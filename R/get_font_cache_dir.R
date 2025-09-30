#' Get Font Cache Directory
#'
#' Returns the package directory where Font Awesome fonts are/should be cached.
#'
#' @typedreturn character(1)
#'   Absolute path to the Font Awesome fonts cache directory.
#'
#' @examples
#' \donttest{
#' # Get font cache directory
#' cache_dir <- get_font_cache_dir()
#' print(cache_dir)
#' }
#'
#' @export
get_font_cache_dir <- function() {
  #------ FUNCTION LOGIC ------#

  # use rappdirs to get user-specific cache directory for ggbranding
  cache_dir <- rappdirs::user_cache_dir("ggbranding")

  # create directory if it doesn't exist and inform
  if (!fs::dir_exists(cache_dir)) {
    fs::dir_create(cache_dir, recurse = TRUE)
    rlang::inform(paste("Created font cache directory at:", cache_dir))
  }

  return(cache_dir)
}
