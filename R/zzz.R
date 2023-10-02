.onLoad <- function(lib, pkg){
  # fetch quarto version
  local_quarto <- quarto::quarto_version()

  # raise a warning if quarto version is < 1.3.0
  version_ok <-  local_quarto >= numeric_version("1.3.0")

  if (!version_ok){
    warning("Your current version of quarto is ", local_quarto, ", minimal required version is 1.3.0")
  }
}
