test_that("branding parameter validation works", {
  expect_error(branding(github = 123), regexp = "Must be of type 'string'")
  expect_error(
    branding(linkedin = ""),
    regexp = "must have at least 1 characters"
  )
  expect_error(branding(custom_icons = c("test")), regexp = "Must have names") # needs names
  expect_error(
    branding(additional_text = ""),
    regexp = "must have at least 1 characters"
  )
  expect_error(
    branding(text_position = "middle"),
    regexp = "Must be element of"
  )
  expect_error(branding(line_spacing = 0), regexp = "Must be of type 'integer'")
  expect_error(branding(line_spacing = 4L), regexp = "Element 1 is not <= 3.")
  expect_error(
    branding(icon_color = ""),
    regexp = "must have at least 1 characters"
  )
  expect_error(
    branding(text_family = ""),
    regexp = "must have at least 1 characters"
  )
  expect_error(
    branding(additional_text_color = ""),
    regexp = "must have at least 1 characters"
  )
  expect_error(
    branding(additional_text_size = ""),
    regexp = "must have at least 1 characters"
  )
  # text_family = NULL should be allowed
  expect_no_error(branding(
    github = "test",
    text_family = NULL,
    setup_fonts = FALSE
  ))
})

test_that("branding returns HTML string", {
  result <- branding(github = "testuser")

  expect_type(result, "character")
  expect_length(result, 1)
  expect_true(grepl("<span", result))
  expect_true(grepl("Font Awesome", result))
})

test_that("branding handles single platform correctly", {
  result <- branding(github = "testuser", setup_fonts = FALSE)

  expect_true(grepl("testuser", result))
  expect_true(grepl("xf09b", result, ignore.case = TRUE))
})

test_that("branding handles multiple platforms with spacing", {
  result <- branding(
    github = "user1",
    linkedin = "user2",
    setup_fonts = FALSE
  )

  expect_true(grepl("user1", result))
  expect_true(grepl("user2", result))
  # Check for transparent dots spacing
  expect_true(grepl("transparent.*\\.\\.\\.", result))
})

test_that("branding handles additional_text correctly", {
  # Test with additional text before
  result_before <- branding(
    github = "testuser",
    additional_text = "Data source: Test",
    text_position = "before",
    setup_fonts = FALSE
  )

  expect_true(grepl("Data source: Test", result_before))
  expect_true(grepl("testuser", result_before))

  # Test with additional text after
  result_after <- branding(
    github = "testuser",
    additional_text = "Data source: Test",
    text_position = "after",
    setup_fonts = FALSE
  )

  expect_true(grepl("Data source: Test", result_after))
  expect_true(grepl("testuser", result_after))
})

test_that("branding handles line_spacing correctly", {
  result_single <- branding(
    github = "testuser",
    additional_text = "Test text",
    line_spacing = 1L,
    setup_fonts = FALSE
  )

  result_double <- branding(
    github = "testuser",
    additional_text = "Test text",
    line_spacing = 2L,
    setup_fonts = FALSE
  )

  result_triple <- branding(
    github = "testuser",
    additional_text = "Test text",
    line_spacing = 3L,
    setup_fonts = FALSE
  )

  # Should have different numbers of <br> tags
  expect_equal(
    lengths(regmatches(result_single, gregexpr("<br>", result_single))),
    1
  )
  expect_equal(
    lengths(regmatches(result_double, gregexpr("<br>", result_double))),
    2
  )
  expect_equal(
    lengths(regmatches(result_triple, gregexpr("<br>", result_triple))),
    3
  )
})

test_that("branding works without additional_text", {
  result <- branding(github = "testuser", setup_fonts = FALSE)

  expect_false(grepl("<br>", result))
  expect_true(grepl("testuser", result))
})

test_that("branding handles custom_icons correctly", {
  result <- branding(
    custom_icons = c(envelope = "test@email.com", globe = "website.com"),
    setup_fonts = FALSE
  )

  expect_true(grepl("email.com", result))
  expect_true(grepl("website.com", result))
})

