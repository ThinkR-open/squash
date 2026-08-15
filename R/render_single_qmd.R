#' Render a qmd course to html
#'
#' Render a single qmd file to html with image folder.
#'
#' @param qmd character. Path to the qmd file to render
#' @param img_root_dir character. Path to the main image folder to extract media to
#' @param metadata list. List of metadata to be used for rendering single qmd file
#' @param purrr_insistently_rate_backoff function. Function to use to retry rendering qmd files in case of failure. Should be a purrr::rate_backoff function.
#' @param isolate logical. If TRUE (default, controlled by option "squash.isolate_render"), render inside a throwaway copy of the quarto project so concurrent renders do not share project state. Outputs are copied back to the real chapter afterwards. When isolation is not possible (no quarto project above the qmd, project with a project-level output-dir, filesystem without symlink support), the qmd is rendered in place as before.
#'
#' @inheritParams compile_qmd_course
#'
#' @importFrom quarto quarto_render
#' @importFrom cli cli_alert_danger
#'
#' @return logical. TRUE if rendering succeeded, FALSE otherwise. Side effect : render qmd as html
#'
#' @export
#' @examples
#' # create a temp dir with qmd
#' temp_dir <- tempfile(pattern = "render")
#'
#' dir.create(
#'   path = file.path(temp_dir, "img"),
#'   recursive = TRUE
#' )
#'
#' file.copy(
#'   from = system.file("courses", "M01", "M01S01", "C01-qmd1_for_test.qmd", package = "squash"),
#'   to = temp_dir
#' )
#'
#' file.copy(
#'   from = system.file("courses", "M01", "M01S01", "img", "logo_1.png", package = "squash"),
#'   to = file.path(temp_dir, "img")
#' )
#'
#' # render qmd
#' is_rendered <- render_single_qmd(
#'   qmd = file.path(temp_dir, "C01-qmd1_for_test.qmd"),
#'   img_root_dir = file.path(temp_dir, "image_folder")
#' )
#'
#' # clean temp dir
#' unlink(temp_dir, recursive = TRUE)
render_single_qmd <- function(
  qmd,
  img_root_dir = "img",
  output_format = "revealjs",
  metadata = NULL,
  quiet = TRUE,
  purrr_insistently_rate_backoff = purrr::rate_backoff(
    pause_base = 0.1,
    max_times = 5
  ),
  isolate = getOption("squash.isolate_render", TRUE)
) {
  # set image sub-folder name
  chapter <- dirname(qmd)

  img_dir <- file.path(
    img_root_dir,
    paste0(basename(chapter), "_img")
  )

  quarto_render_insistently <- purrr::insistently(
    quarto_render,
    rate = purrr_insistently_rate_backoff
  )

  # concurrent renders sharing one quarto project race on the project
  # state, so each render runs in its own throwaway copy of the project
  isolation <- NULL
  if (isTRUE(isolate)) {
    isolation <- tryCatch(
      expr = {
        build_isolated_project(qmd)
      },
      squash_no_project = \(condition) {
        # no quarto project above the qmd: there is no shared project
        # state to isolate from, rendering in place is the normal path
        NULL
      },
      squash_no_isolation = \(condition) {
        cli_alert_info(
          "{conditionMessage(condition)}, rendering in place"
        )
        NULL
      },
      error = \(error_message) {
        cli_alert_warning(
          "Could not isolate {qmd} ({conditionMessage(error_message)}), rendering in place"
        )
        NULL
      }
    )
  }

  input <- if (is.null(isolation)) {
    qmd
  } else {
    isolation$iso_qmd
  }

  # try rendering qmd and warn user if successful / fail
  tryCatch(
    expr = {
      quarto_render_insistently(
        input = input,
        metadata = c(metadata, list(`extract-media` = img_dir)),
        output_format = output_format,
        quiet = quiet
      )
      if (!is.null(isolation)) {
        collect_isolated_outputs(isolation)
      }
      return(TRUE)
    },
    error = \(error_message) {
      cli_alert_danger(
        "Failed to render {qmd} ({conditionMessage(error_message)})"
      )
      return(FALSE)
    },
    finally = {
      if (!is.null(isolation)) {
        unlink(isolation$iso_root, recursive = TRUE)
      }
    }
  )
}
