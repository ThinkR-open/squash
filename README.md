
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {nq1h} n qmd to 1 html

<!-- badges: start -->
<!-- badges: end -->

The goal of {nq1h} is to compile n .qmd (under format revealjs) to one
single html file.

Contrary to
[thinkrverse/poc_and_reprex/multi_quarto_to_one_reveal](https://forge.thinkr.fr/thinkr/thinkrverse/poc_and_reprex/multi_quarto_to_one_reveal),
this version :

- does not rely on `npm`
- encapsulate the mechanism within an R pacakage

## POC

Render all qmds to html.

``` r
# list example qmds
courses_path <- system.file(
  "courses",
  package = "nq1h"
)

qmds <- list.files(
  path = courses_path,
  full.names = TRUE,
  pattern = "qmd$"
)

# generate html in temp folder
temp_dir <- tempfile(pattern = "compile")

html_output <- compile_qmd_course(
  vec_qmd_path = qmds,
  output_dir = temp_dir,
  output_html = "course_complete.html"
)
```

``` r
# view html
browseURL(html_output)
```

The images rendered in the final html are stored in sub-folders based on
their folder of origin to avoid erasing images with identical names.

The reveal dependencies are stored in a companion folder.

``` r
# list image folder
fs::dir_tree(
  path = file.path(
    dirname(html_output),
    "course_complete_img"
  )
)

# list dependencies folder
fs::dir_tree(
  path = file.path(
    dirname(html_output),
    "course_complete_files"
  )
)

# clean up
unlink(temp_dir, recursive = TRUE)
```
