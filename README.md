
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {nq1h}: n qmd to 1 html

<!-- badges: start -->
<!-- badges: end -->

The goal of {nq1h} is to compile n .qmd presentations to one single html
file.

The main purpose of this is to create custom slide decks from several
chapter .qmd files.

The resulting html file follows the ThinkR quarto theme:
[thinkr-open/quakr](https://github.com/ThinkR-open/quakr)

![](inst/schemas/schema_readme.png)

## Installation

``` r
if (!requireNamespace("remotes")) {install.packages("remotes")}
if (!requireNamespace("git2r")) {install.packages("git2r")}

options(
  remotes.git_credentials = git2r::cred_user_pass(
    "gitlab-ci-token", 
    Sys.getenv("FORGE_PAT")
  )
)

remotes::install_git(
  "https://forge.thinkr.fr/thinkr/thinkrverse/poc_and_reprex/nq1h", 
  upgrade = "never"
)
```

## External dependencies

This package relies on quarto \> 1.3.

Link to quarto: [download page](https://quarto.org/docs/download/)

## How to use it

``` r
library(nq1h)
```

Given a vector containing path to several .qmd chapters.

``` r
courses_path <- system.file(
  "courses",
  package = "nq1h"
)

qmds <- list.files(
  path = courses_path,
  full.names = TRUE,
  recursive = TRUE,
  pattern = "qmd$"
)

qmds
#> [1] "/tmp/RtmpVw7VtL/temp_libpath1e1fde3ebd140c/nq1h/courses/C01/qmd1_for_test.qmd"
#> [2] "/tmp/RtmpVw7VtL/temp_libpath1e1fde3ebd140c/nq1h/courses/C01/qmd2_for_test.qmd"
#> [3] "/tmp/RtmpVw7VtL/temp_libpath1e1fde3ebd140c/nq1h/courses/C02/qmd3_for_test.qmd"
```

And a directory where you want your course to be generated.

``` r
# generate html in temp folder
temp_dir <- tempfile(pattern = "compile")
```

You can use the function `compile_qmd_course()` to compile a course.

``` r
html_output <- compile_qmd_course(
  vec_qmd_path = qmds,
  output_dir = temp_dir,
  output_html = "complete_course.html"
)
#> • Rendering /tmp/RtmpVw7VtL/temp_libpath1e1fde3ebd140c/nq1h/courses/C01/qmd1_for_test.qmd
#> ✔ qmd1_for_test.qmd rendered successfully
#> • Rendering /tmp/RtmpVw7VtL/temp_libpath1e1fde3ebd140c/nq1h/courses/C01/qmd2_for_test.qmd
#> ✔ qmd2_for_test.qmd rendered successfully
#> • Rendering /tmp/RtmpVw7VtL/temp_libpath1e1fde3ebd140c/nq1h/courses/C02/qmd3_for_test.qmd
#> ✔ qmd3_for_test.qmd rendered successfully
```

Check out the result

``` r
browseURL(html_output)
```

Clean temporary exemple directory.

``` r
# clean up
unlink(temp_dir, recursive = TRUE)
```

## Devs

The project management of this package (issues, milestones etc…) is done
within the
[thinkr/thinkrverse/formation](https://forge.thinkr.fr/thinkr/thinkrverse/formation/)
repo.

The general specifications the pacakge is to meet cna be found here:
[Spécifications Techniques de l’outil de création de
cours](https://www.notion.so/thnkr/Sp-cifications-Techniques-de-l-outil-de-cr-ation-de-cours-52bd760e477c4f64b37a1230c927d386)
