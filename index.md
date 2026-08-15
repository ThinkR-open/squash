# {squash}: several quarto to single html

The goal of {squash} is to compile a single html presentation file from
multiple independent quarto files.

The main purpose of this is to create custom slide decks from several
quarto chapter files.

The resulting revealjs presentation can be themed via quarto extensions.

![A simple schematic view of squash input and
output](reference/figures/simple_scheme.png)

## Installation

You can install the **stable** version from
[GitHub](https://github.com/Thinkr-open/squash) with:

``` r

remotes::install_github("Thinkr-open/squash", ref = "production")
```

You can install the **development** version from
[GitHub](https://github.com/Thinkr-open/squash) with:

``` r

remotes::install_github("Thinkr-open/squash", ref = "main")
```

This package relies on quarto \> 1.3 (see its [download
page](https://quarto.org/docs/download/)).

## Play with {squash}

### TL;DR

Given the vector `qmds` containing paths to one or several qmd revealjs
presentation, you can use the function
[`compile_qmd_course()`](https://thinkr-open.github.io/squash/reference/compile_qmd_course.md)
to compile a full presentation.

``` r

library(squash)

html_output <- compile_qmd_course(
  vec_qmd_path = qmds,
  output_dir = tempdir(),
  output_html = "complete_course.html"
)
```

Check out the result

``` r

browseURL(html_output)
```

### Tutorials

You can find find a full tutorial on how to create your first
{squash}-made html
[here](https://thinkr-open.github.io/squash/articles/simple-example-usage.html).

Eager to spice it up? Take a look at some advanced usage doc :

- using quarto themes and extensions:
  [here](https://thinkr-open.github.io/squash/articles/advanced-usage-theme.html)
- using a personalized template:
  [here](https://thinkr-open.github.io/squash/articles/advanced-usage-template.html)
- using parallel workers with [future](https://future.futureverse.org):
  [here](https://thinkr-open.github.io/squash/articles/advanced-usage-future.html)

### Related tools

Not quite what you were looking for? Here are two closely related quarto
tools :

- exporting as a book instead of a slide deck: [quarto
  book](https://quarto.org/docs/books/)
- including snippets instead of full quarto chapters: [Include
  shortcodes](https://quarto.org/docs/authoring/includes.html)

## Contribute

Ready to help? Take a look at the [contribution
guidelines](https://thinkr-open.github.io/squash/articles/dev-contribute.html).
