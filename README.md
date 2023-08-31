
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {nq1h} n qmd to 1 html

<!-- badges: start -->
<!-- badges: end -->

The goal of {nq1h} is to compile n .qmd (under format revealjs) to one
single html file.

## POC

Render all qmds to html.

``` r
courses_path <- "inst/courses"

vec_qmd_path <- list.files(
  path = courses_path, 
  full.names = TRUE, 
  pattern = "qmd$"
)


for (qmd in vec_qmd_path){
  cli::cat_bullet(
    sprintf("Rendering %s", basename(qmd))
  )
  quarto::quarto_render(
    input = qmd,
    quiet = TRUE
  )
}
```

Compile individual html into one unique html file.

``` r
template_qmd <- readLines("inst/template.qmd")

path_html_files <- list.files(
  courses_path, 
  full.names = TRUE,
  pattern = "\\.html$"
)

divs_to_insert <- path_html_files |> 
  lapply(
    \(path_html_file) {
      sprintf(
        '<div data-external-replace="%s">  </div>',
        path_html_file
      )
    }
  ) |> 
  paste(
    collapse = "\n\n---\n\n"
  )

index_qmd <- gsub(
  pattern = "\\{\\{insert_divs\\}\\}",
  replacement = divs_to_insert,
  template_qmd
) 

writeLines(
  index_qmd,
  "index.qmd"
)
```

``` r
quarto::quarto_preview("index.qmd")
```
