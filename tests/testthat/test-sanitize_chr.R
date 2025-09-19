test_that("sanitize_chr handles basic character sanitization", {
  # Test email addresses
  expect_equal(
    sanitize_chr("contact@example.com"),
    "contact@\u200Bexample.com"
  )

  # Test URLs with forward slashes
  expect_equal(
    sanitize_chr("https://example.com/path"),
    "https:/\u200B/\u200Bexample.com/\u200Bpath"
  )

  # Test HTML-like characters
  expect_equal(
    sanitize_chr("text<tag>content"),
    "text<\u200Btag>\u200Bcontent"
  )
})

test_that("sanitize_chr handles edge cases", {
  # Test NULL input
  expect_error(sanitize_chr(NULL))

  # Test NA values
  expect_true(is.na(sanitize_chr(NA_character_)))

  # Test empty string
  expect_equal(sanitize_chr(""), "")

  # Test string with no problematic characters
  expect_equal(sanitize_chr("normal text"), "normal text")
})

test_that("sanitize_chr handles character vectors", {
  input <- c("user@domain.com", "https://site.com/page", "normal text")
  expected <- c(
    "user@\u200Bdomain.com",
    "https:/\u200B/\u200Bsite.com/\u200Bpage",
    "normal text"
  )
  expect_equal(sanitize_chr(input), expected)
})

test_that("sanitize_chr handles mixed NA and valid values", {
  input <- c("user@domain.com", NA_character_, "https://site.com")
  result <- sanitize_chr(input)

  expect_equal(result[1], "user@\u200Bdomain.com")
  expect_true(is.na(result[2]))
  expect_equal(result[3], "https:/\u200B/\u200Bsite.com")
})

test_that("sanitize_chr handles multiple problematic characters in one string", {
  # String with multiple @ and / characters
  input <- "email@domain.com/path@server/file"
  expected <- "email@\u200Bdomain.com/\u200Bpath@\u200Bserver/\u200Bfile"
  expect_equal(sanitize_chr(input), expected)

  # String with all problematic characters
  input <- "test@example.com/path<tag>content"
  expected <- "test@\u200Bexample.com/\u200Bpath<\u200Btag>\u200Bcontent"
  expect_equal(sanitize_chr(input), expected)
})

test_that("sanitize_chr parameter validation works", {
  # Test non-character input
  expect_error(sanitize_chr(123), regexp = "Must be of type 'character'")
  expect_error(
    sanitize_chr(list("test")),
    regexp = "Must be of type 'character'"
  )
  expect_error(sanitize_chr(TRUE), regexp = "Must be of type 'character'")
})

test_that("sanitize_chr preserves character vector names", {
  input <- c(github = "user@domain.com", website = "https://site.com")
  result <- sanitize_chr(input)

  expect_equal(names(result), c("github", "website"))
  expect_equal(result[["github"]], "user@\u200Bdomain.com")
  expect_equal(result[["website"]], "https:/\u200B/\u200Bsite.com")
})

test_that("sanitize_chr handles repeated patterns correctly", {
  # Multiple consecutive problematic characters
  expect_equal(
    sanitize_chr("test@@example.com"),
    "test@\u200B@\u200Bexample.com"
  )

  expect_equal(
    sanitize_chr("path//to//file"),
    "path/\u200B/\u200Bto/\u200B/\u200Bfile"
  )

  expect_equal(
    sanitize_chr("<<tag>>"),
    "<\u200B<\u200Btag>\u200B>\u200B"
  )
})
