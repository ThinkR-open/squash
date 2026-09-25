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
#' @return character. Absolute path of the closest parent folder (the
#'   folder itself included) holding a `_quarto.yml` or `_quarto.yaml`,
#'   `NA` when there is none. Like quarto, the parents are those of the
#'   path as written: symlinks are not resolved.
#'
#' @noRd
find_quarto_project_root <- function(dir) {
  current <- absolute_path(dir)
  repeat {
    config_found <- file.exists(
      file.path(current, c("_quarto.yml", "_quarto.yaml"))
    )
    if (any(config_found)) {
      return(current)
    }
    parent <- dirname(current)
    if (identical(x = parent, y = current)) {
      return(NA_character_)
    }
    current <- parent
  }
}

#' Make a path absolute without resolving symlinks
#'
#' @param path character. A path, relative to the working directory or
#'   absolute.
#'
#' @return character. The absolute path, with `/` separators and the `.`
#'   and `..` segments collapsed.
#'
#' @noRd
absolute_path <- function(path) {
  path <- gsub(pattern = "\\\\", replacement = "/", x = path)
  if (!grepl(pattern = "^([A-Za-z]:)?/", x = path)) {
    path <- file.path(gsub(pattern = "\\\\", replacement = "/", x = getwd()), path)
  }
  root <- regmatches(x = path, m = regexpr(pattern = "^([A-Za-z]:)?/", text = path))
  segments <- strsplit(
    x = substring(text = path, first = nchar(root) + 1),
    split = "/",
    fixed = TRUE
  )[[1]]
  kept <- character(0)
  for (a_segment in segments) {
    if (a_segment %in% c("", ".")) {
      next
    }
    if (identical(x = a_segment, y = "..")) {
      kept <- kept[-length(kept)]
      next
    }
    kept <- c(kept, a_segment)
  }
  return(paste0(root, paste(kept, collapse = "/")))
}
