# Create a single html from multiple qmd

Independently compile several qmd and create a common html

## Usage

``` r
compile_qmd_course(
  vec_qmd_path,
  output_dir,
  output_html,
  template = system.file("template_minimal.qmd", package = "squash"),
  output_format = "revealjs",
  title = "Title",
  metadata_template = NULL,
  metadata_qmd = NULL,
  template_text = NULL,
  ext_dir = NULL,
  quiet = FALSE,
  debug = FALSE,
  fix_img_path = TRUE,
  render_pdf = FALSE,
  render_pdf_fun = pagedown::chrome_print,
  render_qmd_purrr_insistently_rate_backoff = purrr::rate_backoff(pause_base = 0.1,
    max_times = 5)
)
```

## Arguments

- vec_qmd_path:

  character. Vector of the path to qmd files

- output_dir:

  character. Output path to store html files and companion folders

- output_html:

  character. File name of the complete html output saved

- template:

  character. Path to the template qmd to use. Content will be included
  at the positions inside double-brackets

- output_format:

  character. Output format of the qmd, default to "revealjs". Can be
  adapted for specific themes.

- title:

  character. Title of the presentation

- metadata_template:

  list. List of metadata used for rendering template. If a path to a yml
  file is provided, metadata will be read from this file.

- metadata_qmd:

  list. List of metadata used for rendering individual qmd files. If a
  path to a yml file is provided, metadata will be read from this file.

- template_text:

  list. List of named elements to include in the template.

- ext_dir:

  character. Path to the \_extensions directory to use when compiling
  qmd

- quiet:

  logical. Output info in user console

- debug:

  logical. Output rendering output in user console.

- fix_img_path:

  logical. If image path are present as raw html inside files, use this
  option to correctly edit their path.

- render_pdf:

  logical. If TRUE, render a pdf version of the html file

- render_pdf_fun:

  function. Function to use to render the pdf. Default to
  pagedown::chrome_print. The function need to take a path to a html
  file as input.

- render_qmd_purrr_insistently_rate_backoff:

  function. Function to use to retry rendering qmd files in case of
  failure. Should be a purrr::rate_backoff function.

## Value

character. The path to the resulting html file

## Examples

``` r
library(future)

# set parallel rendering
plan(multisession, workers = 2)

# list example qmds
courses_path <- system.file(
  "courses",
  "M01",
  package = "squash"
)

# copy course tree in tmpdir, add quarto porject file
tmp_course_path <- tempfile(pattern = "course")
dir.create(tmp_course_path)
file.create(file.path(tmp_course_path, "_quarto.yaml"))
#> [1] TRUE

file.copy(
  from = courses_path,
  to = tmp_course_path,
  recursive = TRUE
)
#> [1] TRUE

qmds <- list.files(
  path = tmp_course_path,
  full.names = TRUE,
  recursive = TRUE,
  pattern = "qmd$"
)

# generate html in temp folder
temp_dir <- tempfile(pattern = "compile")

html_output <- compile_qmd_course(
  vec_qmd_path = qmds,
  output_dir = temp_dir,
  output_html = "complete_course.html"
)
#> ℹ {future} is using plan(multisession, workers = 2), to modify this use `future::plan()`
#> ✔ All qmd rendered.

# reset default rendering
plan("default")

# clean up
unlink(temp_dir, recursive = TRUE)
unlink(tmp_course_path, recursive = TRUE)
```
