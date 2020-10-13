#' Install system depedencies
#'
#' @param dockerfile
#' @param ...
#' @param description
#'
#' @return
#' @export
#'
install_system_dependencies <- function(dockerfile, ..., description = NULL) {
  # This is how data.frame captures ...
  packages <- as.list(substitute(list(...)))[-1L]
  if (length(packages) == 0) return(dockerfile) # no packages declared
  # R interprets - as subtraction, but it's a common symbol in system packages
  # We remove the space around it to coerce it back to a hyphen.
  packages <- lapply(packages, function(x) gsub(" - ", "-", deparse(x)))

  install_packages_command <- paste(
    "RUN apt-get update &&",
    "apt-get install -y --no-install-recommends",
    paste(packages, collapse = ' ')
  )

  if (is.null(description)) {
    description <- glue::glue(
      "Install system packages: {paste(packages, collapse = ', ')}"
    )
  }

  append_dockerfile(dockerfile, install_packages_command, description)
}
