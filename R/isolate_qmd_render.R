#' Build an isolated quarto project to render a single qmd
#'
#' Concurrent `quarto render` processes sharing one quarto project race on the
#' project state (`.quarto/`, `_extensions/` resolution), which surfaces as
#' transient "Unable to read the extension" failures and corrupted crossref
#' indexes. This helper materializes a throwaway project in `tempdir()` where
#' the render can run alone: the repository tree is exposed through symlinks
#' (so `here::here()` and data paths keep resolving), while the project
#' configuration (`_quarto*.yml`), `_extensions/` and the chapter of the
#' target qmd are real private copies. Each isolated render therefore gets
#' its own fresh `.quarto/` state.
#'
#' Every filesystem step is checked: on any failure (symlinks forbidden,
#' restricted mounts, Windows without the symlink privilege) an error is
#' raised so the caller can fall back to rendering in place. Projects that
#' define a `project: output-dir:` (websites, books) are refused as well,
#' because their outputs land outside the chapter and could not be collected.
#'
#' @param qmd character. Path to the qmd file to render.
#'
#' @return A list with `iso_qmd` (path of the qmd inside the isolated
#' project), `iso_chapter`, `real_chapter`, `iso_root` and
#' `files_before` (inventory of the isolated chapter before rendering,
#' with modification time and size).
#'
#' @noRd
build_isolated_project <- function(qmd) {
  qmd <- normalizePath(qmd, mustWork = TRUE)
  chapter <- dirname(qmd)

  proj <- chapter
  while (!any(file.exists(file.path(proj, c("_quarto.yml", "_quarto.yaml"))))) {
    parent <- dirname(proj)
    if (identical(parent, proj)) {
      stop(
        errorCondition(
          message = paste0("No quarto project found above ", qmd),
          class = c("squash_no_project", "error", "condition")
        )
      )
    }
    proj <- parent
  }

  refuse_project_with_output_dir(proj = proj)

  iso <- tempfile(pattern = "squash_iso_")
  dir_create_or_stop(iso)
  cleanup_armed <- TRUE
  on.exit(
    {
      if (cleanup_armed) {
        unlink(iso, recursive = TRUE)
      }
    },
    add = TRUE
  )

  # repository level: symlink everything except the quarto project dir.
  # The exposed root is bounded to the enclosing repository (.git / .here
  # anchor): without such an anchor, nothing above the project is exposed.
  root <- find_repository_root(proj = proj)
  if (!is.null(root)) {
    rel_proj_parts <- split_path_below(root = root, descendant = proj)
    iso_cur <- iso
    real_cur <- root
    for (i in seq_along(rel_proj_parts)) {
      link_siblings_or_stop(
        real_dir = real_cur,
        iso_dir = iso_cur,
        keep_real = rel_proj_parts[i]
      )
      real_cur <- file.path(real_cur, rel_proj_parts[i])
      iso_cur <- file.path(iso_cur, rel_proj_parts[i])
      if (i < length(rel_proj_parts)) {
        dir_create_or_stop(iso_cur)
      }
    }
    iso_proj <- iso_cur
  } else {
    iso_proj <- file.path(iso, basename(proj))
  }

  # make sure here::here() anchors on the isolated root
  if (!file.exists(file.path(iso, ".here"))) {
    if (!file.create(file.path(iso, ".here"))) {
      stop("Could not create ", file.path(iso, ".here"))
    }
  }

  # project level: private copies of config and extensions, own .quarto
  dir_create_or_stop(iso_proj)
  rel_parts <- split_path_below(root = proj, descendant = chapter)
  first_kept <- if (length(rel_parts) > 0) {
    rel_parts[1]
  } else {
    NULL
  }
  for (entry in list.files(proj, all.files = TRUE, no.. = TRUE)) {
    if (entry %in% c(".quarto", "_freeze")) {
      next
    }
    if (identical(entry, first_kept)) {
      next
    }
    is_config <- grepl("^_quarto.*\\.ya?ml$", entry) || entry == "_extensions"
    # when the qmd sits directly in the project dir, the project dir IS the
    # chapter: plain files must be real private copies as well
    is_chapter_file <- length(rel_parts) == 0 &&
      !dir.exists(file.path(proj, entry))
    if (is_config || is_chapter_file) {
      copy_or_stop(
        from = file.path(proj, entry),
        to = iso_proj,
        recursive = TRUE
      )
    } else {
      link_or_stop(
        from = file.path(proj, entry),
        to = file.path(iso_proj, entry)
      )
    }
  }

  # descend to the chapter: intermediate levels are real dirs with
  # symlinked siblings, the chapter itself is a real copy
  iso_cur <- iso_proj
  real_cur <- proj
  for (i in seq_along(rel_parts)) {
    real_cur <- file.path(real_cur, rel_parts[i])
    iso_next <- file.path(iso_cur, rel_parts[i])
    dir_create_or_stop(iso_next)
    if (i < length(rel_parts)) {
      link_siblings_or_stop(
        real_dir = real_cur,
        iso_dir = iso_next,
        keep_real = rel_parts[i + 1]
      )
    } else {
      entries <- list.files(
        real_cur,
        full.names = TRUE,
        all.files = TRUE,
        no.. = TRUE
      )
      if (length(entries) > 0) {
        copy_or_stop(from = entries, to = iso_next, recursive = TRUE)
      }
    }
    iso_cur <- iso_next
  }

  iso_chapter <- iso_cur

  cleanup_armed <- FALSE
  return(
    list(
      iso_qmd = file.path(iso_chapter, basename(qmd)),
      iso_chapter = iso_chapter,
      real_chapter = chapter,
      iso_root = iso,
      files_before = chapter_inventory(iso_chapter)
    )
  )
}

