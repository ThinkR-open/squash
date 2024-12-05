
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {squash}: several quarto to single html <img src="man/figures/logo.png" align="right" height="138" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/ThinkR-open/squash/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ThinkR-open/squash/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ThinkR-open/squash/graph/badge.svg)](https://app.codecov.io/gh/ThinkR-open/squash)
<!-- badges: end -->

The goal of {squash} is to compile n .qmd presentations to one single
html file.

The main purpose of this is to create custom slide decks from several
chapter .qmd files.

The resulting html file can be themed via quarto extensions.

## Installation

## External dependencies

This package relies on quarto \> 1.3.

Link to quarto: [download page](https://quarto.org/docs/download/)

## How to use it

``` r
library(squash)
```

Given a vector containing path to several .qmd chapters.

``` r
# list example qmds from /inst
courses_path <- system.file(
  "courses",
  "M01",
  package = "squash"
)

# copy example qmds in a tempdir
tmp_course_path <- tempfile(pattern = "course")
dir.create(tmp_course_path)

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

qmds
```

And a directory where you want your course to be generated.

``` r
# generate html in temp folder
temp_dir <- tempfile(pattern = "compile")
```

You can use the function `compile_qmd_course()` to compile a course.

> We wrap the function call inside a `progressr::with_progress()` to see
> the progress bar. You can also set it in the console with
> `progressr::handlers(global = TRUE)`

``` r
html_output <- progressr::with_progress(
  compile_qmd_course(
    vec_qmd_path = qmds,
    output_dir = temp_dir,
    output_html = "complete_course.html"
  )
)
```

Check out the result

``` r
browseURL(html_output)
```

Clean temporary example directory.

``` r
unlink(temp_dir, recursive = TRUE)
unlink(tmp_course_path, recursive = TRUE)
```

## Devs

### Check

Some tests manually verify the appearance of the slides. To trigger
them, please run `devtools::test()` interactively.
