library(RJSONIO)

context("authenticate")

test_that("empty parameter list", {
  credentials = as.list(readJSONStream("../../myfxbook-login.json"))
  fx <- myfxbook$new(email = credentials$username, password = credentials$password, debug = FALSE)
  expect_equal(nchar(fx$session), 26)
})
