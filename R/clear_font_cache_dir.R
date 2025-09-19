#' Clear Font Cache
#'
#' Removes cached Font Awesome fonts to free up space or force re-download.
#'
#' @typed confirm: logical(1)
#'   Whether to ask for confirmation before deleting cached files. (default: TRUE)
#'
#' @typedreturn logical(1)
#'   TRUE if cache was cleared successfully, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#' # Clear font cache
#' clear_font_cache_dir()
#'
#' # Clear without confirmation
#' clear_font_cache_dir(confirm = FALSE)
#' }
#'
#' @export
clear_font_cache_dir <- function(confirm = TRUE) {
  #------ PARAMETER VALIDATION ------#

  # confirm must be a logical scalar
  checkmate::assert_logical(confirm, len = 1, any.missing = FALSE)

  #------ FUNCTION LOGIC ------#

  # get cache directory
  cache_dir <- get_font_cache_dir()

  # if directory doesn't exist, nothing to clear
  if (!fs::dir_exists(cache_dir)) {
    rlang::inform("No font cache directory found.")
    return(TRUE)
  }

  # list cached Font Awesome font files
  cached_files <- fs::dir_ls(
    cache_dir,
    glob = "*Font-Awesome*.otf"
  )

  # if no cached files, nothing to clear
  if (length(cached_files) == 0) {
    rlang::inform("No cached Font Awesome fonts found.")
    return(TRUE)
  }

  # if confirm is TRUE, prompt user
  if (confirm) {
    # list files to be deleted
    rlang::inform(c(
      "i" = paste("Found", length(cached_files), "cached font file(s):"),
      "*" = paste("  -", fs::path_file(cached_files), collapse = "\n* ")
    ))

    # ask for confirmation up to 3 times
    max_tries <- 3
    tries <- 0
    while (tries < max_tries) {
      response <- readline(prompt = "Delete these files? (y/N): ")
      resp_low <- tolower(trimws(response))

      if (resp_low %in% c("n", "no")) {
        rlang::inform("Cache clearing cancelled.")
        return(FALSE)
      } else if (resp_low %in% c("y", "yes", "")) {
        rlang::inform("Proceeding to delete cached files...")
        return(TRUE)
      } else {
        rlang::inform("Invalid response (must be y/N).")
        tries <- tries + 1
        if (tries < max_tries) {
          rlang::inform(paste0(
            "Please try again (attempt ",
            tries + 1,
            " of ",
            max_tries,
            ")."
          ))
        }
      }
    }

    # If we get here, the user failed to give a valid answer `max_tries` times
    rlang::inform("Too many invalid attempts – cache clearing aborted.")
    return(FALSE)
  }

  # attempt to delete files
  success <- fs::file_delete(cached_files)

  # fs::file_delete returns the paths that were deleted successfully
  # If all files were deleted, the length should match
  if (length(success) == length(cached_files)) {
    rlang::inform("Font cache cleared successfully.")
    return(TRUE)
  } else {
    rlang::warn(c(
      "Some files could not be deleted.",
      "*" = paste("Deleted:", length(success), "of", length(cached_files))
    ))
    return(FALSE)
  }
}
