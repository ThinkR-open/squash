# Create a themed html from a qmd template

Create a template html

## Usage

``` r
create_template_html(
  path_to_qmd,
  output_file,
  output_dir,
  output_format = "revealjs",
  title = "Title",
  metadata = NULL,
  temp_dir = tempfile(pattern = "template"),
  ext_dir = system.file("_extensions", package = "squash")
)
```

## Arguments

- path_to_qmd:

  character. Path to the qmd template to be rendered

- output_file:

  character. Name of the output html template

- output_dir:

  character. Output path to store html files and companion folders

- output_format:

  character. Output format of the qmd, default to "revealjs". Can be
  adapted for specific themes.

- title:

  character. Title of the presentation

- metadata:

  list. List of metadata to be used for rendering template

- temp_dir:

  character. Path to the temp_dir where template will be rendered

- ext_dir:

  character. Path to the \_extensions directory to use when compiling
  qmd

## Value

character. Path to the html template

## Examples

``` r
# create temp dir
temp_dir <- tempfile(pattern = "template")

# create html template
path_to_html_template <- create_template_html(
  path_to_qmd = system.file("template.qmd", package = "squash"),
  output_dir = temp_dir,
  output_file = "complete_course.html"
)

# clean up
unlink(temp_dir, recursive = TRUE)
```
