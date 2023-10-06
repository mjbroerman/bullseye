#' my simple function
#'
#' A simple addition function
#'
#' @param a numeric
#' @param b numeric
#'
sum_numbers <- function(a, b) {
  tryCatch({
    as.numeric(a) + as.numeric(b)
  },
  warning = function(e) {
    "not numeric"
  },
  error = function(e) {
    "error"
  })
}
