#' Clean folder after quarto rendering
#' 
#' Remove all the files and folders created when rendering a qmd to html
#' 
#' @param dir character. The directory to look for rendering output recursively.
#' @param present_before character. Path to the files and directories present before rendering.
#' @param extra_files character. Path of additional files to remove.
#' 
#' @return None. Side effect: remove files that were not present before rendering
#' 
#' @export
#' @examples
#' # create a temp dir with qmd
#' temp_dir <- tempfile(pattern = "clean")
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
#' # list files before rendering
#' file_and_dirs_before <- list.files(
#'   temp_dir,
#'   recursive = TRUE,
#'   full.names = TRUE,
#'   include.dirs = TRUE
#' )
#'
#' # render qmd
#' quarto::quarto_render(
#'   input = file.path(temp_dir, "C01-qmd1_for_test.qmd"),
#'   quiet = TRUE
#' )
#'
#' # remove created files and dirs
#' clean_rendering_files(
#'   dir = temp_dir,
#'   present_before = file_and_dirs_before
#' )
#'
#' # clean temp dir
#' unlink(temp_dir, recursive = TRUE)
clean_rendering_files <- function(
    dir,
    present_before,
    extra_files = NULL
){

  # list files
  present_after <- unique(
    list.files(
      path = dir,
      full.names = TRUE,
      recursive = TRUE,
      include.dirs = TRUE
    )
  )
  
  file_created_by_rendering <- setdiff(
    x = present_after,
    y = path.expand(present_before)
  )
  
  unlink(
    x = file_created_by_rendering,
    recursive = TRUE
  )
  
  unlink(
    x = extra_files,
    recursive = TRUE
  )
  
}
