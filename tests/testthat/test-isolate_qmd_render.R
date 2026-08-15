symlinks_supported <- function() {
  probe_dir <- tempfile(pattern = "symlink_probe")
  dir.create(probe_dir)
  on.exit(unlink(probe_dir, recursive = TRUE), add = TRUE)
  target <- file.path(probe_dir, "target")
  file.create(target)
  ok <- suppressWarnings(
    file.symlink(from = target, to = file.path(probe_dir, "link"))
  )
  isTRUE(ok) && nzchar(Sys.readlink(file.path(probe_dir, "link")))
}

make_fake_repo <- function() {
  root <- tempfile(pattern = "iso_repo")
  chapter <- file.path(root, "courses", "M01", "S01")
  sibling <- file.path(root, "courses", "M01", "S02")
  ext <- file.path(root, "courses", "_extensions", "acme", "theme")

  dir.create(chapter, recursive = TRUE)
  dir.create(sibling, recursive = TRUE)
  dir.create(ext, recursive = TRUE)
  file.create(file.path(root, ".here"))

  writeLines("format: revealjs", file.path(root, "courses", "_quarto.yml"))
  writeLines("title: theme", file.path(ext, "_extension.yml"))
  writeLines("a,b", file.path(root, "data.csv"))
  qmd <- file.path(chapter, "doc.qmd")
  writeLines("# doc", qmd)
  writeLines("img", file.path(chapter, "logo.png"))
  writeLines("# other", file.path(sibling, "other.qmd"))

  list(root = root, chapter = chapter, qmd = qmd)
}

test_that("build_isolated_project creates a private project and keeps the repo reachable", {
  skip_if_not(symlinks_supported(), "symlinks are not supported here")

  repo <- make_fake_repo()
  on.exit(unlink(repo$root, recursive = TRUE), add = TRUE)

  isolation <- build_isolated_project(repo$qmd)
  on.exit(unlink(isolation$iso_root, recursive = TRUE), add = TRUE)

  iso_courses <- file.path(isolation$iso_root, "courses")

  # chapter and its content are real copies
  expect_true(file.exists(isolation$iso_qmd))
  expect_false(nzchar(Sys.readlink(isolation$iso_chapter)))
  expect_true(file.exists(file.path(isolation$iso_chapter, "logo.png")))

  # project config and extensions are private copies, not symlinks
  expect_true(file.exists(file.path(iso_courses, "_quarto.yml")))
  expect_false(nzchar(Sys.readlink(file.path(iso_courses, "_extensions"))))
  expect_true(
    file.exists(file.path(iso_courses, "_extensions", "acme", "theme", "_extension.yml"))
  )

  # sibling chapter and repo-level files stay reachable through symlinks
  expect_true(nzchar(Sys.readlink(file.path(iso_courses, "M01", "S02"))))
  expect_true(file.exists(file.path(iso_courses, "M01", "S02", "other.qmd")))
  expect_true(file.exists(file.path(isolation$iso_root, "data.csv")))

  # here::here() anchor is present at the isolated root
  expect_true(file.exists(file.path(isolation$iso_root, ".here")))

  # no shared .quarto state is exposed in the isolated project
  expect_false(dir.exists(file.path(iso_courses, ".quarto")))
})

test_that("collect_isolated_outputs copies new and updated outputs back", {
  skip_if_not(symlinks_supported(), "symlinks are not supported here")

  repo <- make_fake_repo()
  on.exit(unlink(repo$root, recursive = TRUE), add = TRUE)

  # a stale output from a previous render already sits in the real chapter
  writeLines("<html>OLD</html>", file.path(repo$chapter, "doc.html"))

  isolation <- build_isolated_project(repo$qmd)
  on.exit(unlink(isolation$iso_root, recursive = TRUE), add = TRUE)

  # simulate a render: the html is REGENERATED and media appear
  Sys.sleep(1.1)
  writeLines("<html>NEW</html>", file.path(isolation$iso_chapter, "doc.html"))
  media <- file.path(isolation$iso_chapter, "out_img", "S01_img")
  dir.create(media, recursive = TRUE)
  writeLines("img", file.path(media, "fig.png"))

  collect_isolated_outputs(isolation)

  # updated pre-existing output is refreshed, new files are brought back
  expect_identical(
    readLines(file.path(repo$chapter, "doc.html")),
    "<html>NEW</html>"
  )
  expect_true(file.exists(file.path(repo$chapter, "out_img", "S01_img", "fig.png")))
  # untouched inputs are not altered
  expect_identical(readLines(file.path(repo$chapter, "doc.qmd")), "# doc")
})

