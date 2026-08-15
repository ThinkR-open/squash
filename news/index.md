# Changelog

## squash 1.3.0

- Each qmd is now rendered inside an isolated throwaway copy of the
  quarto project (option `squash.isolate_render`, `TRUE` by default).
  Concurrent renders no longer share the project state (`.quarto/`
  crossref index, `_extensions/` resolution), which removes the random
  `Failed to render` errors of parallel compilation
  (quarto-dev/quarto-cli#2749).
- Isolation falls back to rendering in place whenever it is not
  possible: no quarto project above the qmd, project with a
  project-level `output-dir` (websites, books), or filesystem without
  symlink support (e.g. Windows without the symlink privilege). Every
  filesystem step of the isolation is checked so a partial isolated
  project can never be rendered silently.
- Outputs are copied back to the real chapter when they are new or
  updated, so re-renders refresh files left by a previous run.
- [`render_single_qmd()`](https://thinkr-open.github.io/squash/reference/render_single_qmd.md)
  now reports the underlying error message instead of discarding it.

## squash 1.2.0

- The rendering of the Qmd is now performed insistently with
  purrr::insistently(), and can be configured in the rendering
  functions.

## squash 1.1.0

- You can now print the output to pdf
  ([\#18](https://github.com/ThinkR-open/squash/issues/18))

## squash 1.0.0

- Official stable release

## squash 0.4.7

- Add architecture scheme
- Improve Readme

## squash 0.4.6

- Add vignette for advanced usage
- Improve code coverage
- Refactoring

## squash 0.4.5

- Add `debug` parameter to split simple verbose and large one includong
  all rendering details
- Add vignette for simple usage

## squash 0.4.4

- Refactoring to reduce single function size

## squash 0.4.3

- use {fs} to compute extensions relative path

## squash 0.4.2

- Use external extension directory.
- Enable metadata input as yaml
- Update doc to cimplify user example in ReadMe.

## squash 0.4.1

- Set rendering parameters as function parameters instead of yaml file.

## squash 0.4.0

- New feature : set `fix_img_path` to TRUE to enable img embedding with
  html code.

## squash 0.3.8

- Update quakr to increase text size in slides

## squash 0.3.7

- New feature: add a footer to the html

## squash 0.3.6

- Add admin file to install {squash} on dev containers

## squash 0.3.5

- Improve test slides description text to ease visual check
- Remove fusen structure

## squash 0.3.4

- Use keywords metadata as slide url id if present and check for
  duplicates

## squash 0.3.3

- Create output directory recursively if does not exist

## squash 0.3.2

- Do not try to fetch img dir when no media is extracted from a qmd

## squash 0.3.1

- Look for quarto project using directory path

## squash 0.3.0

- No file rendering is executed inside the package file architecture
- Rendering progress is tracked with {progressr}
- Quarto compil profile and quakr theme are added to quarto project if
  not pre-existing

## squash 0.2.1

- Example courses used in {formation} are converted to qmd and included
  in tests

## squash 0.2.0

- Rename package
