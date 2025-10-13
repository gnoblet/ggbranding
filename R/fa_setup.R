#' Setup Font Awesome Fonts with Auto-Download
#'
#' Automatically sets up Font Awesome fonts, downloading them if necessary.
#' Sets up both Brands and Free Solid font families.
#'
#' @typed auto_download: logical(1)
#'   Whether to automatically download fonts if not found. (default: TRUE)
#' @typed version: character(1)
#'   Font Awesome version to use in semantic versioning format. Must match pattern. (default: "7.0.1")
#' @typed quiet: logical(1)
#'   Whether to suppress messages during setup. (default: FALSE)
#'
#' @typedreturn logical(1)
#'   TRUE if fonts were successfully loaded, FALSE otherwise.
#'
#' @examples
#' \donttest{
#' # Setup fonts with auto-download
#' fa_setup()
#'
#' # Setup without auto-download
#' fa_setup(auto_download = FALSE)
#' }
#'
#' @export
fa_setup <- function(
  auto_download = TRUE,
  version = "7.0.1",
  quiet = FALSE
) {
  #------ PARAMETER VALIDATION ------#

  # auto_download and quiet must be logical scalars
  checkmate::assert_logical(auto_download, len = 1, any.missing = FALSE)
  checkmate::assert_logical(quiet, len = 1, any.missing = FALSE)

  # version must be in semantic versioning format
  checkmate::assert_string(
    version,
    min.chars = 1,
    pattern = "^[0-9]+\\.[0-9]+\\.[0-9]+$"
  )
  if (version != "7.0.1") {
    rlang::abort(
      message = "Currently, only version '7.0.1' is supported.",
      class = "version_not_supported"
    )
  }

  #------- FUNCTION LOGIC ------#

  # 1. Check if fonts are already loaded
  font_families <- rlang::try_fetch(
    sysfonts::font_families(),
    error = function(cnd) NULL
  )

  brands_loaded <- !is.null(font_families) &&
    "Font Awesome 7 Brands" %in% font_families
  free_solid_loaded <- !is.null(font_families) &&
    "Font Awesome 7 Free Solid" %in% font_families

  if (brands_loaded && free_solid_loaded) {
    if (!quiet) {
      rlang::inform(c(
        "v" = "Font Awesome 7 fonts are already loaded (Brands and Free Solid)"
      ))
    }
    showtext::showtext_auto()
    return(TRUE)
  }

  # 2. Check cache and download if necessary

  # get cache dir and expected font paths
  cache_dir <- get_font_cache_dir()
  cached_brands <- fs::path(
    cache_dir,
    paste0("Font-Awesome-", version, "-Brands-Regular-400.otf")
  )
  cached_free_solid <- fs::path(
    cache_dir,
    paste0("Font-Awesome-", version, "-Free-Solid-900.otf")
  )

  # check what we have cached
  brands_cached <- fs::file_exists(cached_brands)
  free_solid_cached <- fs::file_exists(cached_free_solid)

  # determine what we need to do
  font_paths <- list(brands = NULL, free_solid = NULL)

  if (brands_cached && free_solid_cached) {
    # both are cached
    font_paths$brands <- cached_brands
    font_paths$free_solid <- cached_free_solid
    if (!quiet) {
      rlang::inform(c(
        "i" = "Using cached Font Awesome fonts",
        "*" = paste("Brands:", cached_brands),
        "*" = paste("Free Solid:", cached_free_solid)
      ))
    }
  } else if (auto_download) {
    # some or all fonts missing, attempt download
    if (!quiet) {
      missing_fonts <- c()
      if (!brands_cached) {
        missing_fonts <- c(missing_fonts, "Brands")
      }
      if (!free_solid_cached) {
        missing_fonts <- c(missing_fonts, "Free Solid")
      }

      rlang::inform(c(
        "i" = paste(
          "Font Awesome fonts not found locally:",
          paste(missing_fonts, collapse = ", ")
        ),
        "*" = "Attempting to download..."
      ))
    }

    downloaded_paths <- fa_download(version = version, quiet = quiet)

    # use downloaded paths if successful, otherwise fall back to cached versions
    font_paths$brands <- downloaded_paths$brands %||%
      (if (brands_cached) cached_brands else NULL)
    font_paths$free_solid <- downloaded_paths$free_solid %||%
      (if (free_solid_cached) cached_free_solid else NULL)
  } else {
    # no auto-download, use what we have cached
    if (brands_cached) {
      font_paths$brands <- cached_brands
    }
    if (free_solid_cached) font_paths$free_solid <- cached_free_solid
  }

  # check if we have at least one font available
  if (is.null(font_paths$brands) && is.null(font_paths$free_solid)) {
    if (!quiet) {
      rlang::inform(c(
        "!" = "Font Awesome fonts could not be loaded automatically",
        "i" = "Please either:",
        "*" = "1. Download Font Awesome 7 fonts manually from https://fontawesome.com/download",
        "*" = "2. Extract the 'otf' files from the downloaded archive",
        "*" = "3. Either place them in the cache directory:",
        " " = paste0('   "', cache_dir, '"'),
        "*" = "   (create the directory if it doesn't exist)",
        "*" = "OR",
        "*" = "load them manually with:",
        " " = '   sysfonts::font_add(family = "Font Awesome 7 Brands", regular = "path/to/brands.otf")',
        " " = '   sysfonts::font_add(family = "Font Awesome 7 Free Solid", regular = "path/to/free-solid.otf")'
      ))
    }
    return(FALSE)
  }

  # 3. Load the fonts into R's font system
  success <- TRUE

  rlang::try_fetch(
    {
      # Load Brands font if available and not already loaded
      if (!is.null(font_paths$brands) && !brands_loaded) {
        sysfonts::font_add(
          family = "Font Awesome 7 Brands",
          regular = font_paths$brands
        )
        if (!quiet) {
          rlang::inform(c(
            "v" = "Font Awesome 7 Brands loaded successfully"
          ))
        }
      }

      # Load Free Solid font if available and not already loaded
      if (!is.null(font_paths$free_solid) && !free_solid_loaded) {
        sysfonts::font_add(
          family = "Font Awesome 7 Free Solid",
          regular = font_paths$free_solid
        )
        if (!quiet) {
          rlang::inform(c(
            "v" = "Font Awesome 7 Free Solid loaded successfully"
          ))
        }
      }

      showtext::showtext_auto()

      return(TRUE)
    },
    error = function(cnd) {
      rlang::warn(c(
        "!" = "Failed to load Font Awesome fonts",
        "x" = conditionMessage(cnd)
      ))
      return(FALSE)
    }
  )
}
