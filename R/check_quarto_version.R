#' Verify quarto version
#'
#' @importFrom quarto quarto_version
#'
#' @return Null, warn user if quarto version is non compatible
#' @noRd
check_quarto_version <- function() {
  # fetch quarto version
  local_quarto <- quarto_version()

  # raise a warning if quarto version is < 1.3.0
  version_ok <- local_quarto >= numeric_version("1.3.0")

  if (!version_ok) {
    stop(paste0(
      "Your current version of quarto is ",
      local_quarto,
      ", minimal required version is 1.3.0"
    ))
  }
}
