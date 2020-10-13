#' Set an environment variable in the image build
#'
#' @param dockerfile Object of class "dockerfile". Create a new Dockerfile with
#'   [new_dockerfile()] or [from_rocker()].
#' @param ... Named environment values to declare in the Docker container. These
#'    will be evaluated immediately.
#' @param description Character. Use this description for all environment
#'   variables. This only affects the Dockerfile description, and has no impact
#'   on the actual Dockerfile.
#'
#' @return Object of class "dockerfile"
#' @export
#'
docker_env <- function(dockerfile = new_dockerfile(), ..., description = NULL) {
  dots <- list(...)
  dots_names <- names(dots)
  for (i in seq_along(dots)) {
    env_name <- dots_names[i]
    env_value <- dots[[i]]
    env_value <- as.character(env_value)
    if (is.null(env_name) || env_name == "") {
      stop("environment variables must be given as named arguments")
    }
    env_description <- if (!is.null(description)) {
      description
    } else {
      glue::glue("Declare environment variable: {env_name} = {env_value}")
    }
    dockerfile <- append_dockerfile(
      dockerfile,
      glue::glue("ENV {env_name} = {shQuote(env_value)}"),
      env_description
    )
  }
  dockerfile
}

#' RUN a custom command in image build
#'
#' Information is not shared between `RUN` commands. This means that an
#' environment variable set in one `RUN` command will not be available in
#' another. File system changes will be persisted, however. For example, if a
#' `RUN` command creates a file, that file will be accessible by other `RUN`
#' commands.
#'
#' @param dockerfile Object of class "dockerfile". Create a new Dockerfile with
#'   [new_dockerfile()] or [from_rocker()].
#' @param ... Optionally named commands to `RUN`. Each command will be executed
#'   separately (see Description). Command names are used to label commands in
#'   the Dockerfile description, but have no impact on the actual Dockerfile.
#' @param description Character. Use this description for all commands. This
#'   only affects the Dockerfile description, and has no impact on the actual
#'   Dockerfile.
#'
#' @return Object of class "dockerfile"
#' @export
#'
#' @examples
#' dockerfile <- new_dockerfile()
#' docker_run(dockerfile, 'echo "Giraffes are tall"')
#' docker_run(
#'   dockerfile,
#'   echo_giraffe = 'echo "Giraffes are tall"',
#'   list_files = 'ls'
#' )
#'
docker_run <- function(dockerfile = new_dockerfile(), ..., description = NULL) {
  dots <- list(...)
  dots_names <- names(dots)
  for (i in seq_along(dots)) {
    command_name <- dots_names[i]
    command <- dots[[i]]
    command <- as.character(command)
    command_description <- if (!is.null(description)) {
      description
    } else if (is.null(command_name) || command_name == "") {
      glue::glue("{command}")
    } else {
      glue::glue("{command_name}")
    }
    dockerfile <- append_dockerfile(
      dockerfile,
      glue::glue("RUN {command}"),
      command_description
    )
  }
  dockerfile
}
