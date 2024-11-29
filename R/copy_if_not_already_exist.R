#' Copy file or directory if they do not already exist
#' 
#' @param from character. The extensions directory to copy
#' @param to character. The target path to copy to extensions to
#' @param quiet logical. Should the use be warned about pre-existing dir
#' 
#' @importFrom fs dir_ls dir_copy dir_exists
#' @importFrom purrr walk
#' 
#' @return character. Path of added directory.
#' 
#' @noRd
#' @examples
#' tmpdir <- tempfile(pattern = "copy")
#'
#' copy_if_not_already_exist(
#'   from = system.file("_extensions", package = "squash"),
#'   to = file.path(tmpdir, "_extensions")
#' )
#'
#' unlink(tmpdir, recursive = TRUE)
copy_if_not_already_exist <- function(
    from,
    to,
    quiet = FALSE
){

  # list extensions in input dir
  ext_list <- dir_ls(path = from, recurse = 1, type = "directory") |> 
    gsub(pattern = from, replacement = "")
  
  # list extensions already present in target dir
  already_present <- dir_exists(file.path(to, ext_list))
  existing_ext <- ext_list[already_present]
  new_ext <- ext_list[!already_present]
  
  if (length(existing_ext) > 0) {
    if (!quiet){
      cli_alert_info(
        paste(
          "{toString(existing_ext)} extension(s)",
          "already present in quarto project {dirname(to)}.",
          "Using it for compil."
        )
      )
    }
  }
  
  if (length(new_ext) > 0){
    
    walk(
      .x = new_ext,
      .f = \(x){
        dir_copy(path = file.path(from, x),
                 new_path = file.path(to, x)
        )
      }
    )
    
    to_copied_path <- file.path(to, new_ext)
    
  } else {
    to_copied_path <- NULL
  }
  # return path that has been created
  return(to_copied_path)
}