#' Copy files produced or updated by an isolated render back to the real chapter
#'
#' Compares the isolated chapter with the inventory captured before rendering:
#' files that are new, or whose size or modification time changed, are copied
#' back (so a re-render refreshes outputs that already existed).
#'
#' @param isolation list. As returned by [build_isolated_project()].
#'
#' @return Invisibly, the copied file paths.
#'
#' @noRd
collect_isolated_outputs <- function(isolation) {
  after <- chapter_inventory(isolation$iso_chapter)
  before <- isolation$files_before

  is_new <- !(after$path %in% before$path)
  matched <- match(after$path, before$path)
  is_changed <- !is_new &
    (after$mtime != before$mtime[matched] | after$size != before$size[matched])
  to_copy <- after$path[is_new | is_changed]

  for (rel_file in to_copy) {
    dest <- file.path(isolation$real_chapter, rel_file)
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    file.copy(
      from = file.path(isolation$iso_chapter, rel_file),
      to = dest,
      overwrite = TRUE
    )
  }

  return(invisible(file.path(isolation$real_chapter, to_copy)))
}

#' Inventory of a chapter directory: relative path, mtime, size
#' @noRd
chapter_inventory <- function(dir) {
  paths <- list.files(
    dir,
    recursive = TRUE,
    all.files = TRUE,
    full.names = FALSE
  )
  info <- file.info(file.path(dir, paths))
  return(
    data.frame(
      path = paths,
      mtime = as.numeric(info$mtime),
      size = info$size,
      stringsAsFactors = FALSE
    )
  )
}

#' Nearest ancestor of the project marking a repository root (.git or .here)
#'
#' Returns NULL when no marker exists above the project: in that case nothing
#' above the project directory is exposed in the isolated tree.
#'
#' @noRd
find_repository_root <- function(proj) {
  cur <- dirname(proj)
  while (!identical(cur, dirname(cur))) {
    if (any(file.exists(file.path(cur, c(".git", ".here"))))) {
      return(cur)
    }
    cur <- dirname(cur)
  }
  return(NULL)
}

#' Split the path of `descendant` relative to `root` into components
#' @noRd
split_path_below <- function(root, descendant) {
  if (identical(root, descendant)) {
    return(character(0))
  }
  rel <- substring(descendant, nchar(root) + 2)
  return(strsplit(rel, split = "/", fixed = TRUE)[[1]])
}

#' Refuse isolation for projects rendering into a project-level output-dir
#' @importFrom yaml read_yaml
#' @noRd
refuse_project_with_output_dir <- function(proj) {
  configs <- list.files(
    proj,
    pattern = "^_quarto.*\\.ya?ml$",
    full.names = TRUE
  )
  for (config in configs) {
    parsed <- tryCatch(
      expr = {
        read_yaml(config)
      },
      error = \(error_message) {
        NULL
      }
    )
    if (!is.null(parsed$project$`output-dir`)) {
      stop(
        errorCondition(
          message = paste0(
            "Project ", proj, " renders into an output-dir (",
            parsed$project$`output-dir`,
            "), its outputs could not be collected from an isolated copy"
          ),
          class = c("squash_no_isolation", "error", "condition")
        )
      )
    }
  }
  return(invisible(NULL))
}

#' dir.create that errors on failure
#' @noRd
dir_create_or_stop <- function(path) {
  if (!dir.create(path, showWarnings = FALSE)) {
    stop("Could not create directory ", path)
  }
  return(invisible(path))
}

#' file.symlink that errors on failure
#' @noRd
link_or_stop <- function(from, to) {
  ok <- suppressWarnings(file.symlink(from = from, to = to))
  if (!isTRUE(all(ok))) {
    stop("Could not symlink ", from, " -> ", to)
  }
  return(invisible(to))
}

#' file.copy that errors on failure
#' @noRd
copy_or_stop <- function(from, to, recursive = FALSE) {
  ok <- file.copy(from = from, to = to, recursive = recursive)
  if (!isTRUE(all(ok))) {
    stop(
      "Could not copy ",
      paste(from[!ok], collapse = ", "),
      " into ", to
    )
  }
  return(invisible(to))
}

#' Symlink every entry of real_dir into iso_dir, except keep_real
#' @noRd
link_siblings_or_stop <- function(real_dir, iso_dir, keep_real) {
  for (entry in list.files(real_dir, all.files = TRUE, no.. = TRUE)) {
    if (!identical(entry, keep_real)) {
      link_or_stop(
        from = file.path(real_dir, entry),
        to = file.path(iso_dir, entry)
      )
    }
  }
  return(invisible(iso_dir))
}
