# Load required packages for mocking
library(sysfonts)
library(showtext)

test_that("fa_setup parameter validation works", {
  expect_error(
    fa_setup(auto_download = "yes"),
    regexp = "Must be of type 'logical"
  )
  expect_error(fa_setup(version = "invalid"), regexp = "Must comply to pattern")
  expect_error(fa_setup(version = "1.2"), regexp = "Must comply to pattern")
  expect_error(fa_setup(quiet = 1), regexp = "Must be of type 'logical")
})

test_that("fa_setup only supports version 7.0.1", {
  expect_error(
    fa_setup(version = "6.5.0"),
    class = "version_not_supported"
  )
  expect_error(
    fa_setup(version = "8.0.0"),
    class = "version_not_supported"
  )
})

test_that("fa_setup returns TRUE when fonts already loaded", {
  local_mocked_bindings(
    font_families = function() {
      c("Font Awesome 7 Brands", "Font Awesome 7 Free Solid", "Arial")
    },
    .package = "sysfonts"
  )
  local_mocked_bindings(
    showtext_auto = function() NULL,
    .package = "showtext"
  )

  expect_message(
    result <- fa_setup(quiet = FALSE),
    "Font Awesome 7 fonts are already loaded"
  )
  expect_true(result)
})

test_that("fa_setup handles cached fonts correctly", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  # Create cached font files
  brands_file <- fs::path(
    temp_cache,
    "Font-Awesome-7.0.1-Brands-Regular-400.otf"
  )
  free_solid_file <- fs::path(
    temp_cache,
    "Font-Awesome-7.0.1-Free-Solid-900.otf"
  )
  fs::file_create(brands_file)
  fs::file_create(free_solid_file)

  local_mocked_bindings(
    font_families = function() character(0),
    font_add = function(...) NULL,
    .package = "sysfonts"
  )
  local_mocked_bindings(
    showtext_auto = function() NULL,
    .package = "showtext"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache
  )

  expect_message(
    result <- fa_setup(quiet = FALSE),
    "Using cached Font Awesome fonts"
  )
  expect_true(result)

  fs::dir_delete(temp_cache)
})

test_that("fa_setup attempts download when auto_download is TRUE", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  fa_download_called <- FALSE

  local_mocked_bindings(
    font_families = function() character(0),
    font_add = function(...) NULL,
    .package = "sysfonts"
  )
  local_mocked_bindings(
    showtext_auto = function() NULL,
    .package = "showtext"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      fa_download_called <<- TRUE
      list(
        brands = fs::path(temp_cache, "brands.otf"),
        free_solid = fs::path(temp_cache, "free_solid.otf")
      )
    }
  )

  result <- fa_setup(auto_download = TRUE, quiet = TRUE)
  expect_true(fa_download_called)
  expect_true(result)

  fs::dir_delete(temp_cache)
})

test_that("fa_setup fails gracefully when no fonts available", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  local_mocked_bindings(
    font_families = function() character(0),
    .package = "sysfonts"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) list(brands = NULL, free_solid = NULL)
  )

  expect_message(
    result <- fa_setup(auto_download = TRUE, quiet = FALSE),
    "Font Awesome fonts could not be loaded automatically"
  )
  expect_false(result)

  fs::dir_delete(temp_cache)
})

test_that("fa_setup handles partial font availability", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(temp_cache, "brands.otf")
  fs::file_create(brands_file)

  local_mocked_bindings(
    font_families = function() character(0),
    font_add = function(...) NULL,
    .package = "sysfonts"
  )
  local_mocked_bindings(
    showtext_auto = function() NULL,
    .package = "showtext"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = NULL)
    }
  )

  result <- fa_setup(auto_download = TRUE, quiet = TRUE)
  expect_true(result) # Should succeed with at least one font

  fs::dir_delete(temp_cache)
})

test_that("fa_setup respects auto_download = FALSE", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  fa_download_called <- FALSE

  local_mocked_bindings(
    font_families = function() character(0),
    .package = "sysfonts"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      fa_download_called <<- TRUE
      return(NULL)
    }
  )

  result <- fa_setup(auto_download = FALSE, quiet = TRUE)
  expect_false(fa_download_called)
  expect_false(result)

  fs::dir_delete(temp_cache)
})

test_that("fa_setup handles font loading errors gracefully", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(temp_cache, "brands.otf")
  fs::file_create(brands_file)

  local_mocked_bindings(
    font_families = function() character(0),
    font_add = function(...) stop("Font loading error"),
    .package = "sysfonts"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = NULL)
    }
  )

  expect_warning(
    result <- fa_setup(quiet = TRUE),
    "Failed to load Font Awesome fonts"
  )
  expect_false(result)

  fs::dir_delete(temp_cache)
})

test_that("fa_setup loads both font types when available", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(temp_cache, "brands.otf")
  free_solid_file <- fs::path(temp_cache, "free_solid.otf")
  fs::file_create(brands_file)
  fs::file_create(free_solid_file)

  font_families_added <- character()

  local_mocked_bindings(
    font_families = function() character(0),
    font_add = function(family, ...) {
      font_families_added <<- c(font_families_added, family)
    },
    .package = "sysfonts"
  )
  local_mocked_bindings(
    showtext_auto = function() NULL,
    .package = "showtext"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = free_solid_file)
    }
  )

  result <- fa_setup(quiet = TRUE)
  expect_true(result)
  expect_true("Font Awesome 7 Brands" %in% font_families_added)
  expect_true("Font Awesome 7 Free Solid" %in% font_families_added)

  fs::dir_delete(temp_cache)
})

test_that("fa_setup skips loading already loaded fonts", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(temp_cache, "brands.otf")
  free_solid_file <- fs::path(temp_cache, "free_solid.otf")
  fs::file_create(brands_file)
  fs::file_create(free_solid_file)

  font_add_called <- FALSE

  local_mocked_bindings(
    font_families = function() {
      c("Font Awesome 7 Brands") # Only brands already loaded
    },
    font_add = function(family, ...) {
      font_add_called <<- TRUE
      expect_equal(family, "Font Awesome 7 Free Solid") # Should only add free_solid
    },
    .package = "sysfonts"
  )
  local_mocked_bindings(
    showtext_auto = function() NULL,
    .package = "showtext"
  )
  local_mocked_bindings(
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = free_solid_file)
    }
  )

  result <- fa_setup(quiet = TRUE)
  expect_true(result)
  expect_true(font_add_called) # Should have called font_add for free_solid

  fs::dir_delete(temp_cache)
})
