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
#' @param date character. Start and end dates of the training
#' @param footer character. Footer appearing in all slides
#' @param trainer character. Name of the trainer
#' @param mail character. Mail of the trainer
#' @param phone character. Phone number of the trainer
#' @param ext_dir character. Path to the _extensions directory to use when compiling qmd
#' @param quiet logical. Output info in user console
#' @param fix_img_path logical. If image path are present as raw html inside files,
#' use this option to correctly edit their path.
#'
#' @importFrom tools file_ext
#' @importFrom htmltools htmlTemplate renderDocument save_html
#' @importFrom furrr future_map_lgl furrr_options
#' @importFrom purrr walk
#' @importFrom future plan
#' @importFrom cli cli_alert_info cli_alert_warning cli_alert_success
#' @importFrom progressr handlers progressor with_progress
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
    template = system.file("template.qmd", package = "squash"),
    output_format = "thinkridentity-revealjs",
    title = "Formation R",
    date = "01/01/01-01/01/01",
    footer = "**<i class='las la-book'></i> Formation R**",
    trainer = "ThinkR",
    mail = "thinkr.fr",
    phone = "+33 0 00 00 00 00",
    ext_dir = system.file("_extensions", package = "squash"),
    quiet = TRUE,
    fix_img_path = FALSE
) {
  # check paths
  not_all_files_are_qmd <- any(
    file_ext(vec_qmd_path) != "qmd"
  )
  if (isTRUE(not_all_files_are_qmd)) {
    stop("Some of the input files are not qmd files.")
  }
  
  # create output dir and html template
  template_html <- create_template_html(
    path_to_qmd = template,
    output_dir = output_dir,
    output_format = output_format,
    output_file = output_html,
    title = title,
    date = date,
    footer = footer,
    ext_dir = ext_dir
  )
  
  # list courses files present before rendering
  vec_qmd_dir <- unique(dirname(vec_qmd_path))
  
  file_present_before_rendering <- list.files(
    path = vec_qmd_dir,
    full.names = TRUE,
    include.dirs = TRUE,
    recursive = TRUE
  )
  
  # add extension in each directory
  tmp_ext_dir <- add_extension(
    vec_qmd_path = vec_qmd_path
  )
  
  # set main folder for image
  img_root_dir <- gsub("\\.html", "_img", output_html)
  
  # warn user about {furrr} strategy (e.g. parallel, sequential, default)
  if (isFALSE(quiet)){
    future_setting <- attr(plan(), "call")
    future_setting <- ifelse(
      test = is.null(future_setting),
      yes = 'plan("default")',
      no = deparse(future_setting)
    )
    
    cli_alert_info(paste(
      "{{future}} is using {future_setting},",
      "to modify this use {.code future::plan()}"
    ))
  }

  # setup progress report with {progressr}
  handlers("progress")
  p <- progressor(along = vec_qmd_path)
  
  # render each course in parallel
  render_success <- future_map_lgl(
    .x = vec_qmd_path,
    .f = \(x){
      p(sprintf("rendering %s", basename(x)), class = "sticky")
      render_single_qmd(x, img_root_dir = img_root_dir)
    },
    # make random number generation reproducible
    .options = furrr_options(seed = TRUE)
  )

  # exit and clean if some rendering failed
  if (!all(render_success)){
    clean_rendering_files(
      dir = vec_qmd_dir,
      present_before = file_present_before_rendering,
      extra_files = tmp_ext_dir
    )
    return(NULL)
  } else {
    if(isFALSE(quiet)){
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
  complete_html <- htmlTemplate(
    filename = template_html,
    include_html_content = html_content,
    include_trainer = trainer,
    include_mail = mail,
    include_phone = phone
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
    extra_files = tmp_ext_dir
  )
  
  return(
    file.path(
      output_dir,
      output_html
    )
  )
}
