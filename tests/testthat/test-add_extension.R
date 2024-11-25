test_that("add_extension works", {
  # add two qmd in a tmp dir, one with yaml project
  tmpdir <- tempfile(pattern = "addcompil")
  dir.create(file.path(tmpdir, "tmpsubfolder1"), recursive = TRUE)
  dir.create(file.path(tmpdir, "tmpsubfolder2"), recursive = TRUE)
  
  vec_qmd_path <- c(
    file.path(tmpdir, "tmpsubfolder1", "dummy1.qmd"),
    file.path(tmpdir, "tmpsubfolder2", "dummy2.qmd")
  )
  
  file.create(vec_qmd_path)

  #' @description test function add extension next to qmd if not project detected
  new_proj_files <- add_extension(vec_qmd_path = vec_qmd_path, quiet = FALSE)

  expect_true(all(dir.exists(new_proj_files)))
  
  # add quarto project
  file.create(
    file.path(tmpdir, "_quarto.yaml")
  )
  
  #' @description test function add extension in project root
  new_proj_files <- add_extension(vec_qmd_path = vec_qmd_path, quiet = FALSE)
  
  #' @description test project files are created if not pre existing
  expect_true(dir.exists(new_proj_files))
  
  #' @description test user message are sent for compil and quakr theme
  expect_message(
    {new_proj_files <- add_extension(vec_qmd_path = vec_qmd_path, quiet = FALSE)},
    regexp = "Using it for compil."
  )
  
  #' @description test project files are not created if pre-existing
  expect_equal(object = new_proj_files, expected = c("NULL"))
  
  # cleanup
  unlink(tmpdir, recursive = TRUE)
})
