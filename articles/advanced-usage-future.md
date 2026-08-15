# Using parallel workers

Inside [squash](https://thinkr-open.github.io/squash/), the individual
rendering of quarto presentation files is managed via
[future](https://future.futureverse.org) and
[furrr](https://github.com/futureverse/furrr) packages, meaning you can
parallelize the generation of several chapters at once.

To do so, you need to setup the
[`future::plan()`](https://future.futureverse.org/reference/plan.html)
with your selected behavior (e.g. `sequential` or `multisession`) before
running the compilation.

``` r

library(squash)

# set parallel rendering with future
future::plan(future::multisession, workers = 2)

html_output <- compile_qmd_course(
  vec_qmd_path = qmds,
  output_dir = temp_dir,
  output_html = "complete_course.html"
)

# reset default future plan
future::plan("default")
```

By running the above command,
[squash](https://thinkr-open.github.io/squash/) will first warn you that
a non-default plan is detected for running the compilation. It will then
proceed to render the html.

    #> ℹ {future} is using plan(multisession, workers = 2), to modify this use `future::plan()`
    #> ✔ All qmd rendered.

## A note on future

- Future plan will not be modified by
  [squash](https://thinkr-open.github.io/squash/), you may want to
  restor default plan after rendering with the `future::plan("default")`
  command.

- Parallel rendering in currently not natively supported by quarto. As a
  result, please use parallel rendering at your own risk, as it is
  likely to become unstable with an increasing number of quarto chapter
  files.

- Unstability is likely caused by temporary execution directories that
  may be erased by a sub-process while still being looked for in another
  subprocess.
