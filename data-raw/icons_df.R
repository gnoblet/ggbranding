# Data Generation Script for ggbranding Package
# This script parses Font Awesome YAML metadata to extract Unicode values
# for brand icons and communication icons (envelope, phone) with version tracking

# load required packages
library(httr2)
library(yaml)
library(rlang)
library(stringr)
library(purrr)
library(usethis)

# configuration
TIMEOUT_SECONDS <- 30
USER_AGENT <- "ggbranding-R-package/1.0"

# Font Awesome Source URLs
fa_yml_url <- "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/7.x/metadata/icons.yml"


# safe fetch raw content from URL
safe_fetch_raw <- function(url, source_name) {
  rlang::try_fetch(
    {
      cat("Fetching", source_name, "from Font Awesome...\n")

      req <- httr2::request(url) |>
        httr2::req_user_agent(USER_AGENT) |>
        httr2::req_timeout(TIMEOUT_SECONDS)

      resp <- httr2::req_perform(req)

      if (httr2::resp_status(resp) == 200) {
        content <- httr2::resp_body_string(resp)
        cat("✓ Successfully fetched", source_name, "\n")
        return(content)
      } else {
        warning(paste(
          "HTTP",
          httr2::resp_status(resp),
          "error from",
          source_name
        ))
        return(NULL)
      }
    },
    error = function(cnd) {
      warning(paste(
        "Failed to fetch",
        source_name,
        ":",
        rlang::cnd_message(cnd)
      ))
      return(NULL)
    }
  )
}

# fetch Font Awesome icons YAML and convert to list
icons_yaml <- safe_fetch_raw(fa_yml_url, "icons YAML")
icons_yaml <- yaml::yaml.load(icons_yaml)


# communication icons we want to include (non-brand)
icons_communication <- c(
  "envelope",
  "envelope-open",
  "envelope-circle-check",
  "envelope-open-text",
  "phone",
  "phone-flip",
  "phone-volume",
  "phone-slash",
  "mobile",
  "mobile-screen",
  "mobile-button",
  "at",
  "link",
  "globe",
  "earth",
  "world",
  "rss",
  "wifi",
  "signal",
  "address-book",
  "address-card",
  "contact-book",
  "contact-card",
  "vcard"
)


# keep only icons where "brands" is in styles OR icon name is in COMMUNICATION_ICONS
icons_yaml <- purrr::keep(
  icons_yaml,
  \(x) {
    "brands" %in%
      x$styles |
      (any(x$search$terms %in% icons_communication) & "solid" %in% x$styles)
  }
)

# as.dataframe
icons_df <- purrr::map(
  icons_yaml,
  \(x) {
    data.frame(
      label = x$label,
      unicode = x$unicode,
      unicode_full = paste0("&#x", x$unicode, ";"),
      name = stringr::str_to_lower(stringr::str_replace_all(
        x$label,
        "-| ",
        "_"
      )),
      styles = ifelse("brands" %in% x$styles, "brands", "solid"),
      search_terms = ifelse(
        is.null(x$search$terms),
        "",
        paste(x$search$terms, collapse = ",")
      ),
      aliases = ifelse(
        is.null(x$aliases$names),
        "",
        paste(x$aliases$names, collapse = ",")
      ),
      stringsAsFactors = FALSE
    )
  }
) |>
  purrr::list_rbind()

# save processed data
usethis::use_data(icons_df, overwrite = TRUE)
