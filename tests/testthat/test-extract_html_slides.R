# create temp dir
temp_dir <- tempfile(pattern = "template")
dir.create(temp_dir)

# copy qmd in tmp
squash_path <- system.file(package = "squash")

files_to_copy <- c(
  file.path(
    squash_path,
    c("_extensions",
      file.path("courses", "M01"),
      "_quarto.yaml",
      "_quarto-render.yml")
  )
)

file.copy(
  from = files_to_copy,
  to = temp_dir,
  recursive = TRUE
)

# render all course qmd in quarto project with default profile
# remove as_job to not run as background jobs
quarto::quarto_render(
  input = temp_dir,
  quiet = TRUE,
  as_job = FALSE
)

# list created html
htmls <- list.files(
  path = temp_dir,
  pattern = "qmd[0-9]_for_test\\.html$",
  recursive = TRUE,
  full.names = TRUE
)
  
test_that("extract_html_slides returns all html slide classes in correct order", {
  
  # run function with slide order 1-2-3
  html_slide_content <- extract_html_slides(
    vec_html_path = htmls,
    use_metadata = TRUE
  )
  
  #' @description test with three html files in order 1-2-3
  section_title <- html_slide_content |>
    read_html() |>
    html_elements(css = "section") |>
    html_attr("id")
  expect_equal(
    object = section_title,
    expected = c(
      "M01S01-1",
      "1-slide-with-code",
      "1-slide-with-speaker-note",
      "1-slide-with-image",
      "title-slide-2",
      "2-slide-with-side-by-side-image-layout",
      "2-slide-with-side-by-side-image-columns",
      "2-slide-with-side-by-side-chunk-layout",
      "2-slide-with-side-by-side-chunk-columns",
      "M01S02-1",
      "3-slide-with-text",
      "3-slide-with-text-1",
      "3-slide-with-image"
    )
  )
  
  # run function with slide order 2-1-3
  html_slide_content_reordered <- extract_html_slides(
    vec_html_path = htmls[c(2, 1, 3)],
    use_metadata = TRUE
  )
  
  #' @description test with three htmls in order 2-1-3
  section_title_reordered <- html_slide_content_reordered |>
    read_html() |>
    html_elements(css = "section") |>
    html_attr("id")
  expect_equal(
    object = section_title_reordered,
    expected = c(
      "title-slide-1",
      "1-slide-with-side-by-side-image-layout",
      "1-slide-with-side-by-side-image-columns",
      "1-slide-with-side-by-side-chunk-layout",
      "1-slide-with-side-by-side-chunk-columns",
      "M01S01-1",
      "2-slide-with-code",
      "2-slide-with-speaker-note",
      "2-slide-with-image",
      "M01S02-1",
      "3-slide-with-text",
      "3-slide-with-text-1",
      "3-slide-with-image"
    )
  )
})

# clean up
unlink(temp_dir, recursive = TRUE)
