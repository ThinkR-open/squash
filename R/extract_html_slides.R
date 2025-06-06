#' Extract html slide content
#'
#' Extract slide content from multiple html
#'
#' @param vec_html_path character. The vector of path to individual html files
#' @param use_metadata logical. Use the keywords metadata for building the slide's url
#'
#' @importFrom tools file_ext
#' @importFrom rvest read_html html_elements html_children html_attr
#' @importFrom htmltools HTML
#'
#' @return HTML. The HTML slide content of all html files combined together.
#'
#' @export
#' @examples
#' # list html files
#' courses_path <- system.file(
#'   "courses",
#'   package = "squash"
#' )
#'
#' htmls <- list.files(
#'   path = courses_path,
#'   full.names = TRUE,
#'   recursive = TRUE,
#'   pattern = "html$"
#' )
#'
#' html_slide_content <- extract_html_slides(vec_html_path = htmls)
extract_html_slides <- function(
  vec_html_path,
  use_metadata = TRUE
) {
  # verify path are html files
  not_all_files_are_html <- any(
    file_ext(vec_html_path) != "html"
  )
  if (isTRUE(not_all_files_are_html)) {
    stop("Some of the input files are not html files.")
  }

  # extract all slides elements
  list_html_slides <- lapply(
    X = vec_html_path,
    FUN = \(html_path) {
      html_path |>
        read_html() |>
        html_elements(".slides") |>
        html_children() |>
        as.character()
    }
  )

  # use simple numbering for title slide id
  list_slide_id <- paste0(
    "title-slide-",
    as.character(seq_along(vec_html_path))
  )

  if (use_metadata) {
    # replace simple numbering by keyword metadata
    list_slide_keywords <- lapply(
      X = vec_html_path,
      FUN = \(html_path) {
        meta <- html_path |>
          read_html() |>
          html_elements("meta")
        meta_name <- html_attr(meta, name = "name")
        meta_content <- html_attr(meta, name = "content")
        keyword <- meta_content[meta_name == "keywords" & !is.na(meta_name)]
        paste0(keyword, collapse = "-")
      }
    )

    index_with_keyword <- which(list_slide_keywords != "")
    list_slide_id[index_with_keyword] <- list_slide_keywords[index_with_keyword]

    # detect non-unique keywords
    dup_keywords <- anyDuplicated(list_slide_id)
    if (dup_keywords != 0) {
      stop(
        "Some keywords are not unique : ",
        toString(list_slide_id[dup_keywords])
      )
    }
  }

  # edit content for proper slide formating
  list_html_slides <- lapply(
    X = seq_along(list_html_slides),
    FUN = \(slide_number) {
      list_html_slides[[slide_number]] |>
        # add chapter number as prefix to avoid duplicated subtitles across htmls
        gsub(
          pattern = "<section id=\"([^\"]*)\"([^>]*)>",
          replacement = paste0("<section id=\"", slide_number, "-\\1\"\\2>")
        ) |>
        # rename 1st slide with keyword or chapter number
        gsub(
          pattern = paste0(slide_number, "-title-slide"),
          replacement = list_slide_id[[slide_number]]
        )
    }
  )

  # compile all slides content into a single HTML text
  html_content <- list_html_slides |>
    unlist() |>
    paste0(collapse = "\n") |>
    HTML()

  return(html_content)
}
