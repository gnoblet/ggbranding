

<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggbranding <a href="https://gnoblet.github.io/ggbranding/"><img src="man/figures/logo.png" align="right" height="139" alt="ggbranding website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/gnoblet/ggbranding/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gnoblet/ggbranding/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/ggbranding.png)](https://CRAN.R-project.org/package=ggbranding)
[![Codecov test
coverage](https://codecov.io/gh/gnoblet/ggbranding/graph/badge.svg)](https://app.codecov.io/gh/gnoblet/ggbranding)
<!-- badges: end -->

> Add personal branding to ggplot2 charts using Font Awesome 7 icons

**Key Features:**

-   🚀 **Auto Font Setup** - Automatically downloads Font Awesome 7
    fonts on first use
-   🎨 **500+ Icons** - Access to all Font Awesome brand and
    communication icons
-   🎯 **One Function Call** - Add complete branding with
    `add_branding()`
-   🎨 **Customizable** - Brand colors, custom text, and styling options
-   📦 **Lightweight** - Efficient font caching and quite minimal
    dependencies

## Installation

Install the development version from GitHub:

``` r
# library(pak)
pak::pak("gnoblet/ggbranding")
# CRAN version to come
```

## Quick Start

``` r
library(ggplot2)
library(ggtext)
library(ggbranding)
library(showtext)
#> Loading required package: sysfonts
#> Loading required package: showtextdb
library(sysfonts)

# setup dpi
showtext::showtext_opts(dpi = 300)

# add branding with + in ggplot chain
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  labs(title = "My Awesome Plot") +
  add_branding(
    github = "gnoblet",
    bluesky = "@gnoblet",
    linkedin = "gnoblet"
  )
```

<img src="man/figures/README-quick-start-1.png" style="width:100.0%" />

That’s it! The function automatically:

-   Downloads and sets up Font Awesome 7 fonts
-   Applies `ggtext::element_textbox_simple()` theme
-   Creates HTML-formatted captions with icons
-   Handles text sanitization for grid rendering

## Uses Examples

Use with `+` in your ggplot chain:

``` r
# With additional text before branding, custom spacing and blue colors
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point() +
  add_branding(
    github = "gnoblet",
    bluesky = "@gnoblet",
    additional_text = "Data source: iris dataset",
    text_position = "before",
    line_spacing = 2L, # double line breaks for extra space
    icon_color = "blue",
    text_color = "blue",
    additional_text_color = "darkgrey"
  )
```

<img src="man/figures/README-add-branding-basic-1.png"
style="width:100.0%" />

``` r

# With custom styling and Roboto Condensed font
font_add_google("Monoton", "monoton")
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  add_branding(
    github = "GNOBLET",
    bluesky = "@GNOBLET",
    caption_halign = 1, # right-align caption
    icon_size = "12pt", # larger icons
    text_size = "12pt", # larger text,
    text_family = "monoton", # custom font
    caption_margin = ggplot2::margin(t = 20, b = 5, unit = "pt") # custom margin
  )
```

<img src="man/figures/README-add-branding-basic-2.png"
style="width:100.0%" />

``` r

# Use custom icons
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  add_branding(
    github = "gnoblet",
    bluesky = "@gnoblet",
    custom_icons = c(
      envelope = "gnoblet@fake.news",
      rss = "gnoblet.github.io"
    )
  )
#> No icon found for platform 'rss', using generic link icon with following
#> unicode: 'xf0c1'.
```

<img src="man/figures/README-add-branding-basic-3.png"
style="width:100.0%" />

## Supported Platforms

Built-in support for major platforms:

<table>
<thead>
<tr>
<th>Platform</th>
<th>Parameter</th>
<th>Example</th>
</tr>
</thead>
<tbody>
<tr>
<td>GitHub</td>
<td><code>github</code></td>
<td><code>github = "username"</code></td>
</tr>
<tr>
<td>GitLab</td>
<td><code>gitlab</code></td>
<td><code>gitlab = "username"</code></td>
</tr>
<tr>
<td>LinkedIn</td>
<td><code>linkedin</code></td>
<td><code>linkedin = "profile"</code></td>
</tr>
<tr>
<td>Bluesky</td>
<td><code>bluesky</code></td>
<td><code>bluesky = "user.bsky.social"</code></td>
</tr>
<tr>
<td>Twitter/X</td>
<td><code>twitter</code></td>
<td><code>twitter = "handle"</code></td>
</tr>
<tr>
<td>Mastodon</td>
<td><code>mastodon</code></td>
<td><code>mastodon = "@user@server.com"</code></td>
</tr>
<tr>
<td>ORCID</td>
<td><code>orcid</code></td>
<td><code>orcid = "0000-0000-0000-0000"</code></td>
</tr>
<tr>
<td>Email</td>
<td><code>email</code></td>
<td><code>email = "user@email.com"</code></td>
</tr>
<tr>
<td>Website</td>
<td><code>website</code></td>
<td><code>website = "yoursite.com"</code></td>
</tr>
</tbody>
</table>

## Custom Icons

Access 500+ Font Awesome icons with `custom_icons`. To list and search
available icons:

``` r
# Discover available icons
list_available_icons() |> head(5)

# Search for specific icons
list_available_icons(search = "envelope")
```

## Troubleshooting

### Common Issues

``` r
# 1. Icons not displaying
fa_setup(auto_download = TRUE)

# 2. Clear cache if fonts seem corrupted
clear_font_cache_dir(confirm = FALSE)

# 3. Check available icons
head(list_available_icons())

# 4. Test basic functionality
branding(github = "test")
```

### Manual Font Setup (If Needed)

``` r
library(sysfonts)
library(showtext)

# Download Font Awesome 7 from https://fontawesome.com/download
# Extract and use the Brands font file
sysfonts::font_add(
  family = "Font Awesome 7 Brands",
  regular = "path/to/Font-Awesome-7-Brands-Regular-400.otf"
)
sysfonts::font_add(
  family = "Font Awesome 7 Free",
  regular = "path/to/Font-Awesome-7-Free-Solid-900.otf"
)
showtext::showtext_auto()

# Then use with setup_fonts = FALSE
branding(github = "username", setup_fonts = FALSE)
```

## License

GPL v3 or later. See the [LICENSE](LICENSE.md) file for details.

## Citation

``` r
citation("ggbranding")
```

## Acknowledgments

-   Inspired by [Nicola Rennie’s blog
    post](https://nrennie.rbind.io/blog/adding-social-media-icons-ggplot2/)
-   Font Awesome team for their marvelous icoms
-   R community for ggplot2, ggtext, and ecosystem packages

------------------------------------------------------------------------

**Made with ♥ and Font Awesome 7 • Add your branding today!**
