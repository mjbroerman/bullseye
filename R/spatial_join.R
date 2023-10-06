#' Combined Spatial Join with Pre-filtering
#'
#' Performs a combined spatial join of points to polygons with optional
#' pre-filtering based on a shared attribute column.
#'
#' @param pts_sf An sf object containing the point geometries.
#' @param polys_sf An sf object containing the polygon geometries.
#' @param prefilter_col Character string specifying the name of the column
#' used for pre-filtering. If the column is present in the points dataset,
#' points will be filtered to match unique values from the polygons dataset.
#' Default is NULL, meaning no pre-filtering will occur.
#'
#' @return A dataframe containing the result of the spatial join.
#' @importFrom sf st_set_geometry st_as_sf
#' @importFrom rsgeo as_rsgeo contains_sparse
#' @importFrom dplyr filter mutate bind_cols left_join distinct select
#' @importFrom purrr map
#' @importFrom tibble add_column enframe
#' @importFrom rlang sym
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example usage, replace with real datasets
#' result <- combined_spatial_join(pts_sf = sample_pts,
#'                                polys_sf = sample_polys,
#'                                prefilter_col = "example_col")
#' }

combined_spatial_join <- function(pts_sf, polys_sf, prefilter_col = NULL, return_col) {

  # Prepare by pre-filtering if possible
  if (!is.null(prefilter_col) && prefilter_col %in% names(pts_sf)) {
    all_unique_vals <- unique(polys_sf[[prefilter_col]])
    pts_prep_sf <- pts_sf |> dplyr::filter(!!rlang::sym(prefilter_col) %in% all_unique_vals)
  } else {
    pts_prep_sf <- pts_sf
  }

  # Convert to rsgeo objects and fast join
  poly_rs <- as_rsgeo(polys_sf)
  points_rs <- as_rsgeo(pts_prep_sf)
  result_rs <- contains_sparse(points_rs, poly_rs)

  # Get indices from funny result
  ind_non_empty <- which(sapply(result_rs, length) > 0)
  ind_all <- unlist(result_rs)
  ind_match <- map(result_rs, function(x) if(length(x) == 0) NA_integer_ else x)

  # Filter and index points and db
  pts_filt_sf <- pts_prep_sf[ind_all, ] |>
    add_column(ind_all) |>
    st_set_geometry(NULL) |>
    distinct()

  poly_filt_sf <- polys_sf[ind_non_empty,] |>
    add_column(ind_all) |>
    st_set_geometry(NULL) |>
    distinct()

  # Combine match indices with input points, then join on the results
  joint <- enframe(ind_match) |>
    mutate(value = unlist(value)) |>
    bind_cols(pts_sf) |>
    left_join(pts_filt_sf, by = c("value" = "ind_all")) |>
    left_join(poly_filt_sf, by = c("value" = "ind_all"))

  # select
  if(!is.null(prefilter_col) && prefilter_col %in% names(joint)) {
    selected_data <- dplyr::select(joint, !!rlang::sym(prefilter_col), {{return_col}}, geometry)
  } else {
    selected_data <- dplyr::select(joint, {{return_col}}, geometry)
  }

  res <- sf::st_as_sf(selected_data)

  return(res)
}
