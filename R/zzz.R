#' Verify quarto version
#'
#' @param lib lib
#' @param pkg pkg
#'
#' @return Null, warn user if quarto version is non compatible
#' @noRd
.onLoad <- function(lib, pkg) {
  check_quarto_version()
}