test_that("branding handles font setup parameter", {
  # Mock fa_setup to track if it's called
  fa_setup_called <- FALSE

  with_mocked_bindings(
    fa_setup = function(...) {
      fa_setup_called <<- TRUE
    },
    {
      branding(github = "test", setup_fonts = TRUE)
      expect_true(fa_setup_called)

      fa_setup_called <- FALSE
      branding(github = "test", setup_fonts = FALSE)
      expect_false(fa_setup_called)
    }
  )
})

test_that("branding sanitizes usernames", {
  # Mock sanitize_chr to verify it's called
  sanitize_called <- FALSE

  with_mocked_bindings(
    sanitize_chr = function(x) {
      sanitize_called <<- TRUE
      return(x)
    },
    {
      branding(github = "test@user.com", setup_fonts = FALSE)
      expect_true(sanitize_called)
    }
  )
})

test_that("branding uses correct font families", {
  result <- branding(github = "testuser", setup_fonts = FALSE)

  # Should use Font Awesome 7 Brands for GitHub
  expect_true(grepl("Font Awesome 7 Brands", result))
})

test_that("branding handles missing icons gracefully", {
  expect_message(
    result <- branding(
      custom_icons = c(nonexistent = "test"),
      setup_fonts = FALSE
    ),
    "No icon found for platform"
  )

  # Should still return a result with fallback icon
  expect_type(result, "character")
  expect_true(grepl("test", result))
})

test_that("branding applies styling correctly", {
  result <- branding(
    github = "testuser",
    icon_color = "red",
    text_color = "blue",
    icon_size = "12pt",
    text_size = "10pt",
    setup_fonts = FALSE
  )

  expect_true(grepl("color: red", result))
  expect_true(grepl("color: blue", result))
  expect_true(grepl("font-size: 12pt", result))
  expect_true(grepl("font-size: 10pt", result))
})

test_that("branding applies text_family correctly", {
  # Test with specified font family
  result <- branding(
    github = "testuser",
    text_family = "Arial",
    setup_fonts = FALSE
  )

  expect_true(grepl("font-family: Arial", result))

  # Test default text_family (NULL) - should NOT include font-family
  result_default <- branding(
    github = "testuser",
    setup_fonts = FALSE
  )

  expect_false(grepl("font-family:", result_default))

  # Test with NULL explicitly
  result_null <- branding(
    github = "testuser",
    text_family = NULL,
    setup_fonts = FALSE
  )

  expect_false(grepl("font-family:", result_null))
})

test_that("branding applies additional_text styling correctly", {
  # Test with custom additional text color and size
  result <- branding(
    github = "testuser",
    additional_text = "Data source: Test",
    additional_text_color = "red",
    additional_text_size = "12pt",
    setup_fonts = FALSE
  )

  # Should contain the custom styling for additional text
  expect_true(grepl("Data source: Test", result))
  expect_true(grepl("color: red", result))
  expect_true(grepl("font-size: 12pt", result))

  # Test fallback behavior - should use text_color and text_size when additional_text_* are NULL
  result_fallback <- branding(
    github = "testuser",
    additional_text = "Data source: Test",
    text_color = "blue",
    text_size = "10pt",
    additional_text_color = NULL,
    additional_text_size = NULL,
    setup_fonts = FALSE
  )

  expect_true(grepl("Data source: Test", result_fallback))
  expect_true(grepl("color: blue", result_fallback))
  expect_true(grepl("font-size: 10pt", result_fallback))

  # Test mixed usage - custom color but default size
  result_mixed <- branding(
    github = "testuser",
    additional_text = "Data source: Test",
    text_color = "black",
    text_size = "8pt",
    additional_text_color = "green",
    additional_text_size = NULL,
    setup_fonts = FALSE
  )

  expect_true(grepl("color: green", result_mixed))
  expect_true(grepl("font-size: 8pt", result_mixed))
})
