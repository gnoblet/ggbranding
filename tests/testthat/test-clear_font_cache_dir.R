test_that("clear_font_cache_dir parameter validation works", {
  expect_error(
    clear_font_cache_dir("yes"),
    regexp = "Must be of type 'logical'"
  )
  expect_error(clear_font_cache_dir(NULL), regexp = "Must be of type 'logical'")
  expect_error(
    clear_font_cache_dir(c(TRUE, FALSE)),
    regexp = "Must have length 1"
  )
})

test_that("clear_font_cache_dir handles non-existent cache directory", {
  temp_dir <- fs::file_temp()

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      expect_message(
        result <- clear_font_cache_dir(confirm = FALSE),
        "No font cache directory found"
      )
      expect_true(result)
    }
  )
})

test_that("clear_font_cache_dir handles empty cache directory", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      expect_message(
        result <- clear_font_cache_dir(confirm = FALSE),
        "No cached Font Awesome fonts found"
      )
      expect_true(result)
    }
  )

  fs::dir_delete(temp_dir)
})

test_that("clear_font_cache_dir deletes Font Awesome files successfully", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)

  # Create mock Font Awesome files
  fa_files <- c(
    fs::path(temp_dir, "Font-Awesome-7.0.1-Brands-Regular-400.otf"),
    fs::path(temp_dir, "Font-Awesome-7.0.1-Free-Solid-900.otf")
  )

  for (file in fa_files) {
    fs::file_create(file)
  }

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      expect_message(
        result <- clear_font_cache_dir(confirm = FALSE),
        "Font cache cleared successfully"
      )
      expect_true(result)
    }
  )

  # Files should be deleted
  expect_false(any(fs::file_exists(fa_files)))

  fs::dir_delete(temp_dir)
})

test_that("clear_font_cache_dir ignores non-Font Awesome files", {
  temp_dir <- fs::file_temp()
  fs::dir_create(temp_dir)

  fa_file <- fs::path(temp_dir, "Font-Awesome-7.0.1-Brands-Regular-400.otf")
  other_file <- fs::path(temp_dir, "other-font.otf")

  fs::file_create(fa_file)
  fs::file_create(other_file)

  with_mocked_bindings(
    get_font_cache_dir = function() temp_dir,
    {
      result <- clear_font_cache_dir(confirm = FALSE)
      expect_true(result)
    }
  )

  # Only FA file deleted, other file remains
  expect_false(fs::file_exists(fa_file))
  expect_true(fs::file_exists(other_file))

  fs::dir_delete(temp_dir)
})

test_that("clear_font_cache_dir with confirm=TRUE requires manual testing", {
  # Interactive confirmation can't be easily automated
  skip("Interactive confirmation requires manual testing")
})
