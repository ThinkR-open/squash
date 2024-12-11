#' Copy img to root img directory and edit path in html
#'
#' @param html_path character. Path to html file.
#' @param img_root_dir character. Path to img root dir
#'
#' @importFrom purrr map discard walk2
#' @importFrom rvest html_attr read_html html_elements
#' @importFrom stats setNames
#' @importFrom dplyr filter
#'
#' @return None. Side effet : edit img path in html.
#' @export
copy_img_and_edit_path <- function(
  html_path,
  img_root_dir
) {
  # set image sub-folder name
  chapter <- dirname(html_path)

  img_dir <- file.path(
    img_root_dir,
    paste0(basename(chapter), "_img")
  )

  # read html image path
  img_list <- html_path |>
    read_html() |>
    html_elements("img")

  img_df <- map(
    .x = c("src", "data-src", "class"),
    .f = \(x){
      img_list |> html_attr(x)
    }
  ) |>
    setNames(c("src", "data", "img_class")) |>
    data.frame()

  img_path <- discard(unique(c(img_df$src, img_df$data)), is.na)

  # correct the ones not in img_root_dir
  img_correct_path <- grepl(pattern = paste0("^", img_dir), x = img_path)
  img_to_fix <- img_path[!img_correct_path]

  if (length(img_to_fix) > 0) {
    html_content <- readLines(html_path, warn = FALSE)

    walk2(
      .x = file.path(dirname(html_path), img_to_fix),
      .y = file.path(dirname(html_path), img_dir, img_to_fix),
      .f = \(x, y){
        dir.create(dirname(y), recursive = TRUE, showWarnings = FALSE)
        file.copy(from = x, to = y, overwrite = TRUE)
      }
    )

    html_content <- gsub(
      pattern = paste0('"(', paste0(img_to_fix, collapse = "|"), ')"'),
      replacement = paste0('"', img_dir, "\\/", "\\1", '"'),
      x = html_content
    )

    writeLines(text = html_content, con = html_path)
  }
}
