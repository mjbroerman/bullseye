#' Fetch ZIP file links from a given URL
#'
#' @param base_url The base URL from which to fetch ZIP links.
#' @importFrom rvest read_html html_nodes html_attr
#' @return A character vector containing the full URLs of the ZIP files.
fetch_zip_links <- function(base_url) {
  webpage <- read_html(base_url)
  zip_links <- webpage  |>
    html_nodes("a") |>
    html_attr("href") |>
    grep("zip$", x = _, value = TRUE)
  full_links <- paste0(base_url, zip_links)
  return(full_links)
}

#' Download and unzip a file
#'
#' @param url The URL of the ZIP file to download.
#' @param temp_dir The directory where the ZIP file will be downloaded and unzipped.
#' @return The directory where the unzipped files are stored.
download_and_unzip <- function(url, temp_dir) {
  local_zip <- file.path(temp_dir, basename(url))
  download.file(url, local_zip, mode = "wb")
  local_dir <- file.path(temp_dir, tools::file_path_sans_ext(basename(url)))
  unzip(local_zip, exdir = local_dir)
  return(local_dir)
}

#' Read shapefiles from a directory
#'
#' @param dir_path The directory containing the shapefile (.shp).
#' @importFrom sf st_read
#' @return A simple feature collection.
read_shapefiles <- function(dir_path) {
  shp_file <- list.files(dir_path, pattern = "\\.shp$", full.names = TRUE)
  st_read(shp_file)
}

# TODO: implement somewhere prefilter column, eg. state or county for block groups


#' Main pipeline function for fetching, downloading, and reading shapefiles
#'
#' @param remove_temp Logical; should the temporary directory be removed? Default is FALSE.
#' @param base_url The base URL from which to fetch ZIP links.
#' @param filename The filename for the output GeoParquet file in inst/extdata.
#' @param compression The compression algorithm for GeoParquet. Default is "zstd".
#' @param compression_level The compression level. Default is 6.
#' @param n_limit Optional; limit the number of ZIP files to download. Default is NULL (download all).
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
#' @importFrom geoarrow write_geoparquet
#' @return The output is written as a GeoParquet file.
#'
#' @export
main_pipeline <-
  function(remove_temp = FALSE,
           base_url,
           filename,
           compression = "zstd",
           compression_level = 6,
           n_limit = NULL,
           save = TRUE) {
    temp_dir <- tempdir()
    zip_links <- fetch_zip_links(base_url)

    # Apply n_limit here
    if (!is.null(n_limit)) {
      zip_links <- zip_links[1:n_limit]
    }

    shape_list <- zip_links |>
      purrr::map( ~ download_and_unzip(.x, temp_dir)) |>
      purrr::map( ~ read_shapefiles(.x))

    if (remove_temp) {
      unlink(temp_dir, recursive = TRUE)
    }

    if(save){
      shape_list |>
        dplyr::bind_rows() |>
        geoarrow::write_geoparquet(file.path("inst/extdata", filename),
                                   compression = compression,
                                   compression_level = compression_level)
    }
  }
