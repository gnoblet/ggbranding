# Simple Hex Sticker for ggbranding Package
# Creates a minimal hex with rounded bars and logos using only ggplot2 + patchwork

library(ggplot2)
library(patchwork)
library(ggbranding)
library(showtext)
library(sysfonts)

# Setup fonts
font_add_google("Inter", "inter")
showtext_auto()
showtext_opts(dpi = 300)

# Helper function to create hexagon coordinates
hex_coords <- function(center = c(0, 0), radius = 1) {
  angles <- seq(pi / 6, 2 * pi + pi / 6, length.out = 7)
  data.frame(
    x = center[1] + radius * cos(angles),
    y = center[2] + radius * sin(angles)
  )
}

# Create hexagon background
hex_df <- hex_coords(radius = 1)

hex_bg <- ggplot() +
  geom_polygon(
    data = hex_df,
    aes(x = x, y = y),
    fill = "#F8F9FA",
    color = "#2C3E50",
    linewidth = 2
  ) +
  # Add package name
  annotate(
    "text",
    x = 0,
    y = -0.37,
    label = "ggbranding",
    family = "inter",
    size = 5,
    color = "#2C3E50",
    fontface = "bold"
  ) +
  theme_void() +
  coord_fixed(ratio = 1) +
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA)
  )

# Create fake bar data
fake_data <- data.frame(
  x = c("A", "B", "C", "D", "E", "F"),
  y = c(20, 18, 14, 10, 8, 5)
)

# Create simple bar chart with rounded appearance
bar_chart <- ggplot(fake_data, aes(x = x, y = y)) +
  geom_col(
    fill = "#2C3E50",
    width = 0.7
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.margin = margin(5, 5, 20, 5)
  ) +
  coord_cartesian(ylim = c(0, 28)) +
  # Add branding with two logos
  add_branding(
    github = "ggbranding",
    bluesky = "@ggbranding",
    text_size = "4pt",
    icon_size = "4pt",
    text_family = "inter",
    text_color = "#2C3E50",
    icon_color = "#2C3E50",
    caption_halign = 0.5
  )

# Combine hex background with inset bar chart
sticker <- hex_bg +
  inset_element(
    bar_chart,
    left = 0.13,
    right = 0.87,
    bottom = 0.27,
    top = 0.87
  )

# Save the sticker
ggsave(
  filename = "man/figures/logo.png",
  plot = sticker,
  width = 1.73,
  height = 2,
  units = "in",
  dpi = 300,
  bg = "transparent"
)
