#' List Available Icons
#'
#' Shows all available icons from the icons_df dataset that can be used
#' in the custom_icons parameter of branding() and add_branding() functions.
#'
#' @typed search: NULL | character(1)
#'   Optional search term to filter icons by name, label, or search terms (optional)
#' @typed show_unicode: logical(1)
#'   Whether to show the Unicode values for icons. (default: FALSE)
#' @typed show_styles: logical(1)
#'   Whether to show the icon styles (brands, solid, etc.). (default: FALSE)
#'
#' @typedreturn data.frame
#'   A data frame with available icons and their metadata
#'
#' @examples
#' \donttest{
#' # List all available icons
#' list_available_icons()
#'
#' # Search for communication-related icons
#' list_available_icons(search = "envelope")
#'
#' # Search for social media icons
#' list_available_icons(search = "github")
#'
#' # Show with Unicode values
#' list_available_icons(search = "twitter", show_unicode = TRUE)
#'
#' # Show with styles information
#' list_available_icons(search = "phone", show_styles = TRUE)
#' }
#'
#' @export
list_available_icons <- function(
  search = NULL,
  show_unicode = FALSE,
  show_styles = FALSE
) {
  #------ PARAMETER VALIDATION ------#

  checkmate::assert_string(search, null.ok = TRUE, min.chars = 1)
  checkmate::assert_logical(show_unicode, len = 1, any.missing = FALSE)
  checkmate::assert_logical(show_styles, len = 1, any.missing = FALSE)

  #------ FUNCTION LOGIC ------#

  # get the icons data
  result <- icons_df

  # filter by search term if provided
  if (!is.null(search)) {
    search_lower <- tolower(search)

    # search in name, label, and search_terms columns
    matches <- grepl(search_lower, tolower(result$name)) |
      grepl(search_lower, tolower(result$label)) |
      grepl(search_lower, tolower(result$search_terms))

    result <- result[matches, ]

    if (nrow(result) == 0) {
      rlang::inform(c(
        "!" = paste("No icons found matching search term:", search),
        "i" = "Try a different search term or use list_available_icons() to see all icons"
      ))
      return(data.frame())
    }
  }

  # select columns to show
  cols_to_show <- c("name", "label")

  if (show_unicode) {
    cols_to_show <- c(cols_to_show, "unicode_full")
  }

  if (show_styles) {
    cols_to_show <- c(cols_to_show, "styles")
  }

  # always add search_terms if they exist and aren't empty
  if ("search_terms" %in% names(result)) {
    result_with_terms <- result[result$search_terms != "", ]
    if (nrow(result_with_terms) > 0) {
      cols_to_show <- c(cols_to_show, "search_terms")
    }
  }

  # select and reorder columns
  result <- result[, cols_to_show, drop = FALSE]

  # sort by name for easier browsing
  result <- result[order(result$name), ]

  # reset row names
  rownames(result) <- NULL

  # inform user about search results
  if (!is.null(search)) {
    rlang::inform(c(
      "i" = paste("Found", nrow(result), "icon(s) matching:", search)
    ))
  } else {
    rlang::inform(c(
      "i" = paste("Showing all", nrow(result), "available icons"),
      "*" = "Use the 'name' column values in custom_icons parameter"
    ))
  }

  return(result)
}
