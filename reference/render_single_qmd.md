# Render a qmd course to html

Render a single qmd file to html with image folder.

## Usage

``` r
render_single_qmd(
  qmd,
  img_root_dir = "img",
  output_format = "revealjs",
  metadata = NULL,
  quiet = TRUE,
  purrr_insistently_rate_backoff = purrr::rate_backoff(pause_base = 0.1, max_times = 5),
  isolate = getOption("squash.isolate_render", TRUE)
)
```

## Arguments

- qmd:

  character. Path to the qmd file to render

- img_root_dir:

  character. Path to the main image folder to extract media to

- output_format:

  character. Output format of the qmd, default to "revealjs". Can be
  adapted for specific themes.

- metadata:

  list. List of metadata to be used for rendering single qmd file

- quiet:

  logical. Output info in user console

- purrr_insistently_rate_backoff:

  function. Function to use to retry rendering qmd files in case of
  failure. Should be a purrr::rate_backoff function.

- isolate:

  logical. If TRUE (default, controlled by option
  "squash.isolate_render"), render inside a throwaway copy of the quarto
  project so concurrent renders do not share project state. Outputs are
  copied back to the real chapter afterwards. When isolation is not
  possible (no quarto project above the qmd, project with a
  project-level output-dir, filesystem without symlink support), the qmd
  is rendered in place as before.

## Value

logical. TRUE if rendering succeeded, FALSE otherwise. Side effect :
render qmd as html

## Examples

``` r
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
#> [1] TRUE

file.copy(
  from = system.file("courses", "M01", "M01S01", "img", "logo_1.png", package = "squash"),
  to = file.path(temp_dir, "img")
)
#> [1] TRUE

# render qmd
is_rendered <- render_single_qmd(
  qmd = file.path(temp_dir, "C01-qmd1_for_test.qmd"),
  img_root_dir = file.path(temp_dir, "image_folder")
)

# clean temp dir
unlink(temp_dir, recursive = TRUE)
```
