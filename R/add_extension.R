#' Detect quarto project and add a temporary _extensions directory
#' 
#' @param vec_qmd_path character. Path to the qmd files targeted for compilation
#' @param quiet logical. Warn user of project status.
#' 
#' @importFrom quarto quarto_inspect
#' @importFrom cli cli_alert_info
#' @importFrom purrr map map_lgl
#' 
#' @return Create file path. Side effect : create a yaml compil profile.
#' 
#' @noRd
#' @examples
#' # add a qmd in a tmp dir
#' tmpdir <- tempfile(pattern = "addcompil")
#' dir.create(tmpdir)
#'
#' qmd <- file.path(tmpdir, "dummy.qmd")
#' file.create(qmd)
#' file.create(file.path(tmpdir, "_quarto.yaml"))
#'
#' # init a quarto project
#' add_extension(vec_qmd_path = qmd, quiet = FALSE)
#'
#' # detects pre-existing
#' add_extension(vec_qmd_path = qmd, quiet = FALSE)
#'
#' # cleanup
#' unlink(tmpdir, recursive = TRUE)
add_extension <- function(
  vec_qmd_path,
  ext_dir = system.file("_extensions",
                        package = "squash"),
  quiet = FALSE
  ){
  
  # look for existing quarto projects
  # _extensions will be added to project root if present
  # otherwise, 
  qmd_dir <- dirname(vec_qmd_path)
  
  quarto_proj <- map(
    .x = qmd_dir,
    .f = \(x){
      # return NULL if dir is not a quarto project
      tryCatch(
        expr = {quarto_inspect(x)$dir},
        error = \(e){NULL}
        )
      }
    ) |> as.vector()
  
  no_quarto_proj <- map_lgl(quarto_proj, is.null)
  qmd_dir <- unique(c(qmd_dir[no_quarto_proj], quarto_proj[!no_quarto_proj]))

  # add extension in detected projects
  if (length(qmd_dir) > 0){

    # add quakr extension
    quarto_quakr_added <- file.path(
      qmd_dir,
      "_extensions"
    )
    
    copied_quakr <- map(
      .x = quarto_quakr_added,
      .f = \(x){
        copy_if_not_already_exist(
          from = ext_dir,
          to = x,
          copy_type = "dir"
        )
      }
    )
  } else {
    copied_quakr <- NULL
  }

  # return list of created files
  copied_files <- as.character(copied_quakr)
  return(copied_files)
}
