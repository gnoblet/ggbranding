#' Add Complete Branding to ggplot2 Charts
#'
#' This function creates a ggplot2 layer that can be added with `+` to apply
#' both theme styling (using element_textbox_simple from ggtext) and branded
#' captions to your ggplot2 charts.
#'
#' @typed github: NULL | character(1)
#'   GitHub username (optional)
#' @typed gitlab: NULL | character(1)
#'   GitLab username (optional)
#' @typed linkedin: NULL | character(1)
#'   LinkedIn username (optional)
#' @typed bluesky: NULL | character(1)
#'   Bluesky handle (optional)
#' @typed twitter: NULL | character(1)
#'   Twitter/X handle (optional)
#' @typed mastodon: NULL | character(1)
#'   Mastodon handle (optional)
#' @typed orcid: NULL | character(1)
#'   ORCID ID (optional)
#' @typed email: NULL | character(1)
#'   Email address (optional)
#' @typed website: NULL | character(1)
#'   Website URL (optional)
#' @typed custom_icons: NULL | character
#'   Named vector of additional icon names and usernames (optional). Names should match icons from icons_df.
#' @typed additional_text: NULL | character(1)
#'   Additional text to include in caption (e.g., "Data source: XYZ")
#' @typed text_position: character(1)
#'   Position of additional text relative to branding. Either "before" or "after". (default: "before")
#' @typed line_spacing: integer(1)
#'   Number of line breaks between additional text and icons (1-3). (default: 1)
#' @typed icon_color: character(1)
#'   Color for icons. (default: "#666666")
#' @typed text_color: character(1)
#'   Color for usernames/text. (default: "#333333")
#' @typed use_brand_colors: logical(1)
#'   Whether to use brand-specific colors for icons. (default: FALSE)
#' @typed icon_size: character(1)
#'   Font size for icons. (default: "8pt")
#' @typed text_size: character(1)
#'   Font size for text/usernames. (default: "8pt")
#' @typed line_height: character(1)
#'   Line height for the caption. (default: "1.2")
#' @typed text_family: character(1)
#'   Font family for text/usernames. (default: "sans")
#' @typed setup_fonts: logical(1)
#'   Whether to automatically setup Font Awesome fonts. (default: TRUE)
#' @typed caption_width: NULL | character(1)
#'   Width specification for caption text box (default: NULL uses ggtext default)
#' @typed caption_halign: numeric(1)
#'   Horizontal alignment for caption (0 = left, 0.5 = center, 1 = right). (default: 0)
#' @typed caption_margin: NULL | ggplot2::margin
#'   Margin specification for caption (default: NULL uses ggtext default)
#'
#' @typedreturn list
#'   A list of ggplot2 components that can be added with `+`
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(ggtext)
#' library(ggbranding)
#'
#' # Use with + in ggplot chain
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   labs(title = "My Plot") +
#'   add_branding(
#'     github = "yourusername",
#'     linkedin = "yourprofile"
#'   )
#'
#' # With additional text
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
#'   geom_point() +
#'   add_branding(
#'     github = "yourusername",
#'     additional_text = "Data source: iris dataset",
#'     text_position = "before"
#'   )
#'
#' # With custom icons and styling
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   add_branding(
#'     github = "yourusername",
#'     custom_icons = c(
#'       envelope = "contact@example.com",
#'       globe = "https://mywebsite.com"
#'     ),
#'     use_brand_colors = TRUE,
#'     caption_halign = 1
#'   )
#' }
#'
#' @export
add_branding <- function(
  github = NULL,
  gitlab = NULL,
  linkedin = NULL,
  bluesky = NULL,
  twitter = NULL,
  mastodon = NULL,
  orcid = NULL,
  email = NULL,
  website = NULL,
  custom_icons = NULL,
  additional_text = NULL,
  text_position = "before",
  line_spacing = 1L,
  icon_color = "#666666",
  text_color = "#333333",
  use_brand_colors = FALSE,
  icon_size = "8pt",
  text_size = "8pt",
  line_height = "1.2",
  text_family = "sans",
  setup_fonts = TRUE,
  caption_width = NULL,
  caption_halign = 0,
  caption_margin = NULL
) {
  #------ PARAMETER VALIDATION ------#

  # platform strings are either NULL or non-empty strings
  checkmate::assert_string(github, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(gitlab, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(linkedin, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(bluesky, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(twitter, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(mastodon, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(orcid, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(email, null.ok = TRUE, min.chars = 1)
  checkmate::assert_string(website, null.ok = TRUE, min.chars = 1)
  checkmate::assert_character(
    custom_icons,
    null.ok = TRUE,
    min.chars = 1,
    any.missing = FALSE,
    names = "named"
  )
  checkmate::assert_string(additional_text, null.ok = TRUE, min.chars = 1)
  checkmate::assert_choice(text_position, choices = c("before", "after"))

  checkmate::assert_string(icon_color, min.chars = 1)
  checkmate::assert_string(text_color, min.chars = 1)
  checkmate::assert_logical(use_brand_colors, len = 1, any.missing = FALSE)
  checkmate::assert_string(icon_size, min.chars = 1)
  checkmate::assert_string(text_size, min.chars = 1)
  checkmate::assert_string(line_height, min.chars = 1)
  checkmate::assert_string(text_family, min.chars = 1)
  checkmate::assert_logical(setup_fonts, len = 1, any.missing = FALSE)
  checkmate::assert_string(caption_width, null.ok = TRUE, min.chars = 1)
  checkmate::assert_number(caption_halign, lower = 0, upper = 1)
  # caption_margin validation is more complex - we'll let ggplot2 handle it

  #------ FUNCTION LOGIC ------#

  # check if ggtext is available
  if (!requireNamespace("ggtext", quietly = TRUE)) {
    rlang::abort(c(
      "Package 'ggtext' is required for add_branding()",
      "i" = "Install it with: install.packages('ggtext')"
    ))
  }

  # create the caption using branding() function with all parameters
  final_caption <- branding(
    github = github,
    gitlab = gitlab,
    linkedin = linkedin,
    bluesky = bluesky,
    twitter = twitter,
    mastodon = mastodon,
    orcid = orcid,
    email = email,
    website = website,
    custom_icons = custom_icons,
    additional_text = additional_text,
    text_position = text_position,
    line_spacing = line_spacing,
    icon_color = icon_color,
    text_color = text_color,
    use_brand_colors = use_brand_colors,
    icon_size = icon_size,
    text_size = text_size,
    line_height = line_height,
    text_family = text_family,
    setup_fonts = setup_fonts
  )

  # prepare theme arguments for element_textbox_simple
  textbox_args <- list(
    halign = caption_halign,
    lineheight = as.numeric(line_height)
  )

  # add optional arguments if provided
  if (!is.null(caption_width)) {
    textbox_args$width = caption_width
  }
  if (!is.null(caption_margin)) {
    textbox_args$margin = caption_margin
  }

  # create the element_textbox_simple with arguments
  caption_element <- do.call(ggtext::element_textbox_simple, textbox_args)

  # return a list of ggplot components that can be added with +
  list(
    ggplot2::labs(caption = final_caption),
    ggplot2::theme(plot.caption = caption_element)
  )
}
