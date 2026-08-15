test_that("build_isolated_project creates a private project and keeps the repo reachable", {
  # fake repo: root/(data.csv)/courses/(_quarto.yml, _extensions, M01/S01/file.qmd)
  root <- tempfile(pattern = "iso_repo")
  chapter <- file.path(root, "courses", "M01", "S01")
  sibling <- file.path(root, "courses", "M01", "S02")
  ext <- file.path(root, "courses", "_extensions", "acme", "theme")

  dir.create(chapter, recursive = TRUE)
  dir.create(sibling, recursive = TRUE)
  dir.create(ext, recursive = TRUE)

  writeLines("format: revealjs", file.path(root, "courses", "_quarto.yml"))
  writeLines("title: theme", file.path(ext, "_extension.yml"))
  writeLines("a,b", file.path(root, "data.csv"))
  qmd <- file.path(chapter, "doc.qmd")
  writeLines("# doc", qmd)
  writeLines("img", file.path(chapter, "logo.png"))
  writeLines("# other", file.path(sibling, "other.qmd"))

  isolation <- build_isolated_project(qmd)
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

test_that("collect_isolated_outputs copies rendering outputs back to the real chapter", {
  root <- tempfile(pattern = "iso_repo")
  chapter <- file.path(root, "courses", "M01", "S01")
  dir.create(chapter, recursive = TRUE)
  writeLines("format: revealjs", file.path(root, "courses", "_quarto.yml"))
  qmd <- file.path(chapter, "doc.qmd")
  writeLines("# doc", qmd)

  isolation <- build_isolated_project(qmd)
  on.exit(unlink(isolation$iso_root, recursive = TRUE), add = TRUE)

  # simulate a render: html + media dir appear in the isolated chapter
  writeLines("<html></html>", file.path(isolation$iso_chapter, "doc.html"))
  media <- file.path(isolation$iso_chapter, "out_img", "S01_img")
  dir.create(media, recursive = TRUE)
  writeLines("img", file.path(media, "fig.png"))

  collect_isolated_outputs(isolation)

  expect_true(file.exists(file.path(chapter, "doc.html")))
  expect_true(file.exists(file.path(chapter, "out_img", "S01_img", "fig.png")))
  # pre-existing files are not duplicated or altered
  expect_identical(readLines(file.path(chapter, "doc.qmd")), "# doc")
})
