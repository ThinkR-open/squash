# list example qmds
courses_path <- system.file(
  "courses",
  package = "squash"
)

# copy course tree in tmpdir
tmp_course_path <- tempfile(pattern = "course")
dir.create(tmp_course_path)
file.create(file.path(tmp_course_path, "_quarto.yaml"))

file.copy(
  from = courses_path,
  to = tmp_course_path,
  recursive = TRUE
)

qmds <- list.files(
  path = tmp_course_path,
  full.names = TRUE,
  recursive = TRUE,
  pattern = "qmd$"
)

# generate html in temp folder
temp_dir <- tempfile(pattern = "compile")

# list files present before rendering (add a dummy one)
file.create(
  file.path(tmp_course_path, "dummy_empty.R")
)

file_present_before_rendering <- list.files(
  path = tmp_course_path,
  full.names = TRUE,
  include.dirs = TRUE,
  recursive = TRUE
)

test_that("compile_qmd_course fails gracefully in case of incorrect inputs", {
  # add path to a html file in list
  qmds_with_missing_path <- c(
    qmds[[1]],
    gsub("\\.qmd", ".html", qmds[[2]])
  )
  
  #' @description test cli_message in case of error in input file type
  compile_qmd_course(
        vec_qmd_path = qmds_with_missing_path,
        output_dir = temp_dir,
        output_html = "complete_course.html"
      ) |> 
    expect_error("Some of the input files are not qmd files.")
})

test_that("compile_qmd_course renders all input courses inside a unique html with default params", {
  
  # run function
  html_output <- compile_qmd_course(
    vec_qmd_path = qmds,
    output_dir = temp_dir,
    output_html = "complete_course.html",
  )
  
  file_present_after_rendering <- list.files(
    path = tmp_course_path,
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE
  )
  
  #' @description test that no remaining output files are present
  expect_setequal(
    object = file_present_after_rendering,
    expected = file_present_before_rendering
  )
  
  #' @description test that output html exists
  expect_true(file.exists(html_output))
 
  slide_content <- html_output |>
    read_html() |>
    html_elements(css = ".slides")
  
  slide_content_by_cat <- purrr::map(.x = c("h1", "h2", "code"), .f = \(x) {
    slide_content |>
      html_elements(x) |>
      rvest::html_text()
  })
  
  #' @description test html content is present
  expect_snapshot(x = slide_content_by_cat)
  
})

test_that("compile_qmd_course renders all input courses inside a unique html output with dummy theme", {
  
  # run function
  html_output <- compile_qmd_course(
    vec_qmd_path = qmds,
    output_dir = temp_dir,
    output_html = "complete_course.html",
    fix_img_path = TRUE,
    output_format = "dummy-revealjs",
    metadata_template = list(
      subtitle = "01/01/01-01/01/01",
      footer = "**<i class='las la-book'></i> A footer**"),
    # remove logo and footer to avoid duplicate from template
    metadata_qmd = list(
      footer = "",
      logo = ""
    ),
    ext_dir = system.file("_extensions", package = "squash")
  )
  
  file_present_after_rendering <- list.files(
    path = tmp_course_path,
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE
  )
  
  #' @description test that no remaining output files are present
  expect_setequal(
    object = file_present_after_rendering,
    expected = file_present_before_rendering
  )

  #' @description test that output html exists
  expect_true(file.exists(html_output))
  
  img_path <- file.path(
    dirname(html_output),
    "complete_course_img",
    c(
      "M01S01_img/img/logo_1.png",
      "M01S01_img/img/logo_2.png",
      "M01S02_img/img/logo_1.png",
      "M02S01-presentations_img/C02-code_files/figure-revealjs/unnamed-chunk-1-1.png",
      "M02S01-presentations_img/C02-code_files/figure-revealjs/unnamed-chunk-2-1.png",
      "M02S01-presentations_img/img/shrimp.png",
      "M02S01-presentations_img/img/worm.jpg",
      "M02S01-presentations_img/img/cow.png",
      "M02S01-presentations_img/img/fish.png"
    )
  )

  expected_md5 <- c(
    "339a6d7488c1bf96613ac202f81a4e0a",
    "e1689186ffbb4a2d181e868fbfc716be",
    "f96ffc2c0beba0a12a0670bce72aef77",
    "7a754636fcf0f2ab12e0049888f9c646",
    "5af0089de8304dd00448d75c83ca87e6",
    "f96ffc2c0beba0a12a0670bce72aef77",
    "e1689186ffbb4a2d181e868fbfc716be"
  )
  
  #' @description test that output image exist
  expect_true(all(file.exists(img_path)))
  
  #' @description test that png images are identical
  png_img_path <- img_path[!grepl(pattern = "unnamed-chunk", x = img_path)]
  expect_equal(
    object = tools::md5sum(png_img_path),
    expected = expected_md5,
    ignore_attr = TRUE
  )
  
  slide_content <- html_output |>
    read_html() |>
    html_elements(css = ".slides")
  
  slide_content_by_cat <- purrr::map(.x = c("h1", "h2", "code"), .f = \(x) {
    slide_content |>
      html_elements(x) |>
      rvest::html_text()
  })
  
  #' @description test that img path from embedded html is correct
  expect_true(grepl("complete_course_img/M01S02_img/img/logo_1.png", slide_content))

  #' @description test html content is present
  expect_snapshot(x = slide_content_by_cat)

})

