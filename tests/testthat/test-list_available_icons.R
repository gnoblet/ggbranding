test_that("list_available_icons parameter validation works", {
  expect_error(list_available_icons(search = ""))
  expect_error(list_available_icons(show_unicode = "yes"))
  expect_error(list_available_icons(show_styles = 1))
})

test_that("list_available_icons returns proper data frame", {
  result <- list_available_icons()

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("name" %in% colnames(result))
  expect_true("label" %in% colnames(result))
})

test_that("list_available_icons search works", {
  result <- list_available_icons(search = "github")
  expect_s3_class(result, "data.frame")
  expect_true(any(grepl("github", tolower(result$name))))
})

test_that("list_available_icons handles no results", {
  expect_message(
    result <- list_available_icons(search = "nonexistenticon"),
    "No icons found"
  )
  expect_equal(nrow(result), 0)
})

test_that("list_available_icons show_unicode parameter works", {
  result_default <- list_available_icons(search = "github")
  result_unicode <- list_available_icons(search = "github", show_unicode = TRUE)

  expect_false("unicode_full" %in% colnames(result_default))
  expect_true("unicode_full" %in% colnames(result_unicode))
})

test_that("list_available_icons show_styles parameter works", {
  result_default <- list_available_icons(search = "github")
  result_styles <- list_available_icons(search = "github", show_styles = TRUE)

  expect_false("styles" %in% colnames(result_default))
  expect_true("styles" %in% colnames(result_styles))
})
