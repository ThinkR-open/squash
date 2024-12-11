test_that("future settings does not speak for default behaviour", {
  # set to default
  plan("default")

  expect_message(
    object = {
      fetch_future_settings(quiet = FALSE)
    },
    regexp = NA
  )
})

test_that("future settings does not speak for default behaviour", {
  # set a multisession with one worker
  plan(future::multisession, workers = 1)

  expect_message(
    object = {
      fetch_future_settings(quiet = FALSE)
    },
    regexp = "\\{future\\} is using plan\\(future::multisession, workers = 1\\)"
  )

  # reset to default
  plan("default")
})
