#' Add Personal Branding to ggplot2 Charts
#'
#' This function creates a formatted caption with social media icons and usernames
#' that can be easily added to ggplot2 charts for personal branding.
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
#'   Color for icons. (default is "#666666")
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
#' @typed text_family: NULL | character(1)
#'   Font family for text/usernames. (default: NULL uses system default)
#' @typed setup_fonts: logical(1)
#'   Whether to automatically setup Font Awesome fonts. (default: TRUE)
#'
#' @typedreturn character(1)
#'   A character string containing HTML-formatted caption text
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(ggtext)
#'
#' # Basic usage with GitHub and LinkedIn
#' caption <- branding(github = "yourusername", linkedin = "yourprofile")
#'
#' ggplot(mtcars, aes(x = mpg, y = wt)) +
#'   geom_point() +
#'   labs(caption = caption) +
#'   theme(plot.caption = ggtext::element_textbox_simple())
#'
#' # With custom colors
#' caption <- branding(
#'   github = "yourusername",
#'   linkedin = "yourprofile",
#'   use_brand_colors = TRUE
#' )
#'
#' # With additional text and custom spacing
#' caption <- branding(
#'   github = "yourusername",
#'   linkedin = "yourprofile",
#'   additional_text = "Data source: mtcars dataset",
#'   text_position = "before",
#'   line_spacing = 2L,
#'   icon_color = "steelblue",
#'   text_color = "steelblue"
#' )
#'
#' # With custom icons from icons_df
#' caption <- branding(
#'   github = "yourusername",
#'   custom_icons = c(
#'     envelope = "contact@example.com",
#'     globe = "https://mywebsite.com",
#'     rss = "myblog"
#'   )
#' )
#' }
#'
#' @export
branding <- function(
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
  text_family = NULL,
  setup_fonts = TRUE
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
  checkmate::assert_integer(
    line_spacing,
    len = 1,
    lower = 1,
    upper = 3,
    any.missing = FALSE
  )
  checkmate::assert_string(icon_color, min.chars = 1)
  checkmate::assert_string(text_color, min.chars = 1)
  checkmate::assert_logical(use_brand_colors, len = 1, any.missing = FALSE)
  checkmate::assert_string(icon_size, min.chars = 1)
  checkmate::assert_string(text_size, min.chars = 1)
  checkmate::assert_string(line_height, min.chars = 1)
  checkmate::assert_string(text_family, null.ok = TRUE, min.chars = 1)
  checkmate::assert_logical(setup_fonts, len = 1, any.missing = FALSE)

  # names of custom icons exist in icons_df

  #------ FUNCTION LOGIC ------#

  # setup fonts if requested
  if (setup_fonts) {
    fa_setup(quiet = TRUE)
  }

  # Font family mapping based on icon styles
  font_family_map <- c(
    "brands" = "Font Awesome 7 Brands",
    "solid" = "Font Awesome 7 Free Solid"
  )

  # collect all platforms in a named list, discarding NULL entries
  social_items <- list(
    github = github,
    gitlab = gitlab,
    linkedin = linkedin,
    bluesky = bluesky,
    twitter = twitter,
    mastodon = mastodon,
    orcid = orcid,
    email = email,
    website = website
  )
  social_items <- purrr::discard(social_items, is.null)

  # add custom icons if provided
  if (!is.null(custom_icons)) {
    custom_list <- as.list(custom_icons)
    social_items <- c(social_items, custom_list)
  }
  social_items <- purrr::imap(social_items, \(x, idx) {
    list(platform = idx, username = x)
  })

  # helper to turn a social media item to HTML
  make_html_item <- function(item) {
    platform <- item$platform
    username <- sanitize_chr(item$username)

    # grab the icon and style for this platform
    icon_data <- icons_df[icons_df$name == platform, ]

    if (nrow(icon_data) > 0) {
      icon <- icon_data[['unicode_full']][1]
      icon_style <- icon_data[['styles']][1]
      fa_font_family <- font_family_map[[icon_style]]
    } else {
      # fallback to "link" icon if platform not found
      icon <- "&#xf0c1;"
      fa_font_family <- "Font Awesome 7 Free Solid" # link icon is in Free Solid
      rlang::inform(
        glue::glue(
          "No icon found for platform '{platform}', using generic link icon with following unicode: 'xf0c1'."
        )
      )
    }

    # assemble the HTML string with glue
    text_style <- if (is.null(text_family)) {
      glue::glue(
        "color: {text_color}; font-size: {text_size}; line-height: {line_height};"
      )
    } else {
      glue::glue(
        "font-family: {text_family}; color: {text_color}; font-size: {text_size}; line-height: {line_height};"
      )
    }

    glue::glue(
      "<span style='font-family:\"{fa_font_family}\"; ",
      "color: {icon_color}; font-size: {icon_size};'>{icon}</span> ",
      "<span style='{text_style}'>",
      "{username}</span>"
    )
  }

  # apply the helper to each item
  html_items <- purrr::map_chr(social_items, make_html_item)

  # paste all items with transparent dots for spacing
  separator_span <- "<span style='color: transparent; font-size: 8pt;'>...</span>"
  branding_caption <- paste(html_items, collapse = separator_span)

  # combine with additional text if provided
  final_caption <- branding_caption
  if (!is.null(additional_text)) {
    additional_text_style <- if (is.null(text_family)) {
      glue::glue(
        "color: {text_color}; font-size: {text_size}; line-height: {line_height};"
      )
    } else {
      glue::glue(
        "font-family: {text_family}; color: {text_color}; font-size: {text_size}; line-height: {line_height};"
      )
    }

    styled_additional_text <- glue::glue(
      "<span style='{additional_text_style}'>",
      "{additional_text}</span>"
    )

    # create the separator with specified number of line breaks
    line_separator <- paste(rep("<br>", line_spacing), collapse = "")

    if (text_position == "before") {
      final_caption <- paste(
        styled_additional_text,
        branding_caption,
        sep = line_separator
      )
    } else {
      final_caption <- paste(
        branding_caption,
        styled_additional_text,
        sep = line_separator
      )
    }
  }

  return(final_caption)
}
