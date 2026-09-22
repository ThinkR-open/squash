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
  skip_if(is.null(quarto::quarto_path()), message = "quarto is not installed")
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
