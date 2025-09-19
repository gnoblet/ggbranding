test_that("fa_setup parameter validation works", {
  expect_error(fa_setup(auto_download = "yes"), class = "checkmate")
  expect_error(fa_setup(version = "invalid"), class = "checkmate")
  expect_error(fa_setup(version = "1.2"), class = "checkmate")
  expect_error(fa_setup(quiet = 1), class = "checkmate")
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
  with_mocked_bindings(
    sysfonts::font_families = function() {
      c("Font Awesome 7 Brands", "Font Awesome 7 Free Solid", "Arial")
    },
    showtext::showtext_auto = function() NULL,
    {
      expect_message(
        result <- fa_setup(quiet = FALSE),
        "Font Awesome 7 fonts are already loaded"
      )
      expect_true(result)
    }
  )
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

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    sysfonts::font_add = function(...) NULL,
    showtext::showtext_auto = function() NULL,
    {
      expect_message(
        result <- fa_setup(quiet = FALSE),
        "Using cached Font Awesome fonts"
      )
      expect_true(result)
    }
  )

  fs::dir_delete(temp_cache)
})

test_that("fa_setup attempts download when auto_download is TRUE", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  fa_download_called <- FALSE

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      fa_download_called <<- TRUE
      list(
        brands = fs::path(temp_cache, "brands.otf"),
        free_solid = fs::path(temp_cache, "free_solid.otf")
      )
    },
    sysfonts::font_add = function(...) NULL,
    showtext::showtext_auto = function() NULL,
    {
      result <- fa_setup(auto_download = TRUE, quiet = TRUE)
      expect_true(fa_download_called)
      expect_true(result)
    }
  )

  fs::dir_delete(temp_cache)
})

test_that("fa_setup fails gracefully when no fonts available", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) list(brands = NULL, free_solid = NULL),
    {
      expect_message(
        result <- fa_setup(auto_download = TRUE, quiet = FALSE),
        "Font Awesome fonts could not be loaded automatically"
      )
      expect_false(result)
    }
  )

  fs::dir_delete(temp_cache)
})

test_that("fa_setup handles partial font availability", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(temp_cache, "brands.otf")
  fs::file_create(brands_file)

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = NULL)
    },
    sysfonts::font_add = function(...) NULL,
    showtext::showtext_auto = function() NULL,
    {
      result <- fa_setup(auto_download = TRUE, quiet = TRUE)
      expect_true(result) # Should succeed with at least one font
    }
  )

  fs::dir_delete(temp_cache)
})

test_that("fa_setup respects auto_download = FALSE", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  fa_download_called <- FALSE

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      fa_download_called <<- TRUE
      return(NULL)
    },
    {
      result <- fa_setup(auto_download = FALSE, quiet = TRUE)
      expect_false(fa_download_called)
      expect_false(result)
    }
  )

  fs::dir_delete(temp_cache)
})

test_that("fa_setup handles font loading errors gracefully", {
  temp_cache <- fs::file_temp()
  fs::dir_create(temp_cache)

  brands_file <- fs::path(temp_cache, "brands.otf")
  fs::file_create(brands_file)

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = NULL)
    },
    sysfonts::font_add = function(...) stop("Font loading error"),
    {
      expect_warning(
        result <- fa_setup(quiet = TRUE),
        "Failed to load Font Awesome fonts"
      )
      expect_false(result)
    }
  )

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

  with_mocked_bindings(
    sysfonts::font_families = function() character(0),
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = free_solid_file)
    },
    sysfonts::font_add = function(family, ...) {
      font_families_added <<- c(font_families_added, family)
    },
    showtext::showtext_auto = function() NULL,
    {
      result <- fa_setup(quiet = TRUE)
      expect_true(result)
      expect_true("Font Awesome 7 Brands" %in% font_families_added)
      expect_true("Font Awesome 7 Free Solid" %in% font_families_added)
    }
  )

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

  with_mocked_bindings(
    sysfonts::font_families = function() {
      c("Font Awesome 7 Brands") # Only brands already loaded
    },
    get_font_cache_dir = function() temp_cache,
    fa_download = function(...) {
      list(brands = brands_file, free_solid = free_solid_file)
    },
    sysfonts::font_add = function(family, ...) {
      font_add_called <<- TRUE
      expect_equal(family, "Font Awesome 7 Free Solid") # Should only add free_solid
    },
    showtext::showtext_auto = function() NULL,
    {
      result <- fa_setup(quiet = TRUE)
      expect_true(result)
      expect_true(font_add_called) # Should have called font_add for free_solid
    }
  )

  fs::dir_delete(temp_cache)
})
