#' Build an isolated quarto project to render a single qmd
#'
#' Concurrent `quarto render` processes sharing one quarto project race on the
#' project state (`.quarto/`, `_extensions/` resolution), which surfaces as
#' transient "Unable to read the extension" failures. This helper materializes
#' a throwaway project in `tempdir()` where the render can run alone:
#' the repository tree is exposed through symlinks (so `here::here()` and
#' data paths keep resolving), while the project configuration
#' (`_quarto*.yml`), `_extensions/` and the chapter of the target qmd are
#' real private copies. Each isolated render therefore gets its own fresh
#' `.quarto/` state.
#'
#' @param qmd character. Path to the qmd file to render.
#'
#' @return A list with `iso_qmd` (path of the qmd inside the isolated
#' project), `iso_chapter`, `real_chapter`, `iso_root` and
#' `files_before` (chapter files present before rendering).
#'
#' @noRd
build_isolated_project <- function(qmd) {
  qmd <- normalizePath(qmd, mustWork = TRUE)
  chapter <- dirname(qmd)

  proj <- chapter
  while (!any(file.exists(file.path(proj, c("_quarto.yml", "_quarto.yaml"))))) {
    parent <- dirname(proj)
    if (identical(parent, proj)) {
      stop("No quarto project found above ", qmd)
    }
    proj <- parent
  }
  root <- dirname(proj)

  iso <- tempfile(pattern = "squash_iso_")
  dir.create(iso)

  # repository level: symlink everything except the quarto project dir
  for (entry in list.files(root, all.files = TRUE, no.. = TRUE)) {
    if (entry != basename(proj)) {
      file.symlink(from = file.path(root, entry), to = file.path(iso, entry))
    }
  }
  # make sure here::here() anchors on the isolated root
  if (!file.exists(file.path(iso, ".here"))) {
    file.create(file.path(iso, ".here"))
  }

  rel_parts <- strsplit(
    substring(chapter, nchar(proj) + 2),
    split = "/",
    fixed = TRUE
  )[[1]]

  # project level: private copies of config and extensions, own .quarto
  iso_cur <- file.path(iso, basename(proj))
  dir.create(iso_cur)
  for (entry in list.files(proj, all.files = TRUE, no.. = TRUE)) {
    if (entry %in% c(".quarto", "_freeze", rel_parts[1])) {
      next
    }
    if (grepl("^_quarto.*\\.ya?ml$", entry) || entry == "_extensions") {
      file.copy(
        from = file.path(proj, entry),
        to = iso_cur,
        recursive = TRUE
      )
    } else {
      file.symlink(
        from = file.path(proj, entry),
        to = file.path(iso_cur, entry)
      )
    }
  }

  # descend to the chapter: intermediate levels are real dirs with
  # symlinked siblings, the chapter itself is a real copy
  real_cur <- proj
  for (i in seq_along(rel_parts)) {
    real_cur <- file.path(real_cur, rel_parts[i])
    iso_next <- file.path(iso_cur, rel_parts[i])
    dir.create(iso_next)
    if (i < length(rel_parts)) {
      for (entry in list.files(real_cur, all.files = TRUE, no.. = TRUE)) {
        if (entry != rel_parts[i + 1]) {
          file.symlink(
            from = file.path(real_cur, entry),
            to = file.path(iso_next, entry)
          )
        }
      }
    } else {
      file.copy(
        from = list.files(
          real_cur,
          full.names = TRUE,
          all.files = TRUE,
          no.. = TRUE
        ),
        to = iso_next,
        recursive = TRUE
      )
    }
    iso_cur <- iso_next
  }

  files_before <- list.files(
    iso_cur,
    recursive = TRUE,
    all.files = TRUE,
    full.names = FALSE
  )

  return(
    list(
      iso_qmd = file.path(iso_cur, basename(qmd)),
      iso_chapter = iso_cur,
      real_chapter = chapter,
      iso_root = iso,
      files_before = files_before
    )
  )
}

#' Copy files produced by an isolated render back to the real chapter
#'
#' @param isolation list. As returned by [build_isolated_project()].
#'
#' @return Invisibly, the copied file paths.
#'
#' @noRd
collect_isolated_outputs <- function(isolation) {
  files_after <- list.files(
    isolation$iso_chapter,
    recursive = TRUE,
    all.files = TRUE,
    full.names = FALSE
  )
  new_files <- setdiff(files_after, isolation$files_before)

  for (rel_file in new_files) {
    dest <- file.path(isolation$real_chapter, rel_file)
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    file.copy(
      from = file.path(isolation$iso_chapter, rel_file),
      to = dest,
      overwrite = TRUE
    )
  }

  return(invisible(file.path(isolation$real_chapter, new_files)))
}
