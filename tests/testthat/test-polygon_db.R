test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("querying works", {

  coords_w_state <- make_coords()

  # TODO: version below requires prefiltering, not yet implemented

  # load_filtered_sf <- function(dataset_path, state_code) {
  #   open_dataset(dataset_path) |>
  #     filter(STATEFP %in% state_code) |>
  #     select(GEOID, ADI_NATRANK, ADI_STATERNK, geometry) |>
  #     geoarrow_collect_sf()
  # }
  #
  # create_results_table <- function(sp_join, coords_sf, extra_info) {
  #   res_sp_join <- map(sp_join, function(x) if(length(x) == 0) NA_integer_ else x)
  #   res <- enframe(res_sp_join) |>
  #     mutate(value = unlist(value)) |>
  #     bind_cols(coords_sf) |>
  #     left_join(extra_info, by = c("value" = "all_indices"))
  #   return(res)
  # }
  #
  # get_state_codes <- function(coords_w_state){
  #   coords_w_state |>
  #     distinct(state) |>
  #     left_join(state_fips_df) |>
  #     pull(fips)
  # }




})
