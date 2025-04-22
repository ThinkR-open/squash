#' Render a qmd course to html
#'
#' Render a single qmd file to html with image folder.
#'
#' @param qmd character. Path to the qmd file to render
#' @param img_root_dir character. Path to the main image folder to extract media to
#' @param metadata list. List of metadata to be used for rendering single qmd file
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
  quiet = TRUE
) {
  # set image sub-folder name
  chapter <- dirname(qmd)

  img_dir <- file.path(
    img_root_dir,
    paste0(basename(chapter), "_img")
  )

  quarto_render_insistently <- purrr::insistently(
    quarto_render,
    rate = purrr::rate_backoff(
      pause_base = 0.1,
      max_times = 5
    )
  )

  # try rendering qmd and warn user if successful / fail
  tryCatch(
    expr = {
      quarto_render_insistently(
        input = qmd,
        metadata = c(metadata, list(`extract-media` = img_dir)),
        output_format = output_format,
        quiet = quiet
      )
      return(TRUE)
    },
    error = \(error_message) {
      cli_alert_danger("Failed to render {qmd}, cleaning and existing")

      # throw an error with original error message
      return(FALSE)
    }
  )
}
