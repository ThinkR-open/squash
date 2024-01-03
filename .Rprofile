
if (file.exists("~/.Rprofile")) {
  source("~/.Rprofile")
  if (interactive()) {
  cli::cat_rule("[Rprofile] Sourcing user .Rprofile")
  }
}

if (interactive()) {
  cli::cat_rule("[Rprofile] Sourcing project .Rprofile") 
}

#' Check if quakr is up-to-date
#' 
#' Downloads the last version quakr form github and checks
#' if all files are the same than the current version within the package.
#' 
#' @param branch A character. The name of the quakr branch to 
#' check. Default to "main". If you are using another branch for 
#' dev purpose just provide the name of the branch you are working with.
#' 
#' @return Nothing. Use for its side effects of warning dev if quakr is
#' out of date.
#' 
.check_if_quakr_up_to_date <- function(branch = "main") {
  
  cli::cat_rule(
    sprintf(
      "[Rprofile] Checking in {nq1h} quakr version is up-to-date",
      branch
    )
  )
  
  # Construct url to downlad project wip from github
  zip_file <- sprintf("%s.zip", branch)
  url_quakr <- paste0(
    "https://github.com/",
    "ThinkR-open/quakr/archive/refs/heads/",
    zip_file
  )
  
  # List all files within the quakr extension directory
  quakr_path <- "inst/_extensions/ThinkR-open/thinkridentity/"
  stopifnot(
    file.exists(quakr_path)
  )
  quakr_files <- list.files(
    path = quakr_path,
    full.names = TRUE
  )
  
  # Download the last version of quakr in a temporary directory
  temp_dir <- tempfile()
  dir.create(temp_dir)
  on.exit({
    unlink(
      temp_dir,
      recursive = TRUE, 
      force = TRUE
    )
  })
  cli::cat_rule(
    sprintf(
      "[Rprofile] Downloading last version of quakr@%s",
      branch
    )
  )
  utils::download.file(
    url = url_quakr,
    destfile = file.path(temp_dir, zip_file),
    quiet = TRUE
  )
  
  # List all files within the new package
  withr::with_dir(
    temp_dir,{
      utils::unzip(zip_file)
      downloaded_quakr_files <- list.files(
        path = file.path(
          temp_dir, 
          sprintf("quakr-%s", branch)
        ),
        full.names = TRUE,
        recursive = TRUE
      ) |> 
        grep(
          pattern = "_extension",
          x = _,
          value = TRUE
        )
    })
  
  # Check if all files from the last version of quakr
  # are identical to the current version within {nq1h}
  quakr_up_to_date <- setequal(
    tools::md5sum(downloaded_quakr_files),
    tools::md5sum(quakr_files)
  )
  
  if (isTRUE(quakr_up_to_date)) {
    cli::cli_alert_success(
      sprintf(
        "The package quakr version is up-to-date with ThinkR-open/quakr@%s.",
        branch
      )
    )
  } else {
    cli::cli_alert_danger(
      paste(
        sprintf(
          "The package quakr version is out-of-date compare to ThinkR-open/quakr@%s.",
          branch
        ),
        "Please run the following command in the terminal to update it:",
        "`cd inst/; quarto update ThinkR-open/quakr; cd ..`",
        sep  = "\n"
      )
    )
  }
  
}

if (interactive()) {
  .check_if_quakr_up_to_date()
}


