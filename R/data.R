#' Icons Data
#'
#' A comprehensive dataset of social media platform icons and brand colors.
#' Generated from multiple online sources including Font Awesome, Simple Icons,
#' and Brand Colors.
#'
#' @format A list with the following components:
#' \describe{
#'   \item{icons}{Named list of Unicode HTML entities for social media icons}
#'   \item{colors}{Named list of hex color codes for brand colors}
#'   \item{font_family}{Font family name for icon rendering}
#'   \item{last_updated}{POSIXct timestamp of data generation}
#'   \item{sources}{Character string of data sources used}
#'   \item{generation_info}{List of generation metadata}
#' }
#'
#' @examples
#' # Access GitHub icon
#' icons_df$icons$github
#'
#' # Access Spotify brand color
#' icons_df$colors$spotify
#'
#' # List all available platforms
#' names(icons_df$icons)
#'
#' # Check when data was last updated
#' icons_df$last_updated
#'
#' # View data sources
#' icons_df$sources
#'
"icons_df"
