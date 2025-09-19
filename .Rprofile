if (Sys.info()[['nodename']] == 'fedora') {
  # options(
  #   repos = c(
  #     CRAN = "https://packagemanager.posit.co/cran/__linux__/manylinux_2_28/latest"
  #   )
  # )
  renv::lockfile_modify(
    repos = c(
      P3M = "https://packagemanager.posit.co/cran/__linux__/manylinux_2_28/latest"
    )
  ) |>
    renv::lockfile_write()
}
# source("renv/activate.R")
