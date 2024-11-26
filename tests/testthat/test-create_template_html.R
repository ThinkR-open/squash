# create temp dir
temp_dir <- tempfile(pattern = "template")

test_that("create_template_html generate an html with proper title and theme", {

  # create html template
  path_to_html_template <- create_template_html(
    path_to_qmd = system.file("template.qmd", package = "squash"),
    output_dir = temp_dir,
    output_file = "complete_course.html"
  )
  
  # list files in extensions
  expect_extension_files <- list.files(
    file.path(temp_dir, "_extensions"),
    recursive = TRUE
  )
  
  # extract html content
  slide_content <- path_to_html_template |>
    read_html() |>
    html_elements(css = ".slides") |>
    html_children()
  slide_id <- slide_content |>
    html_attr(name = "id")
  slide_text <- slide_content |> 
    html_elements("p") |> 
    as.character()
  
  #' @description test dummy extension dir is correctly copied
  expect_setequal(
    object = expect_extension_files,
    expected = c(
      "dummy/_extension.yml",
      "dummy/logo.png",
      "dummy/logo.svg",
      "dummy/dummy.scss"
    )
  )
  
  #' @description test html content of template has correct title and text
  expect_equal(
    object = slide_id,
    expected = c("title-slide", NA, "include_trainer")
  )
  expect_contains(
    object = slide_text,
    expected = c(
      "<p>{{ include_html_content }}</p>",
      "<p><strong>{{ include_phone }}</strong></p>",
      "<p><strong>{{ include_mail }}</strong></p>"
    )
  )
  
})

# clean up
unlink(temp_dir, recursive = TRUE)
