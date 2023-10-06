## code to prepare `al_coord` dataset goes here

make_coords <- function(state = "AL", n_points = 1000){
  if (state == "AL"){
    # Define the bounding box for Alabama approximately
    lat_min <- 30.2
    lat_max <- 35.0
    lon_min <- -88.5
    lon_max <- -84.9

    # Generate random coordinates within the bounding box
    set.seed(123)
    latitudes <- runif(n_points, lat_min, lat_max)
    longitudes <- runif(n_points, lon_min, lon_max)

    # Create an sf
    data.frame(lon = longitudes, lat = latitudes) |>
      st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
      # TODO implement use of `state_fips_lookup`
      mutate(STATEFP = "01")

  } else NULL
}

al_coord <- make_coords()

usethis::use_data(al_coord, overwrite = TRUE)
