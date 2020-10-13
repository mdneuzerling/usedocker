from_ubuntu <- function(version = "latest") {
  if (!is_valid_ubuntu_version(version)) {
    stop(version, " is not a valid version of Ubuntu. An Ubuntu version must ",
         "either \"latest\", \"devel\" or \"rolling\", a numeric version such ",
         "as \"18.04\", or a code name such as \"bionic\"")
  }
  ubuntu_parent <- glue::glue("ubuntu:{version}")
  dockerfile <- new_dockerfile(parent = ubuntu_parent)
  dockerfile
}

is_valid_ubuntu_version <- function(version) {
  valid_versions <- c(
    "latest", "devel", "rolling",
    "trusty", #14.04
    "xenial", #16.04
    "bionic", #18.04
    "eoan", #19.10
    "focal", #20.04
    "groovy" #20.10
  )
  version_regex_04 <- "^(\\d\\d.)04$"
  version_regex_10 <- "^(\\d\\d.)10$"
  version %in% valid_versions ||
    grepl(version_regex_04, version) ||
    grepl(version_regex_10, version)
}

#' Use rocker as a starting point for a new Dockerfile
#'
#' @param version Character.
#'
#' @return
#' @export
#'
#' @examples
from_rocker <- function(base = c("r-base", "r-devel", "r-ver", "shiny",
                                 "rstudio", "tidyverse", "verse", "geospatial",
                                 "drd", "r-devel-san", "r-devel-ubsan-clang",
                                 "rstudio:testing", "r-apt"),
                        version = "latest") {

  if (!is_valid_r_version(version)) {
    stop(version, " is not a valid version of R. An R version must be either ",
         "\"latest\", \"devel\", or a full version string such as ",
         "\"3.6.2\"")
  }

  base = match.arg(base)

  # r-ver is a versionable alternative to r-base. If a version is provided to
  # r-base, it's better to just use r-ver than to throw an error --- the user's
  # intentions are clear.
  if (base == "r-base" && version != "latest") {
    base <- "r-ver"
  }

  versioned_bases = c("r-ver", "rstudio", "tidyverse", "verse", "geospatial")
  is_versionable <- base %in% versioned_bases
  if (version != "latest" && !is_versionable) {
    stop(base, " only supports the \"latest\" version of R")
  }

  if (is_versionable) {
    rocker_parent <- glue::glue("rocker/{base}:{version}")
  } else {
    rocker_parent <- glue::glue("rocker/{base}")
  }
  dockerfile <- new_dockerfile(parent = rocker_parent)
  dockerfile$r_available = TRUE
  dockerfile
}

tidyverse_packages <- function() {
  character(0) #TODO
}

verse_packages <- function() {
  character(0) #TODO
}

shiny_packages <- function() {
  character(0) #TODO
}

geospatial_packages <- function() {
  character(0) #TODO
}
