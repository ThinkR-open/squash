#' Fetch future settings
#'
#' @param quiet logical. Warn user of future plan status if non-default.
#'
#' @importFrom cli cli_alert_info cli_alert_warning
#' @importFrom future plan
#'
#' @return Null. Warn user about future setting
#'
#' @noRd
#' @examples
#' fetch_future_settings(vec_qmd_path = qmd, quiet = FALSE)
fetch_future_settings <- function(quiet = TRUE) {
  # look for future settings  (e.g. parallel, sequential, default)
  future_setting <- attr(plan(), "call")
  future_setting <- ifelse(
    test = is.null(future_setting),
    yes = 'plan("default")',
    no = deparse(future_setting)
  )

  if (isFALSE(quiet) && !grepl("sequential", future_setting)) {
    cli_alert_info(paste(
      "{{future}} is using {future_setting},",
      "to modify this use {.code future::plan()}"
    ))
  }
}
