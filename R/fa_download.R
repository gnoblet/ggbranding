#' Download Font Awesome Fonts
#'
#' Downloads Font Awesome fonts from the official GitHub releases if not already cached.
#'
#' @typed version: character(1)
#'   Font Awesome version to download in semantic versioning format. Must match pattern. (default: "7.0.1")
#' @typed force_download: logical(1)
#'   Whether to force re-download even if cached. (default: FALSE)
#' @typed quiet: logical(1)
#'   Whether to suppress download messages. (default: FALSE)
#'
#' @typedreturn list
#'   Named list with paths to downloaded font files ('brands' and 'free_solid'), or NULL values if download failed.
#'
#' @examples
#' \donttest{
#' # Download latest Font Awesome fonts
#' font_paths <- fa_download()
#' }
#'
#' @export
fa_download <- function(
  version = "7.0.1",
  force_download = FALSE,
  quiet = FALSE
) {
  #------ PARAMETER VALIDATION ------#

  # version is a non-empty string matching semantic versioning
  checkmate::assert_string(
    version,
    min.chars = 1,
    pattern = "^[0-9]+\\.[0-9]+\\.[0-9]+$"
  )
  if (version != "7.0.1") {
    rlang::abort(
      message = "Currently, only version '7.0.1' is supported for download.",
      class = "version_not_supported"
    )
  }

  # force_download and quiet are logical scalars
  checkmate::assert_logical(force_download, len = 1, any.missing = FALSE)
  checkmate::assert_logical(quiet, len = 1, any.missing = FALSE)

  #------- FUNCTION LOGIC ------#

  # Download both font types
  brands_path <- fa_download_single(
    font_type = "brands",
    version = version,
    force_download = force_download,
    quiet = quiet
  )

  free_solid_path <- fa_download_single(
    font_type = "free_solid",
    version = version,
    force_download = force_download,
    quiet = quiet
  )

  return(list(
    brands = brands_path,
    free_solid = free_solid_path
  ))
}

#' Download Single Font Awesome Font Type
#'
#' Helper function to download a specific Font Awesome font type.
#'
#' @typed font_type: character(1)
#'   Font type to download: "brands" or "free_solid"
#' @typed version: character(1)
#'   Font Awesome version to download in semantic versioning format
#' @typed force_download: logical(1)
#'   Whether to force re-download even if cached
#' @typed quiet: logical(1)
#'   Whether to suppress download messages
#'
#' @typedreturn character(1) | NULL
#'   Character string with path to the downloaded font file, or NULL if download failed.
#'
#' @keywords internal
fa_download_single <- function(
  font_type,
  version,
  force_download,
  quiet
) {
  #------ PARAMETER VALIDATION ------#

  checkmate::assert_choice(font_type, choices = c("brands", "free_solid"))

  #------- FUNCTION LOGIC ------#

  # Define font file patterns and names based on type
  font_config <- switch(
    font_type,
    "brands" = list(
      pattern = "*Font*Awesome*Brands*400.otf",
      filename = paste0("Font-Awesome-", version, "-Brands-Regular-400.otf"),
      display_name = "Brands"
    ),
    "free_solid" = list(
      pattern = "*Font*Awesome*Free*Solid*900.otf",
      filename = paste0("Font-Awesome-", version, "-Free-Solid-900.otf"),
      display_name = "Free Solid"
    )
  )

  # 1. Check if font is already cached
  cache_dir <- get_font_cache_dir()
  font_file <- fs::path(cache_dir, font_config$filename)

  # if font already exists and not forcing download, return path
  if (fs::file_exists(font_file) && !force_download) {
    if (!quiet) {
      rlang::inform(c(
        "i" = paste(
          "Font Awesome",
          font_config$display_name,
          "font already cached"
        ),
        "*" = paste("Location:", font_file)
      ))
    }
    return(font_file)
  }

  # inform user about download if not quiet
  if (!quiet) {
    rlang::inform(c(
      "i" = paste(
        "Downloading Font Awesome",
        version,
        font_config$display_name,
        "font..."
      ),
      "*" = "This may take a moment"
    ))
  }

  # 2. Download and extract

  # Font Awesome download URL (using GitHub releases)
  base_url <- "https://github.com/FortAwesome/Font-Awesome/releases/download"
  zip_url <- paste0(
    base_url,
    "/",
    version,
    "/fontawesome-free-",
    version,
    "-desktop.zip"
  )

  # download to temporary file
  temp_zip <- fs::file_temp(ext = "zip")

  # try to download and extract
  rlang::try_fetch(
    {
      # download zip file
      response <- httr2::request(zip_url) |>
        httr2::req_perform(path = temp_zip)

      # check for HTTP errors (200 is ok)
      if (httr2::resp_status(response) != 200) {
        rlang::abort(
          message = paste(
            "Failed to download Font Awesome fonts.",
            "HTTP status:",
            httr2::resp_status(response)
          ),
          class = "download_error"
        )
      }

      # extract the zip file
      temp_extract_dir <- fs::file_temp()
      fs::dir_create(temp_extract_dir)

      utils::unzip(temp_zip, exdir = temp_extract_dir)

      # find the specific font file we need
      extracted_files <- fs::dir_ls(
        temp_extract_dir,
        recurse = TRUE,
        glob = font_config$pattern
      )

      # if not found, throw error
      if (length(extracted_files) == 0) {
        rlang::abort(
          message = paste(
            "Could not find Font Awesome",
            font_config$display_name,
            "font file in downloaded archive"
          ),
          class = "font_extract_error"
        )
      }

      # if too many found, throw inform message on using first one
      if (length(extracted_files) > 1 && !quiet) {
        rlang::inform(c(
          "i" = paste(
            "Multiple Font Awesome",
            font_config$display_name,
            "font files found in archive"
          ),
          "*" = "Using the first one found"
        ))
      }

      # copy found file to cache directory
      fs::file_copy(extracted_files[1], font_file, overwrite = TRUE)

      # clean up temporary files
      fs::file_delete(temp_zip)
      fs::dir_delete(temp_extract_dir)

      # inform user of success if not quiet
      if (!quiet) {
        rlang::inform(c(
          "v" = paste(
            "Font Awesome",
            font_config$display_name,
            "font downloaded successfully"
          ),
          "*" = paste("Saved to:", font_file)
        ))
      }

      return(font_file)
    },
    error = function(cnd) {
      rlang::warn(c(
        "!" = paste(
          "Failed to download Font Awesome",
          font_config$display_name,
          "font"
        ),
        "x" = conditionMessage(cnd)
      ))

      # clean up temporary files/folder on error
      if (fs::file_exists(temp_zip)) {
        fs::file_delete(temp_zip)
      }
      if (exists("temp_extract_dir") && fs::dir_exists(temp_extract_dir)) {
        fs::dir_delete(temp_extract_dir)
      }

      return(NULL)
    }
  )
}
