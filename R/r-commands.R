#' Install R
#'
#' This command should not be used with Rocker parent images, as these already
#' have R installed.
#'
#' @param version
#'
#' @return
#'
#' @importFrom magrittr %>%
#' @export
#'
install_r <- function(dockerfile, version = "latest") {
  if (!is_valid_r_version(version)) {
    stop(version, " is not a valid version of R. An R version must be ",
         "either \"latest\", \"devel\", or a full version string such as ",
         "\"3.6.2\"")
  }

  if (dockerfile$r_available) {
    warning("This Dockerfile already contains a step for installing R, or ",
            "uses a parent image with R installed.")
  }

  # Configure default locale, see https://github.com/rocker-org/rocker/issues/19
  configure_locale <- paste('RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  && locale-gen en_US.utf8
  && /usr/sbin/update-locale LANG=en_US.UTF-8')

  make_r <- glue::glue("cd R-{version} && \
    ./configure \
    --prefix=/opt/R/{version} \
    --enable-memory-profiling \
    --enable-R-shlib \
    --with-blas \
    --with-lapack && \
    make && \
    make install")

  dockerfile <- dockerfile %>%
    docker_run("Configure locale to UTF-8" = configure_locale) %>%
    docker_env(
      LC_ALL = "en_US.UTF-8",
      LANG = "en_US.UTF-8",
      description = "Configure locale to UTF-8"
    ) %>%
    install_system_dependencies(apt-get, build-dep, r-base, curl) %>%
    docker_run(
       glue::glue("curl -O https://cran.rstudio.com/src/base/R-3/R-{version}.tar.gz"),
       glue::glue("tar -xzvf R-${version}.tar.gz"),
       description = glue::glue("Download and unpack R {version}")
    ) %>%
    docker_run(
      "Install R from source" = make_r,
      "Put R in PATH" = glue::glue("ln -s /opt/R/{version}/bin/R /usr/local/bin/R"),
      "Put R in PATH" = glue::glue("ln -s /opt/R/{version}/bin/Rscript /usr/local/bin/Rscript")
    )

  dockerfile$r_available = TRUE
  dockerfile
}

#' Install R packages in a Docker image
#'
#' Use a dockerfile that installs R before attempting to install R packages.
#' This can be done by `[install_r()]`, or by using a dockerfile that started with
#' `[from_rocker()]`.
#'
#' @param dockerfile Object of class "dockerfile".
#' @param ... Unquoted package names.
#' @param CRAN Character. Optionally specify a CRAN repository from which to
#'   install
#'
#' @return
#' @export
#'
#' @examples
install_r_packages <- function(dockerfile,
                               ...,
                               CRAN = NULL,
                               description = NULL) {
  if (!dockerfile$r_available) {
    warning("Installing R packages before R will be installed in the image. ",
            "This will probably fail on build.")
  }

  # This is how data.frame captures ...
  packages <- as.list(substitute(list(...)))[-1L]
  if (length(packages) == 0) return(dockerfile) # no packages declared
  package_strings <- paste(paste0("'", packages, "'"), collapse = ",")
  install_package_command <- if (is.null(CRAN)) {
    paste0("install.packages(", package_strings, ")")
  } else {
    paste0(
      "install.packages(",
      package_strings,
      "repos = c(CRAN = '", CRAN, "'))"
    )
  }

  if (is.null(description)) {
    description <- glue::glue(
      "Install R packages: {paste(packages, collapse = ', ')}"
    )
  }

  dockerfile <- append_dockerfile(
    dockerfile,
    glue::glue("RUN Rscript -e {shQuote(install_package_command)}"),
    description
  )
  dockerfile$r_packages = append(dockerfile$r_packages, unlist(packages))
  dockerfile
}

is_valid_r_version <- function(version) {
  version_regex <- "^(\\d+\\.)(\\d+\\.)(\\d+)$"
  if (version %in% c("latest", "devel")) {
    TRUE
  } else if (grepl(version_regex, version)) {
    TRUE
  } else {
    FALSE
  }
}

recommended_r_packages <- function() {
  character(0) #TODO
}
