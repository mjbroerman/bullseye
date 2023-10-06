# plumber.R
library(sf)
library(geoarrow)
library(bullseye)
library(jsonlite)
library(plumber)

filepath <- system.file("extdata", "test_cen.parquet", package = "bullseye")
poly_db <- read_geoparquet_sf(filepath)

#* Receive a data frame, perform operation, and return a modified data frame
#* @param df: Data frame with id, lat, and lng
#* @post /compute
function(req, res) {

  # Try to parse the JSON body to a data frame
  df <- tryCatch({
    fromJSON(req$postBody, flatten = TRUE)
  }, error = function(e) {
    res$status <- 400
    return(list(error = "Invalid JSON format"))
  })

  # Ensure df has the expected columns
  if (!all(c("id", "lat", "lng") %in% names(df))) {
    res$status <- 400
    return(list(error = "Input data frame must have id, lat, and lng columns"))
  }

  # Convert df to sf object
  # coords <- df[, c("lng", "lat"), drop = FALSE]
  # your_sf_obj <- st_as_sf(df, coords = coords, crs = 4326)
  coordinates <- st_sfc(st_point(c(df$lng[1], df$lat[1])), st_point(c(df$lng[2], df$lat[2])))
  your_sf_obj <- st_sf(id = df[, "id"], geometry = coordinates, crs = 4326)

  # Apply the combined_spatial_join function
  joined_data <- bullseye::combined_spatial_join(pts_sf = your_sf_obj, polys_sf = poly_db, return_col = "GEOID")

  # Get the latitude and longitude from the geometry
  joined_data$lat <- st_coordinates(joined_data$geometry)[, "Y"]
  joined_data$lng <- st_coordinates(joined_data$geometry)[, "X"]

  # Create a final result data frame
  df_result <- data.frame(
    id = df$id,
    lat = joined_data$lat,
    lng = joined_data$lng,
    GEOID = joined_data$GEOID
  )

  # Handle NA/NULL GEOID - if needed, adapt accordingly
  df_result$GEOID[is.na(df_result$GEOID)] <- "Not available"

  # Return the resulting data frame as a JSON object
  return(df_result)
}
