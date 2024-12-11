test_that("check_quarto_version warns user with invalid quarto version", {
  expect_error(
    object = {
      with_mocked_bindings(
        quarto_version = function(...) {
          "1.0.0"
        },
        code = {
          check_quarto_version()
        }
      )
    },
    regexp = "minimal required version is 1.3.0"
  )
})
