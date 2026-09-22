make_project_tree <- function() {
  root <- tempfile(pattern = "fetchproj")
  dirs <- c(
    proj_yml = "proj_yml",
    proj_yml_sub = file.path("proj_yml", "chap", "sub"),
    proj_yaml = "proj_yaml",
    inner = file.path("proj_yml", "inner"),
    inner_sub = file.path("proj_yml", "inner", "x"),
    no_proj = file.path("no_proj", "deep"),
    profile_only = "profile_only",
    empty_yml = "empty_yml"
  )
  for (a_dir in dirs) {
    dir.create(file.path(root, a_dir), recursive = TRUE)
  }
  project_yaml <- "project:\n  type: default"
  writeLines(project_yaml, con = file.path(root, "proj_yml", "_quarto.yml"))
  writeLines(project_yaml, con = file.path(root, "proj_yaml", "_quarto.yaml"))
  writeLines(project_yaml, con = file.path(root, "proj_yml", "inner", "_quarto.yml"))
  writeLines(project_yaml, con = file.path(root, "profile_only", "_quarto-init.yml"))
  writeLines("", con = file.path(root, "empty_yml", "_quarto.yml"))

  qmd <- file.path(root, dirs, "dummy.qmd")
  file.create(qmd)
  names(qmd) <- names(dirs)
  return(list(root = root, qmd = qmd))
}

test_that("fetch_project finds project roots without running quarto", {
  tree <- make_project_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)
  root <- normalizePath(tree$root, winslash = "/")

  # an unusable quarto binary: only a filesystem lookup can succeed
  withr::local_envvar(QUARTO_PATH = file.path(tree$root, "no-quarto"))

  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = tree$qmd["proj_yml_sub"])),
    expected = file.path(root, "proj_yml")
  )
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = tree$qmd["proj_yaml"])),
    expected = file.path(root, "proj_yaml")
  )
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = tree$qmd["inner_sub"])),
    expected = file.path(root, "proj_yml", "inner")
  )
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = tree$qmd["empty_yml"])),
    expected = file.path(root, "empty_yml")
  )
})

test_that("fetch_project returns the qmd folder when no project is found", {
  tree <- make_project_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)

  qmd <- tree$qmd[c("no_proj", "profile_only")]
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = qmd)),
    expected = unname(dirname(qmd))
  )
})

test_that("fetch_project deduplicates folders and projects", {
  tree <- make_project_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)
  root <- normalizePath(tree$root, winslash = "/")

  qmd <- tree$qmd[c("proj_yml", "proj_yml_sub", "no_proj")]
  qmd <- c(qmd, file.path(dirname(tree$qmd["no_proj"]), "other.qmd"))
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = qmd)),
    expected = c(
      unname(dirname(tree$qmd["no_proj"])),
      file.path(root, "proj_yml")
    )
  )
})

test_that("fetch_project agrees with quarto inspect", {
  skip_if_not(quarto::quarto_available(), message = "quarto is not installed")
  tree <- make_project_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)

  for (a_qmd in tree$qmd) {
    inspected <- tryCatch(
      expr = {
        quarto::quarto_inspect(dirname(a_qmd))$dir
      },
      error = function(e) {
        NULL
      }
    )
    expected <- if (is.null(inspected)) {
      dirname(a_qmd)
    } else {
      normalizePath(inspected, winslash = "/")
    }
    expect_equal(
      object = unlist(fetch_project(vec_qmd_path = a_qmd)),
      expected = expected,
      label = a_qmd
    )
  }
})

test_that("fetch_project returns a character vector", {
  tree <- make_project_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)

  expect_type(
    object = fetch_project(vec_qmd_path = tree$qmd),
    type = "character"
  )
})

make_symlink_tree <- function() {
  root <- normalizePath(tempfile(pattern = "fetchlink"), winslash = "/", mustWork = FALSE)
  dir.create(file.path(root, "proj", "chap"), recursive = TRUE)
  dir.create(file.path(root, "elsewhere", "chap"), recursive = TRUE)
  dir.create(file.path(root, "outside"))
  writeLines("project:\n  type: default", con = file.path(root, "proj", "_quarto.yml"))
  linked <- c(
    file.symlink(
      from = file.path(root, "proj", "chap"),
      to = file.path(root, "outside", "link_in")
    ),
    file.symlink(
      from = file.path(root, "elsewhere", "chap"),
      to = file.path(root, "proj", "link_out")
    )
  )
  return(list(root = root, linked = all(linked)))
}

test_that("fetch_project follows the path as written, not the symlink target", {
  tree <- make_symlink_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)
  skip_if_not(tree$linked, message = "symlinks are not supported here")

  # a folder linked from outside a project is not in the project
  link_in <- file.path(tree$root, "outside", "link_in")
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = file.path(link_in, "a.qmd"))),
    expected = link_in
  )
  # a folder linked into a project belongs to it
  expect_equal(
    object = unlist(fetch_project(
      vec_qmd_path = file.path(tree$root, "proj", "link_out", "a.qmd")
    )),
    expected = file.path(tree$root, "proj")
  )
})

test_that("fetch_project agrees with quarto inspect through symlinks", {
  skip_if_not(quarto::quarto_available(), message = "quarto is not installed")
  tree <- make_symlink_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)
  skip_if_not(tree$linked, message = "symlinks are not supported here")

  for (a_dir in file.path(tree$root, c("outside/link_in", "proj/link_out"))) {
    inspected <- tryCatch(
      expr = {
        quarto::quarto_inspect(a_dir)$dir
      },
      error = function(e) {
        a_dir
      }
    )
    expect_equal(
      object = unlist(fetch_project(vec_qmd_path = file.path(a_dir, "a.qmd"))),
      expected = inspected,
      label = a_dir
    )
  }
})

test_that("fetch_project resolves relative paths and dot segments", {
  tree <- make_project_tree()
  on.exit(unlink(tree$root, recursive = TRUE), add = TRUE)
  root <- normalizePath(tree$root, winslash = "/")

  withr::local_dir(file.path(root, "proj_yml", "chap"))
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = file.path("sub", "..", "sub", ".", "dummy.qmd"))),
    expected = file.path(root, "proj_yml")
  )
  expect_equal(
    object = unlist(fetch_project(vec_qmd_path = file.path("..", "..", "no_proj", "deep", "dummy.qmd"))),
    expected = file.path("..", "..", "no_proj", "deep")
  )
})