test_that("compile_qmd_course HTML preview looks ok", {
  
  # manual check on interactive mode only
  skip_if_not(interactive())
  take_a_look <- yesno::yesno2("\nReady to look at the html preview ?")
  
  if (isTRUE(take_a_look)) {
    cat("Buckle up, html will open in a new pane, come back to this session for validation")
    Sys.sleep(3)
    browseURL(file.path(temp_dir, "complete_course.html"))
    
    questions <- c(
      "\nYou have 5 chapters ?",
      "\nMain titles are centered and orange ? Chapter names are blue ?",
      "\nImage and code chunk appear properly ?",
      "\nGraphics are visible ?",
      "\nTable is visible ?"
      )
    
    answers <- sapply(
      X = questions,
      FUN = yesno::yesno2
      )
    
    cat("\nThank you :) resuming tests\n")
    
    #' @description testing all visual checks are ok from user answers
    expect_true(all(answers))
  }
})

test_that("compile_qmd_course works with non-default parameters", {

  # run function with other template and parameters
  html_output <- compile_qmd_course(
    vec_qmd_path = qmds[1],
    output_dir = temp_dir,
    output_html = "formation_R.html",
    template = system.file("template.qmd", package = "squash"),
    title = "Trouloulou",
    metadata_template = testthat::test_path("_yamls", "metadata.yml"),
    metadata_qmd = list(
      footer = "imafooter"
    ),
    template_text = list(
      trainer = "Tralala",
      mail = "Trili@li",
      phone = "+33 6 66 66 66 66"
    )
  )
  
  #' @description test output has expected name
  expect_true(
    file.exists(
      file.path(temp_dir, "formation_R.html")
    )
  )
  
  first_slide_content <- html_output |>
    read_html() |>
    html_elements(css = ".slides") |>
    html_children() |>
    _[[1]] |> 
    as.character()
  
  #' @description test non-default info are well inserted in template 1st slide
  expect_snapshot(x = first_slide_content)
  
  last_slide_content <- html_output |>
    read_html() |>
    html_elements(css = ".slides") |>
    html_children() |>
    _[[3]] |> 
    as.character()
  
  #' @description test non-default info are well inserted in template last slide
  expect_snapshot(x = last_slide_content)
  
  file_present_after_rendering <- list.files(
    path = tmp_course_path,
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE
  )
  
  #' @description test that no remaining output files are present
  expect_setequal(
    object = file_present_after_rendering,
    expected = file_present_before_rendering
  )
  
})

test_that("compile_qmd_course clean after exit for qmd with failed rendering", {
  
  # add a qmd that will failed mid-way
  qmd_with_stop <- file.path(
    tmp_course_path,
    "courses",
    "M02",
    "M02S01-presentations",
    "C03-qmd-with-stop.qmd"
  )
  
  file.copy(
    from = testthat::test_path("_qmds", "C03-qmd-with-stop.qmd"),
    to = qmd_with_stop
  )
  
  # run function
  expect_message(
    object = {
      html_output <- compile_qmd_course(
        vec_qmd_path = c(qmds[1:2], qmd_with_stop),
        output_dir = temp_dir,
        output_html = "complete_course.html"
      )
    },
    regexp = paste0("Fail to render .* cleaning and existing")
  )
  
  file_present_after_rendering <- list.files(
    path = tmp_course_path,
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE
  )
  
  #' @description test that no remaining output files are present
  expect_setequal(
    object = file_present_after_rendering,
    expected = c(file_present_before_rendering, qmd_with_stop)
  )
})

test_that("compile_qmd_course account for qmd with no media output dir", {
  
  # add a qmd that has no media (plot / img)
  qmd_with_no_media <- file.path(
    tmp_course_path,
    "courses",
    "M03",
    "M03S01-qmd-no-media",
    "C01-qmd1_for_test_with_no_media.qmd"
  )
  dir.create(dirname(qmd_with_no_media), recursive = TRUE)
  
  file.copy(
    from = testthat::test_path("_qmds", "C01-qmd1_for_test_with_no_media.qmd"),
    to = qmd_with_no_media
  )
  
  # run function
  expect_warning(
    object = {
      html_output <- compile_qmd_course(
        vec_qmd_path = c(qmds[1:2], qmd_with_no_media),
        output_dir = temp_dir,
        output_html = "complete_course.html"
      )
    },
    regexp = NA
  )
  
  #' @description test that no img dir is present for qmd with no media
  expect_false(
    dir.exists(
      file.path(temp_dir, "complete_course_img", "M03S01-qmd-no-media")
    )
  )
  
})

# clean up
unlink(temp_dir, recursive = TRUE)
unlink(tmp_course_path, recursive = TRUE)
