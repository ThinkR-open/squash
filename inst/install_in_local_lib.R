if (gert::git_branch() != "production") {
  stop("Don't install in lib unless you're in production !")
} else {
  gert::git_pull()
}

# Installing the package inside the common library
withr::with_libpaths(
  c(
    "/home/rstudio/_libpathcommun_",
    "/usr/local/lib/R/site-library",
    "/usr/local/lib/R/library"
  ),
  {
    remotes::install_local(
      force = TRUE,
      lib = "/home/rstudio/_libpathcommun_"
    )
  }
)

# We launch a vanilla (without .RProfile & RStudio hook) R session to check
# that the package can be launched with just the common libraries
callr::r_vanilla(
  \(x){
    library("squash")
  },
  libpath = c(
    "/home/rstudio/_libpathcommun_",
    "/usr/local/lib/R/site-library",
    "/usr/local/lib/R/library"
  )
)

# Verifying that the correct version has been installed
res <- installed.packages(lib.loc = "/home/rstudio/_libpathcommun_/") |>
  as.data.frame() |>
  dplyr::filter(Package == "squash")
(actual <- read.dcf(file = "DESCRIPTION")[, "Version"])
testthat::expect_true(res$Version == actual)

# Testing that we don't have anything twice
x <- table(
  rownames(installed.packages(lib.loc = c(
    "/home/rstudio/_libpathcommun_",
    "/usr/local/lib/R/site-library",
    "/usr/local/lib/R/library"
  )))
)
testthat::expect_true(
  length(
    names(x[x > 1])
  ) == 0
)


# We also check that everything is 750
testthat::expect_true(
  all(
    fs::dir_info(
      "/home/rstudio/_libpathcommun_/"
    )$permissions == "rwxr-x---"
  )
)
