test_that("get_font_cache_dir returns a valid directory path", {
  cache_dir <- get_font_cache_dir()

  expect_type(cache_dir, "character")
  expect_length(cache_dir, 1)
  expect_true(fs::is_absolute_path(cache_dir))
  expect_true(grepl("ggbranding", cache_dir))
  expect_true(fs::dir_exists(cache_dir))
})

test_that("get_font_cache_dir is consistent across calls", {
  cache_dir1 <- get_font_cache_dir()
  cache_dir2 <- get_font_cache_dir()

  expect_equal(cache_dir1, cache_dir2)
})

test_that("get_font_cache_dir uses rappdirs correctly", {
  expected <- rappdirs::user_cache_dir("ggbranding")
  actual <- get_font_cache_dir()

  expect_equal(actual, expected)
})

test_that("get_font_cache_dir creates directory if missing", {
  cache_dir <- get_font_cache_dir()

  # Remove directory
  if (fs::dir_exists(cache_dir)) {
    fs::dir_delete(cache_dir)
  }
  expect_false(fs::dir_exists(cache_dir))

  # Should recreate it
  cache_dir2 <- get_font_cache_dir()
  expect_equal(cache_dir, cache_dir2)
  expect_true(fs::dir_exists(cache_dir2))
})
