test_that("copy_if_not_already_exist works", {
  tmpdir <- tempfile(pattern = "copy")
  
  output <- copy_if_not_already_exist(
    from = system.file("_extensions","ThinkR-open","thinkridentity", package = "squash"),
    to = file.path(tmpdir, "thinkridentity"),
    copy_type = "dir"
  )
  
  #' @description test that first copy create the dir
  expect_true(dir.exists(output))
  
  #' @description test that second copy does nothing
  expect_message(
    {
      output <- copy_if_not_already_exist(
        from = system.file("_extensions","ThinkR-open","thinkridentity", package = "squash"),
        to = file.path(tmpdir, "thinkridentity"),
        copy_type = "dir"
      )
    },
    regexp = "already present in quarto project"
  )
  expect_null(output)
  
  unlink(tmpdir, recursive = TRUE)
})
