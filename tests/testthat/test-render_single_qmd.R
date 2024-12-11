# create a temp dir with qmd
temp_dir <- tempfile(pattern = "render")

dir.create(
  path = file.path(temp_dir, "img"),
  recursive = TRUE
)

file.copy(
  from = system.file("courses", "M01", "M01S01", "C01-qmd1_for_test.qmd", package = "squash"),
  to = temp_dir
)

file.copy(
  from = system.file("courses", "M01", "M01S01", "img", "logo_1.png", package = "squash"),
  to = file.path(temp_dir, "img")
)


test_that(
  "render_single_qmd return an alert for failed rendering",
  {
    #' @description test cli_message in case of error in rendering
    expect_message(
      object = {
        is_rendered <- render_single_qmd(
          qmd = "a_qmd_that_does_not_exist.qmd"
        )
      },
      regexp = "Failed to render a_qmd_that_does_not_exist.qmd"
    )

    #' @description test output is FALSE for incorrect rendering
    expect_true(isFALSE(is_rendered))
  }
)

test_that(
  "render_single_qmd returns message and html",
  {
    is_rendered <- render_single_qmd(
      qmd = file.path(temp_dir, "C01-qmd1_for_test.qmd"),
      img_root_dir = "img_complete",
      output_format = "revealjs"
    )

    #' @description test output is TRUE for correct rendering
    expect_true(is_rendered)

    #' @description test html output exist
    expect_true(
      file.exists(
        file.path(temp_dir, "C01-qmd1_for_test.html")
      )
    )

    #' @description test image path is correct
    img_path <- list.files(
      path = file.path(temp_dir, "img_complete"),
      recursive = TRUE,
      full.names = TRUE
    )
    expect_true(
      object = grepl(
        pattern = "img_complete\\/render.+_img\\/img\\/logo_1.png",
        x = img_path
      )
    )
  }
)

# clean temp dir
unlink(temp_dir, recursive = TRUE)
