
# usedocker

This is an **abandoned** package that I intended to use for simplifying the creation of Dockerfiles for R projects. Please don't use this package. Use [dockyard](https://github.com/thebioengineer/dockyard) instead.

While I don't think this package should ever be installed, it may be have some useful code that can be harvested.

## Design philosophy

My intention was to create a package to lower the barrier of entry to using Docker with R. Naturally, this would have leaned heavily on [the Rocker project](https://www.rocker-project.org/).

I had the following ideas in mind:

* Chain functions together with `%>%`, which would map to Docker commands separated by new lines
* Associate each function with a human-readable _description_. Each command would have default descriptions, although the user can provide their own.
* Take advantage of R's metaprogramming features to make it easier for user's to list arguments, eg. `install_r_packages(plumber)` rather than `install_r_packages("plumber")`
* Keep track of the "status" of the dockerfile using S3 and attributes, to warn users about potential mistakes such as installing an R package before installing R

## Example

``` r
library(usedocker)
library(magrittr)

example <- from_rocker(version = "3.6.2") %>% 
  install_system_dependencies(
    make,
  	libsodium-dev,
  	libicu-dev,
  	libcurl4-openssl-dev,
  	libssl-dev
  ) %>% 
  install_r_packages(plumber, promises, future) %>% 
  docker_env(use_ssl = FALSE) %>% 
  docker_run(
    "groupadd -r plumber && useradd --no-log-init -r -g plumber plumber",
    description = "Creating non-root plumber user"
  )
```

The Dockerfile prints nicely:

``` r
example
#> Start with rocker/r-ver:3.6.2 
#> Install system packages: make, libsodium-dev, libicu-dev, libcurl4-openssl-dev, libssl-dev 
#> Install R packages: plumber, promises, future 
#> Declare environment variable: use_ssl = FALSE 
#> Creating non-root plumber user
```

The raw commands can also be printed:

``` r
print_commands(example)
#> FROM rocker/r-ver:3.6.2 
#> RUN apt-get update && apt-get install -y --no-install-recommends make libsodium-dev libicu-dev libcurl4-openssl-dev libssl-dev 
#> RUN Rscript -e "install.packages('plumber','promises','future')" 
#> ENV use_ssl = 'FALSE' 
#> RUN groupadd -r plumber && useradd --no-log-init -r -g plumber plumber
```
