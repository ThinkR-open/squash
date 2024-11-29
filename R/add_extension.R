#' Detect quarto project and add a temporary _extensions directory
#' 
#' @param vec_qmd_path character. Path to the qmd files targeted for compilation
#' @param quiet logical. Warn user of project status.
#' 
#' @importFrom quarto quarto_inspect
#' @importFrom cli cli_alert_info
#' @importFrom purrr map map_lgl
#' @importFrom fs dir_create
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
  
  # sop if not extension dir is provided
  if (is.null(ext_dir)){
    return(NULL)
  }
  
  # look for existing quarto projects
  # _extensions will be added to project root
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
    quarto_ext_added <- file.path(
      qmd_dir,
      "_extensions"
    )
    
    extension_dir_not_found <- !dir.exists(quarto_ext_added)
    
    if (any(extension_dir_not_found)){
      dir_create(quarto_ext_added)
    }
    
    copied_ext <- map(
      .x = quarto_ext_added,
      .f = \(x){
        copy_if_not_already_exist(
          from = ext_dir,
          to = x
        )
      }
    )
    
    if (any(extension_dir_not_found)){
      copied_ext <- c(copied_ext, quarto_ext_added[extension_dir_not_found])
    }

  } else {
    copied_ext <- NULL
  }

  # return list of created dir
  return(as.character(copied_ext))
}
