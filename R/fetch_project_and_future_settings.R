#' List detected quarto project and fetch future settings
#' 
#' @param vec_qmd_path character. Path to the qmd files targeted for compilation
#' @param quiet logical. Warn user of project status.
#' 
#' @importFrom quarto quarto_inspect
#' @importFrom cli cli_alert_info cli_alert_warning
#' @importFrom purrr map map_lgl
#' @importFrom future plan
#' 
#' @return List of quarto projects detected for each qmd.
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
#' fetch_project_and_future_settings(vec_qmd_path = qmd, quiet = FALSE)
#'
#' # cleanup
#' unlink(tmpdir, recursive = TRUE)
fetch_project_and_future_settings <- function(
  vec_qmd_path,
  quiet = TRUE
  ){
  
  # look for existing quarto projects
  # _extensions will be added to project root
  qmd_dir <- unique(dirname(vec_qmd_path))
  
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
  
  dir_is_proj <- !map_lgl(quarto_proj, is.null)
  qmd_proj_dir <- unique(c(qmd_dir[!dir_is_proj], quarto_proj[dir_is_proj]))

  # look for future settings  (e.g. parallel, sequential, default)
  future_setting <- attr(plan(), "call")
  future_setting <- ifelse(
    test = is.null(future_setting),
    yes = 'plan("default")',
    no = deparse(future_setting)
  )
  
  if (isFALSE(quiet)){
    cli_alert_info(paste(
      "{{future}} is using {future_setting},",
      "to modify this use {.code future::plan()}"
    ))
  }
  
  return(qmd_proj_dir)
}
