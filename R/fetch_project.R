#' List detected quarto project
#'
#' A folder belongs to the closest quarto project found by walking up its
#' parents, a project being a folder holding a `_quarto.yml` or
#' `_quarto.yaml`. This is the project root `quarto inspect` reports, found
#' without spawning one quarto process per folder.
#'
#' @param vec_qmd_path character. Path to the qmd files targeted for compilation
#' @param quiet logical. Warn user of project status.
#'
#' @return character. Quarto project root of each qmd, or the qmd folder
#'   when it belongs to no project, without duplicates.
#'
#' @noRd
#' @examples
#' # add a qmd in a tmp dir
#' tmpdir <- tempfile(pattern = "addcompil")
#' dir.create(tmpdir)
#'
#' qmd <- file.path(tmpdir, "dummy.qmd")
#' file.create(qmd)
#' file.create(file.path(tmpdir, "_quarto.yaml"))
#'
#' # init a quarto project
#' fetch_project(vec_qmd_path = qmd, quiet = FALSE)
#'
#' # cleanup
#' unlink(tmpdir, recursive = TRUE)
fetch_project <- function(
  vec_qmd_path,
  quiet = TRUE
) {
  # look for existing quarto projects
  # _extensions will be added to project root
  qmd_dir <- unique(dirname(vec_qmd_path))

  quarto_proj <- vapply(
    X = qmd_dir,
    FUN = find_quarto_project_root,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )

  dir_is_proj <- !is.na(quarto_proj)
  qmd_proj_dir <- unique(c(qmd_dir[!dir_is_proj], quarto_proj[dir_is_proj]))

  return(qmd_proj_dir)
}

#' Find the root of the quarto project holding a folder
#'
#' @param dir character. A folder path.
#'
#' @return character. Normalized path of the closest parent folder (the
#'   folder itself included) holding a `_quarto.yml` or `_quarto.yaml`,
#'   `NA` when there is none.
#'
#' @noRd
find_quarto_project_root <- function(dir) {
  current <- normalizePath(dir, winslash = "/", mustWork = FALSE)
  repeat {
    config_found <- file.exists(
      file.path(current, c("_quarto.yml", "_quarto.yaml"))
    )
    if (any(config_found)) {
      return(current)
    }
    parent <- dirname(current)
    if (identical(parent, current)) {
      return(NA_character_)
    }
    current <- parent
  }
}
