#' Function to nest observational data before modelling with \strong{rmweather}.
#' 
#' \code{rmw_nest_for_modelling} will resample the observations if desired, will
#' test and prepare the data (with \code{\link{rmw_prepare_data}}), and return
#' a nested tibble ready for modelling.
#' 
#' @param df Input data frame. Generally a time series of air quality data with 
#' pollutant concentrations and meteorological variables.
#' 
#' @param by Variables within \code{df} which will be used for nesting. 
#' Generally, \code{by} will be \code{"site"} and \code{"variable"}. 
#' \code{"resampled_set"} will always be added for clarity. 
#' 
#' @param n Number of resampling sets to create. 
#' 
#' @param na.rm Should missing values (NA) be removed from value?
#' 
#' @param fraction Fraction of the observations to make up the training set.
#'  
#' @author Stuart K. Grange
#' 
#' @return Nested tibble. 
#' 
#' @seealso \code{\link{rmw_prepare_data}}, \code{\link{rmw_model_nested_sets}}, 
#' \code{\link{rmw_predict_nested_sets}}
#' 
#' @examples 
#' 
#' # Load package
#' library(dplyr)
#' 
#' # Keep things reproducible
#' set.seed(123)
#'
#' # Prepare example data for modelling, replicate observations twice too
#' data_london %>% 
#'   rmw_nest_for_modelling(by = c("site", "variable"), n = 2)
#'  
#' @export
rmw_nest_for_modelling <- function(df, by = "resampled_set", n = 1, 
                                   na.rm = FALSE, fraction = 0.8) {
  
  # Check input
  n <- as.integer(n)
  stopifnot(!is.na(n))
  
  # A check, this keyword causes issues in the splitting function
  if ("fraction" %in% names(df)) {
    stop("Input cannot contain a variable called `fraction`.", call. = FALSE)
  }
  
  # Add resampled_set to by if it does not exist
  if (!"resampled_set" %in% by) by <- c("resampled_set", by)

  # Replicate table if needed
  if (n == 1L) {
    # Just add a identifier
    df_sampled <- mutate(df, resampled_set = 1L)
  } else {
    # Reproduce tibble n times
    df_sampled <- purrr::map_dfr(1:n, ~df, .id = "resampled_set") %>% 
      mutate(resampled_set = as.integer(resampled_set))
  }
  
  # Check if all variables are there
  if (!all(by %in% names(df_sampled))) {
    stop(
      "The variables requested for nesting are not contained in the input.", 
      call. = FALSE
    )
  }
  
  # Nest the tibble
  df_nest <- df_sampled %>% 
    dplyr::nest_by(across(dplyr::all_of(by)),
                   .key = "observations") %>% 
    mutate(
      observations = list(
        rmw_prepare_data(observations, na.rm = na.rm, fraction = fraction
      )
    )
  )
  
  return(df_nest)
  
}
