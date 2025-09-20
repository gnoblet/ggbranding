test_that("fa_download parameter validation works", {
  expect_error(
    fa_download(version = "invalid"),
    regexp = 'Must comply to pattern'
  )
  expect_error(fa_download(version = 123), regexp = "Must be of type 'string'")
  expect_error(fa_download(version = "1.2"), regexp = "Must comply to pattern")
  expect_error(
    fa_download(force_download = "yes"),
    regexp = "Must be of type 'logical'"
  )
  expect_error(fa_download(quiet = 1), regexp = "Must be of type 'logical'")
})

test_that("fa_download only supports version 7.0.1", {
  expect_error(
    fa_download(version = "6.5.0"),
    class = "version_not_supported"
  )
  expect_error(
    fa_download(version = "8.0.0"),
    class = "version_not_supported"
  )
})

test_that("fa_download returns named list with both font types", {
  mock_fa_download_single <- function(font_type, ...) {
    paste0("mock_path_", font_type, ".otf")
  }

  with_mocked_bindings(
    fa_download_single = mock_fa_download_single,
    {
      result <- fa_download(quiet = TRUE)

      expect_type(result, "list")
      expect_named(result, c("brands", "free_solid"))
      expect_equal(result$brands, "mock_path_brands.otf")
      expect_equal(result$free_solid, "mock_path_free_solid.otf")
    }
  )
})

test_that("fa_download calls fa_download_single twice", {
  call_count <- 0
  font_types <- character()

  mock_fa_download_single <- function(font_type, ...) {
    call_count <<- call_count + 1
    font_types <<- c(font_types, font_type)
    return(paste0("path_", font_type))
  }

  with_mocked_bindings(
    fa_download_single = mock_fa_download_single,
    {
      result <- fa_download(quiet = TRUE)

      expect_equal(call_count, 2)
      expect_equal(sort(font_types), c("brands", "free_solid"))
    }
  )
})

test_that("fa_download passes parameters correctly", {
  captured_params <- list()

  mock_fa_download_single <- function(
    font_type,
    version,
    force_download,
    quiet
  ) {
    captured_params[[font_type]] <<- list(
      version = version,
      force_download = force_download,
      quiet = quiet
    )
    return(NULL)
  }

  with_mocked_bindings(
    fa_download_single = mock_fa_download_single,
    {
      fa_download(version = "7.0.1", force_download = TRUE, quiet = FALSE)

      expect_equal(captured_params$brands$version, "7.0.1")
      expect_equal(captured_params$brands$force_download, TRUE)
      expect_equal(captured_params$brands$quiet, FALSE)

      expect_equal(captured_params$free_solid$version, "7.0.1")
      expect_equal(captured_params$free_solid$force_download, TRUE)
      expect_equal(captured_params$free_solid$quiet, FALSE)
    }
  )
})

test_that("fa_download handles partial failures", {
  mock_fa_download_single <- function(font_type, ...) {
    if (font_type == "brands") {
      return("brands_path.otf")
    } else {
      return(NULL) # Simulate failure
    }
  }

  with_mocked_bindings(
    fa_download_single = mock_fa_download_single,
    {
      result <- fa_download(quiet = TRUE)

      expect_equal(result$brands, "brands_path.otf")
      expect_null(result$free_solid)
    }
  )
})

test_that("fa_download_single parameter validation works", {
  expect_error(
    fa_download_single("invalid_type", "7.0.1", FALSE, TRUE),
    regexp = "Must be element of set"
  )
})

test_that("fa_download_single returns cached file when available", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(
    temp_cache,
    "Font-Awesome-7.0.1-Brands-Regular-400.otf"
  )
  fs::file_create(brands_file)

  with_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    {
      expect_message(
        result <- fa_download_single("brands", "7.0.1", FALSE, FALSE),
        "Font Awesome Brands font already cached"
      )
      expect_equal(result, brands_file)
    }
  )

  fs::dir_delete(temp_cache)
})

test_that("fa_download_single respects quiet parameter", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(
    temp_cache,
    "Font-Awesome-7.0.1-Brands-Regular-400.otf"
  )
  fs::file_create(brands_file)

  with_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    {
      expect_silent(
        result <- fa_download_single("brands", "7.0.1", FALSE, TRUE)
      )
      expect_equal(result, brands_file)
    }
  )

  fs::dir_delete(temp_cache)
})
