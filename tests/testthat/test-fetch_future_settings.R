test_that("fetch_future_settings quiet TRUE vs FALSE", {
  oplan <- plan("default")
  on.exit(plan(oplan), add = TRUE)
  expect_message(
    object = {
      fetch_future_settings(FALSE)
    },
    regexp = NA
  )
})

test_that("fetch_future_settings speak when future::multisession", {
  oplan <- plan(future::multisession, workers = 1)
  on.exit(plan(oplan), add = TRUE)
  expect_message(
    object = {
      fetch_future_settings(quiet = FALSE)
    },
    regexp = "\\{future\\} is using plan\\(future::multisession, workers = 1\\)"
  )
})
