#' Create a themed html from a qmd template
#' 
#' Create a template html with ThinkR styling
#' 
#' @param path_to_qmd character. Path to the qmd template to be rendered in thinkridentity-revealjs
#' @param output_file character. Name of the output html template
#' @param temp_dir character. Path to the temp_dir where template will be rendered
#' 
#' @inheritParams compile_qmd_course
#' 
#' @importFrom quarto quarto_render
#' @importFrom utils download.file unzip
#' @importFrom yaml write_yaml
#'
#' @return character. Path to the html template
#' 
#' @export
#' @examples
#' # create temp dir
#' temp_dir <- tempfile(pattern = "template")
#'
#' # create html template
#' path_to_html_template <- create_template_html(
#'   path_to_qmd = system.file("template.qmd", package = "squash"),
#'   output_dir = temp_dir,
#'   output_file = "complete_course.html"
#' )
#'
#' # clean up
#' unlink(temp_dir, recursive = TRUE)
create_template_html <- function(
  path_to_qmd,
  output_file,
  output_dir,
  output_format = "thinkridentity-revealjs",
  title = "Formation R",
  date = '01/01/01-01/01/01',
  footer = "**<i class='las la-book'></i> Formation R**",
  temp_dir = tempfile(pattern = "template"),
  ext_dir = system.file("_extensions", package = "squash")
  ){
    
  # set qmd file name base on html output name
  output_file_qmd <- gsub("\\.html", "\\.qmd", output_file)
  
  # copy qmd template to temp_dir with new name
  if (!file.exists(temp_dir)){
    dir.create(temp_dir, recursive = TRUE)
  }
  
  file.copy(
    from = path_to_qmd,
    to = file.path(
      temp_dir,
      output_file_qmd)
    )
  
  # copy _extensions folder if present
  dir.create(file.path(temp_dir, "_extensions/"))
  
  file.copy(
    from = ext_dir,
    to = temp_dir,
    recursive = TRUE
  )

  # render template with parameters of quarto project
  quarto_render(
    input = file.path(temp_dir, output_file_qmd),
    quiet = TRUE,
    metadata = list(
      subtitle = date,
      footer = footer
    ),
    quarto_args = c(
      "--metadata",
      paste0("title=", title)
      ),
    output_format = output_format
  )
  
  # copy output html and companion folders to output_dir
  files_to_copy <- c(
    "html" = file.path(temp_dir, output_file),
    "lib_folder" = file.path(temp_dir, gsub("\\.html", "_files", output_file)),
    "ext_folder" = file.path(temp_dir, "_extensions")
  )
  
  if (!file.exists(output_dir)){
    dir.create(output_dir, recursive = TRUE)
  }
  
  file.copy(
    from = files_to_copy,
    to = output_dir,
    recursive = TRUE
  )
  
  # remove temp_dir
  unlink(temp_dir, recursive = TRUE)
  
  # return path to html template
  return(file.path(output_dir, output_file))
}
