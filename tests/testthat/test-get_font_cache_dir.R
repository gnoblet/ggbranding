test_that("get_font_cache_dir returns a valid directory path", {
  temp_dir <- fs::file_temp()

  with_mocked_bindings(
    `rappdirs::user_cache_dir` = function(...) temp_dir,
    {
      cache_dir <- get_font_cache_dir()

      expect_type(cache_dir, "character")
      expect_length(cache_dir, 1)
      expect_true(fs::is_absolute_path(cache_dir))
      expect_true(grepl("ggbranding", cache_dir) || identical(cache_dir, temp_dir))
      expect_true(fs::dir_exists(cache_dir))
    }
  )

  if (fs::dir_exists(temp_dir)) fs::dir_delete(temp_dir)
})

test_that("get_font_cache_dir is consistent across calls", {
  temp_dir <- fs::file_temp()

  with_mocked_bindings(
    `rappdirs::user_cache_dir` = function(...) temp_dir,
    {
      cache_dir1 <- get_font_cache_dir()
      cache_dir2 <- get_font_cache_dir()

      expect_equal(cache_dir1, cache_dir2)
    }
  )

  if (fs::dir_exists(temp_dir)) fs::dir_delete(temp_dir)
})

test_that("get_font_cache_dir uses rappdirs correctly", {
  temp_dir <- fs::file_temp()

  with_mocked_bindings(
    `rappdirs::user_cache_dir` = function(...) temp_dir,
    {
      expected <- temp_dir
      actual <- get_font_cache_dir()

      expect_equal(actual, expected)
    }
  )

  if (fs::dir_exists(temp_dir)) fs::dir_delete(temp_dir)
})

test_that("get_font_cache_dir creates directory if missing", {
  temp_dir <- fs::file_temp()

  with_mocked_bindings(
    `rappdirs::user_cache_dir` = function(...) temp_dir,
    {
      cache_dir <- get_font_cache_dir()

      # Remove directory if present
      if (fs::dir_exists(cache_dir)) {
        fs::dir_delete(cache_dir)
      }
      expect_false(fs::dir_exists(cache_dir))

      # Should recreate it
      cache_dir2 <- get_font_cache_dir()
      expect_equal(cache_dir, cache_dir2)
      expect_true(fs::dir_exists(cache_dir2))
    }
  )

  if (fs::dir_exists(temp_dir)) fs::dir_delete(temp_dir)
})
