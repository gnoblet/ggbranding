#' Sanitize Character Strings for HTML Rendering
#'
#' Adds zero-width spaces after problematic characters to prevent
#' HTML tag auto-detection in grid text rendering.
#'
#' @typed x: character
#'   Character vector to sanitize
#'
#' @typedreturn character
#'   Sanitized character vector with zero-width spaces added
#'
#' @examples
#' \dontrun{
#' # Sanitize email addresses
#' sanitize_chr("contact@example.com")
#'
#' # Sanitize URLs with forward slashes
#' sanitize_chr("https://example.com/path")
#'
#' # Handle vectors
#' sanitize_chr(c("user@domain.com", "path/to/file"))
#' }
#'
#' @keywords internal
sanitize_chr <- function(x) {
  #------ PARAMETER VALIDATION ------#

  checkmate::assert_character(x, any.missing = TRUE)

  #------ FUNCTION LOGIC ------#

  # handle NULL and NA values
  if (is.null(x)) {
    return(x)
  }

  # vectorized operation to handle character vectors
  result <- ifelse(
    is.na(x),
    x,
    {
      # Add zero-width space after problematic characters to break auto-detection
      temp <- stringr::str_replace_all(x, stringr::fixed("@"), "@\u200B")
      temp <- stringr::str_replace_all(temp, stringr::fixed("/"), "/\u200B")
      temp <- stringr::str_replace_all(temp, stringr::fixed("<"), "<\u200B")
      temp <- stringr::str_replace_all(temp, stringr::fixed(">"), ">\u200B")
      temp
    }
  )

  return(result)
}