test_that("a qmd directly in the project dir gets a real private copy", {
  skip_if_not(symlinks_supported(), "symlinks are not supported here")

  root <- tempfile(pattern = "iso_repo")
  proj <- file.path(root, "courses")
  dir.create(proj, recursive = TRUE)
  file.create(file.path(root, ".here"))
  writeLines("format: revealjs", file.path(proj, "_quarto.yml"))
  qmd <- file.path(proj, "doc.qmd")
  writeLines("# doc", qmd)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)

  isolation <- build_isolated_project(qmd)
  on.exit(unlink(isolation$iso_root, recursive = TRUE), add = TRUE)

  expect_true(file.exists(isolation$iso_qmd))
  expect_false(nzchar(Sys.readlink(isolation$iso_qmd)))
})

test_that("nothing above the project is exposed without a repository marker", {
  skip_if_not(symlinks_supported(), "symlinks are not supported here")

  base <- tempfile(pattern = "iso_norepo")
  proj <- file.path(base, "courses")
  chapter <- file.path(proj, "M01")
  dir.create(chapter, recursive = TRUE)
  # a sibling of the project that must NOT leak into the isolated tree
  dir.create(file.path(base, "unrelated"))
  writeLines("format: revealjs", file.path(proj, "_quarto.yml"))
  qmd <- file.path(chapter, "doc.qmd")
  writeLines("# doc", qmd)
  on.exit(unlink(base, recursive = TRUE), add = TRUE)

  isolation <- build_isolated_project(qmd)
  on.exit(unlink(isolation$iso_root, recursive = TRUE), add = TRUE)

  expect_false(file.exists(file.path(isolation$iso_root, "unrelated")))
  expect_true(file.exists(isolation$iso_qmd))
})

test_that("projects with a project-level output-dir are refused", {
  root <- tempfile(pattern = "iso_site")
  proj <- file.path(root, "site")
  dir.create(proj, recursive = TRUE)
  writeLines(
    c("project:", "  type: website", "  output-dir: _site"),
    file.path(proj, "_quarto.yml")
  )
  qmd <- file.path(proj, "index.qmd")
  writeLines("# home", qmd)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)

  expect_error(
    build_isolated_project(qmd),
    class = "squash_no_isolation"
  )
})

test_that("an isolated render produces up-to-date output in the real chapter", {
  skip_if_not(symlinks_supported(), "symlinks are not supported here")
  skip_if_not(quarto::quarto_available(), "quarto is not available")

  # dedicated fixture: a real render requires a well-formed project
  # (the fake _extensions of make_fake_repo() would make quarto error)
  root <- tempfile(pattern = "iso_render")
  chapter <- file.path(root, "courses", "M01", "S01")
  dir.create(chapter, recursive = TRUE)
  file.create(file.path(root, ".here"))
  writeLines("format: revealjs", file.path(root, "courses", "_quarto.yml"))
  repo <- list(
    root = root,
    chapter = chapter,
    qmd = file.path(chapter, "doc.qmd")
  )
  on.exit(unlink(repo$root, recursive = TRUE), add = TRUE)
  writeLines(
    c("---", "title: v1", "---", "", "# FIRST-VERSION"),
    repo$qmd
  )

  expect_true(
    render_single_qmd(
      qmd = repo$qmd,
      img_root_dir = "iso_img",
      output_format = "revealjs"
    )
  )
  html <- file.path(repo$chapter, "doc.html")
  expect_true(file.exists(html))
  expect_true(any(grepl("FIRST-VERSION", readLines(html, warn = FALSE))))

  # re-render with modified content: the real chapter must be refreshed
  writeLines(
    c("---", "title: v2", "---", "", "# SECOND-VERSION"),
    repo$qmd
  )
  expect_true(
    render_single_qmd(
      qmd = repo$qmd,
      img_root_dir = "iso_img",
      output_format = "revealjs"
    )
  )
  expect_true(any(grepl("SECOND-VERSION", readLines(html, warn = FALSE))))

  # no isolated project tree is left behind
  leftovers <- list.files(
    tempdir(),
    pattern = "^squash_iso_",
    full.names = TRUE
  )
  expect_length(leftovers, 0)
})
