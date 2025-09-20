test_that("add_branding parameter validation works", {
  expect_error(
    add_branding(caption_halign = -1),
    regexp = "Element 1 is not >= 0."
  )
  expect_error(
    add_branding(caption_halign = 2),
    regexp = "Element 1 is not <= 1."
  )
  expect_error(
    add_branding(text_family = ""),
    regexp = "must have at least 1 characters"
  )
})

test_that("add_branding requires ggtext package", {
  # Mock requireNamespace to return FALSE
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) FALSE,
    .package = "base"
  )

  expect_error(
    add_branding(github = "test"),
    "Package 'ggtext' is required"
  )
})

test_that("add_branding returns ggplot2 components", {
  # Skip if ggtext not available
  skip_if_not_installed("ggtext")

  result <- add_branding(github = "testuser", setup_fonts = FALSE)

  expect_type(result, "list")
  expect_length(result, 2)

  # Should contain labs() and theme() components
  expect_s3_class(result[[1]], "ggplot2::labels")
  expect_s3_class(result[[2]], "theme")
})

test_that("add_branding passes parameters to branding correctly", {
  skip_if_not_installed("ggtext")

  # Mock branding to capture parameters
  captured_params <- NULL

  local_mocked_bindings(
    branding = function(...) {
      captured_params <<- list(...)
      return("mock caption")
    }
  )

  add_branding(
    github = "testuser",
    linkedin = "testprofile",
    additional_text = "Test data",
    text_position = "after",
    line_spacing = 2L,
    icon_color = "red",
    text_color = "blue",
    text_family = "Arial",
    setup_fonts = FALSE
  )

  expect_equal(captured_params$github, "testuser")
  expect_equal(captured_params$linkedin, "testprofile")
  expect_equal(captured_params$additional_text, "Test data")
  expect_equal(captured_params$text_position, "after")
  expect_equal(captured_params$line_spacing, 2L)
  expect_equal(captured_params$icon_color, "red")
  expect_equal(captured_params$text_color, "blue")
  expect_equal(captured_params$text_family, "Arial")
  expect_equal(captured_params$setup_fonts, FALSE)
})

test_that("add_branding creates proper element_textbox_simple", {
  skip_if_not_installed("ggtext")

  result <- add_branding(
    github = "testuser",
    caption_halign = 0.5,
    caption_width = "80%",
    setup_fonts = FALSE
  )

  # Check that theme component has plot.caption element
  theme_element <- result[[2]]
  expect_true("plot.caption" %in% names(theme_element))
})

test_that("add_branding handles caption styling options", {
  skip_if_not_installed("ggtext")

  # Test with caption width
  result_width <- add_branding(
    github = "test",
    caption_width = "90%",
    setup_fonts = FALSE
  )

  # Test with caption alignment
  result_align <- add_branding(
    github = "test",
    caption_halign = 1,
    setup_fonts = FALSE
  )

  # Both should return valid ggplot components
  expect_length(result_width, 2)
  expect_length(result_align, 2)
})

test_that("add_branding works with ggplot2 plots", {
  skip_if_not_installed("ggtext")
  skip_if_not_installed("ggplot2")

  library(ggplot2)

  # Create a basic plot
  p <- ggplot(mtcars, aes(x = mpg, y = wt)) +
    geom_point()

  # Should be able to add branding without error
  expect_no_error({
    p + add_branding(github = "testuser", setup_fonts = FALSE)
  })
})

test_that("add_branding sets caption correctly", {
  skip_if_not_installed("ggtext")

  local_mocked_bindings(
    branding = function(...) "Test Caption"
  )

  result <- add_branding(github = "test", setup_fonts = FALSE)

  # Extract the caption from labs component
  labs_component <- result[[1]]
  expect_equal(labs_component$caption, "Test Caption")
})

test_that("add_branding handles all platform parameters", {
  skip_if_not_installed("ggtext")

  captured_params <- NULL

  local_mocked_bindings(
    branding = function(...) {
      captured_params <<- list(...)
      return("mock")
    }
  )

  add_branding(
    github = "gh_user",
    gitlab = "gl_user",
    linkedin = "li_user",
    bluesky = "bs_user",
    twitter = "tw_user",
    mastodon = "mas_user",
    orcid = "orcid_id",
    email = "test@email.com",
    website = "website.com",
    custom_icons = c(envelope = "contact@test.com"),
    setup_fonts = FALSE
  )

  expect_equal(captured_params$github, "gh_user")
  expect_equal(captured_params$gitlab, "gl_user")
  expect_equal(captured_params$linkedin, "li_user")
  expect_equal(captured_params$bluesky, "bs_user")
  expect_equal(captured_params$twitter, "tw_user")
  expect_equal(captured_params$mastodon, "mas_user")
  expect_equal(captured_params$orcid, "orcid_id")
  expect_equal(captured_params$email, "test@email.com")
  expect_equal(captured_params$website, "website.com")
  expect_equal(
    captured_params$custom_icons,
    c(envelope = "contact@test.com")
  )
})

test_that("add_branding handles edge cases", {
  skip_if_not_installed("ggtext")

  # No platforms specified
  result_empty <- add_branding(setup_fonts = FALSE)
  expect_length(result_empty, 2)

  # Only additional text
  result_text_only <- add_branding(
    additional_text = "Just text",
    setup_fonts = FALSE
  )
  expect_length(result_text_only, 2)
})

test_that("add_branding handles text_family parameter", {
  skip_if_not_installed("ggtext")

  captured_params <- NULL

  local_mocked_bindings(
    branding = function(...) {
      captured_params <<- list(...)
      return("mock")
    }
  )

  add_branding(
    github = "test",
    text_family = "Times",
    setup_fonts = FALSE
  )

  expect_equal(captured_params$text_family, "Times")

  # Test default text_family
  add_branding(
    github = "test",
    setup_fonts = FALSE
  )

  expect_equal(captured_params$text_family, "sans")
})
