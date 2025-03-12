#' Create a single html from multiple qmd
#'
#' Independently compile several qmd and create a common html
#'
#' @param vec_qmd_path character. Vector of the path to qmd files
#' @param output_dir character. Output path to store html files and companion folders
#' @param output_html character. File name of the complete html output saved
#' @param template character. Path to the template qmd to use. Content will be included at the positions inside double-brackets
#' @param output_format character. Output format of the qmd, default to "revealjs". Can be adapted for specific themes.
#' @param title character. Title of the presentation
#' @param template_text list. List of named elements to include in the template.
#' @param ext_dir character. Path to the _extensions directory to use when compiling qmd
#' @param metadata_template list. List of metadata used for rendering template.
#' If a path to a yml file is provided, metadata will be read from this file.
#' @param metadata_qmd list. List of metadata used for rendering individual qmd files.
#' If a path to a yml file is provided, metadata will be read from this file.
#' @param quiet logical. Output info in user console
#' @param debug logical. Output rendering output in user console.
#' @param fix_img_path logical. If image path are present as raw html inside files,
#' use this option to correctly edit their path.
#' @param render_pdf logical. If TRUE, render a pdf version of the html file
#' @param render_pdf_fun function. Function to use to render the pdf. Default to pagedown::chrome_print. The function need to take a path to a html file as input.
#'
#' @importFrom tools file_ext
#' @importFrom htmltools htmlTemplate renderDocument save_html HTML
#' @importFrom furrr future_map_lgl furrr_options
#' @importFrom purrr walk
#' @importFrom cli cli_alert_info cli_alert_warning cli_alert_success
#' @importFrom progressr handlers progressor with_progress
#' @importFrom yaml read_yaml
#'
#' @return character. The path to the resulting html file
#'
#' @export
#' @examples
#' library(future)
#'
#' # set parallel rendering
#' plan(multisession, workers = 2)
#'
#' # list example qmds
#' courses_path <- system.file(
#'   "courses",
#'   "M01",
#'   package = "squash"
#' )
#'
#' # copy course tree in tmpdir, add quarto porject file
#' tmp_course_path <- tempfile(pattern = "course")
#' dir.create(tmp_course_path)
#' file.create(file.path(tmp_course_path, "_quarto.yaml"))
#'
#' file.copy(
#'   from = courses_path,
#'   to = tmp_course_path,
#'   recursive = TRUE
#' )
#'
#' qmds <- list.files(
#'   path = tmp_course_path,
#'   full.names = TRUE,
#'   recursive = TRUE,
#'   pattern = "qmd$"
#' )
#'
#' # generate html in temp folder
#' temp_dir <- tempfile(pattern = "compile")
#'
#' html_output <- compile_qmd_course(
#'   vec_qmd_path = qmds,
#'   output_dir = temp_dir,
#'   output_html = "complete_course.html"
#' )
#'
#' # reset default rendering
#' plan("default")
#'
#' # clean up
#' unlink(temp_dir, recursive = TRUE)
#' unlink(tmp_course_path, recursive = TRUE)
compile_qmd_course <- function(
  vec_qmd_path,
  output_dir,
  output_html,
  template = system.file("template_minimal.qmd", package = "squash"),
  output_format = "revealjs",
  title = "Title",
  metadata_template = NULL,
  metadata_qmd = NULL,
  template_text = NULL,
  ext_dir = NULL,
  quiet = FALSE,
  debug = FALSE,
  fix_img_path = TRUE,
  render_pdf = FALSE,
  render_pdf_fun = pagedown::chrome_print
) {
  # check inputs and future settings
  not_all_files_are_qmd <- any(
    file_ext(vec_qmd_path) != "qmd"
  )
  if (isTRUE(not_all_files_are_qmd)) {
    stop("Some of the input files are not qmd files.")
  }

  if (is.character(metadata_template) && file.exists(metadata_template)) {
    metadata_template <- read_yaml(metadata_template)
  }
  if (is.character(metadata_template) && file.exists(metadata_template)) {
    metadata_qmd <- read_yaml(metadata_qmd)
  }

  fetch_future_settings(quiet = quiet)

  # list courses files present before rendering
  vec_qmd_dir <- unique(dirname(vec_qmd_path))

  file_present_before_rendering <- list.files(
    path = vec_qmd_dir,
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE
  )

  # prepare qmd rendering
  tmp_ext_dir <- add_extension(
    vec_qmd_path = vec_qmd_path,
    ext_dir = ext_dir,
    quiet = quiet
  )

  # create output dir and html template
  template_html <- create_template_html(
    path_to_qmd = template,
    output_dir = output_dir,
    output_format = output_format,
    output_file = output_html,
    title = title,
    metadata = metadata_template,
    ext_dir = ext_dir
  )

  # set main folder for image
  img_root_dir <- gsub("\\.html", "_img", output_html)

  # setup progress report with {progressr}
  handlers("progress")
  p <- progressor(along = vec_qmd_path)

  # render each course in parallel
  render_success <- future_map_lgl(
    .x = vec_qmd_path,
    .f = \(x){
      p(sprintf("rendering %s", basename(x)), class = "sticky")
      render_single_qmd(
        x,
        img_root_dir = img_root_dir,
        output_format = output_format,
        metadata = metadata_qmd,
        quiet = !debug
      )
    },
    # make random number generation reproducible
    .options = furrr_options(seed = TRUE)
  )

  # exit and clean if some rendering failed
  if (!all(render_success)) {
    clean_rendering_files(
      dir = vec_qmd_dir,
      present_before = file_present_before_rendering,
      extra_dir = tmp_ext_dir
    )
    stop("Failed to render all qmd files.")
  } else {
    if (isFALSE(quiet)) {
      cli_alert_success("All qmd rendered.")
    }
  }

  # correct remaining img path
  vec_html_path <- gsub("\\.qmd", "\\.html", vec_qmd_path)

  if (fix_img_path) {
    walk(.x = vec_html_path, .f = \(x) {
      copy_img_and_edit_path(html_path = x, img_root_dir = img_root_dir)
    })
  }

  # read html and extract slides elements
  html_content <- extract_html_slides(
    vec_html_path = vec_html_path
  )

  # include content in template
  # use do.call to add any list of extra content in template
  complete_html <- do.call(
    htmlTemplate,
    append(
      list(
        filename = template_html,
        include_html_content = HTML(html_content)
      ),
      template_text
    )
  ) |>
    renderDocument()


  # save html file
  path_to_html <- file.path(
    output_dir,
    output_html
  )

  save_html(
    html = complete_html,
    file = path_to_html
  )

  # copy all img sub-folders to output_dir
  output_img_dir <- file.path(
    output_dir,
    gsub("\\.html", "_img", output_html)
  )

  if (!file.exists(output_img_dir)) {
    dir.create(path = output_img_dir)
  }

  vec_img_dir <- file.path(
    vec_qmd_dir,
    gsub("\\.html", "_img", output_html),
    paste0(basename(vec_qmd_dir), "_img")
  )

  # copy img dir if they are present
  vec_img_dir <- vec_img_dir[dir.exists(vec_img_dir)]

  file.copy(
    from = unique(vec_img_dir),
    to = output_img_dir,
    recursive = TRUE
  )

  clean_rendering_files(
    dir = vec_qmd_dir,
    present_before = file_present_before_rendering,
    extra_dir = tmp_ext_dir
  )

  if (render_pdf) {
    render_pdf_fun(
      file.path(
        output_dir,
        output_html
      )
    )
  }

  return(
    file.path(
      output_dir,
      output_html
    )
  )
}
