#' Title
#'
#' @param parent
#'
#' @return
#' @export
#'
#' @examples
new_dockerfile <- function(parent = NULL) {
  if (is.null(docker_version())) {
    warning("Couldn't find a docker installation. You can still make a ",
            "dockerfile, but it won't be possible to build or run it.")
  }

  new_dockerfile <- list(
    os = character(0),
    commands = character(0),
    description = character(0),
    r_available = FALSE,
    r_packages = character(0),
    python_available = FALSE
  )

  if (!is.null(parent)) {
    new_dockerfile$parent <- parent
    new_dockerfile$commands <- paste("FROM", parent)
    new_dockerfile$description <- glue::glue("Start with {parent}")
  }

  structure(
    new_dockerfile,
    class = "dockerfile"
  )
}

append_dockerfile <- function(dockerfile, command, description) {
  dockerfile$commands <- append(dockerfile$commands, command)
  # Don't use the same description line twice in a row
  last_description <- dockerfile$description[length(dockerfile$description)]
  if (length(last_description) == 0 || description != last_description) {
    dockerfile$description <- append(dockerfile$description, description)
  }
  dockerfile
}

#' Print a dockerfile in a human-readable format
#'
#' @param x
#'
#' @return
#' @export
#'
print.dockerfile <- function(x) {
  for (line in x$description) {
    cat(line, "\n")
  }
}

docker_version <- function() {
  version_regex <- "(\\d+\\.)(\\d+\\.)(\\d+)"
  version_str <- system("docker -v", intern = TRUE) # Not Windows friendly
  version <- regmatches(version_str, regexpr(version_regex, version_str))[1]
  if (length(version) == 0) {
    NULL
  } else {
    version
  }
}

#' Print Docker commands as they would appear in a Dockerfile
#'
#' @param dockerfile
#'
#' @return
#' @export
#'
print_commands <- function(dockerfile) {
  for (command in dockerfile$commands) cat(command, "\n")
}
