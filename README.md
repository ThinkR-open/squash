
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {squash}: several quarto to single html

<!-- badges: start -->

[![R build
status](https://forge.thinkr.fr/thinkr/thinkrverse/squash/badges/main/pipeline.svg)](https://forge.thinkr.fr/thinkr/thinkrverse/squash/-/pipelines)
[![Codecov test
coverage](https://forge.thinkr.fr/thinkr/thinkrverse/squash/badges/main/coverage.svg)](https://forge.thinkr.fr/thinkr/thinkrverse/squash/commits/main)
<!-- badges: end -->

The goal of {squash} is to compile n .qmd presentations to one single
html file.

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
  "https://forge.thinkr.fr/thinkr/thinkrverse/squash", 
  upgrade = "never"
)
```

## External dependencies

This package relies on quarto \> 1.3.

Link to quarto: [download page](https://quarto.org/docs/download/)

## How to use it

``` r
library(squash)
```

Given a vector containing path to several .qmd chapters.

``` r
courses_path <- system.file(
  "courses",
  package = "squash"
)

qmds <- list.files(
  path = courses_path,
  full.names = TRUE,
  recursive = TRUE,
  pattern = "qmd$"
)

qmds
#> [1] "/home/swann/R/x86_64-pc-linux-gnu-library/4.3/squash/courses/C01/qmd1_for_test.qmd"
#> [2] "/home/swann/R/x86_64-pc-linux-gnu-library/4.3/squash/courses/C01/qmd2_for_test.qmd"
#> [3] "/home/swann/R/x86_64-pc-linux-gnu-library/4.3/squash/courses/C02/qmd3_for_test.qmd"
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
#> ℹ {future} is using plan("default"), to modify this use `future::plan()`
#> ℹ Rendering /home/swann/R/x86_64-pc-linux-gnu-library/4.3/squash/courses/C01/qmd1_for_test.qmd
#> ✔ qmd1_for_test.qmd rendered successfully
#> ℹ Rendering /home/swann/R/x86_64-pc-linux-gnu-library/4.3/squash/courses/C01/qmd2_for_test.qmd
#> ✔ qmd2_for_test.qmd rendered successfully
#> ℹ Rendering /home/swann/R/x86_64-pc-linux-gnu-library/4.3/squash/courses/C02/qmd3_for_test.qmd
#> ✔ qmd3_for_test.qmd rendered successfully
```

Check out the result

``` r
browseURL(html_output)
```

Clean temporary example directory.

``` r
unlink(temp_dir, recursive = TRUE)
```

## Devs

### Project Management

The project management of this package (milestones etc…) is done on the
[squash notion
page](https://www.notion.so/thnkr/squash-f2d050e0c1484ecab69d044cc7bf201c?pvs=4).

### Keeping ThinkR quarto theme up-to-date

This package is harboring another project
[quakr](https://github.com/ThinkR-open/quakr) which is the ThinkR theme
for the quarto revealjs format.

It is not a R package but a quarto extension stored in `inst/`.

It should be kept in sync with the main branch of
<https://github.com/ThinkR-open/quakr> to insure that {squash} is always
shipped with the latest release of quakr.

#### Automatic sync check

There is a built-in fail-safe function `.check_if_quakr_up_to_date()` in
the project `.Rprofile`.

Every time a dev open the project `.check_if_quakr_up_to_date`:

- downloads the the latest version of quakr in a temp directory
- checks it against the current version within the package
- informs the dev if quakr needs to be updated

#### Updating quakr

quakr needs to be updated via the quarto cli.

First, you need to be in the package `inst/` directory where the
extension is stored

``` bash
cd inst/
```

Run the `quarto update` command and answer `yes` to all questions

``` bash
quarto update ThinkR-open/quakr
```

If you want to update quakr using a specific branch, use `@` to specifiy
which branch you would like to use. For example:

``` bash
quarto update ThinkR-open/quakr@dev
```

In that case you will also need to provide thebranch name to
`.check_if_quakr_up_to_date()` in the .Rprofile as such
`.check_if_quakr_up_to_date(branch = "dev")` not to be bothered by
useless warnings.

Lastly, don’t forget to get back to the package directory

``` bash
cd ..
```
