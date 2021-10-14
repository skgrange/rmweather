#' Function to calculate observed-predicted error statistics. 
#' 
#' @param df Data frame with observed-predicted variables. 
#' 
#' @param value_model The modelled/predicted variable in \code{"df"}. 
#' 
#' @param value_observed The observed variable in \code{"df"}. 
#' 
#' @author Stuart K. Grange
#' 
#' @return Tibble. 
#' 
#' @export
rmw_calculate_model_errors <- function(df, value_model = "value_predict", 
                                       value_observed = "value") {
  
  # Check input
  if (!all(c(value_model, value_observed) %in% names(df))) {
    stop("`value_model` or `value_observed` not found in the input.", call. = FALSE)
  }
  
  # Get observed mean for extra calculation
  mean_observed <- df %>% 
    select(!!value_observed) %>% 
    pull() %>% 
    mean(na.rm = TRUE)
  
  # Use openair to do the calculations and do some cleaning afterwards
  df %>% 
    openair::modStats(
      mod = value_model, obs = value_observed, 
      statistic = c("MB", "NMB", "MGE", "NMGE", "RMSE", "r", "COE", "IOA")
    ) %>% 
    select(-default) %>% 
    rename(mean_bias = MB,
           normalised_mean_bias = NMB,
           mean_gross_error = MGE,
           normalised_mean_gross_error = NMGE,
           root_mean_squared_error = RMSE,
           coefficient_of_efficiency = COE,
           index_of_agreement = IOA) %>% 
    mutate(
      normalised_root_mean_squared_error = root_mean_squared_error / !!mean_observed,
      r_squared = r ^ 2
    ) %>% 
    relocate(normalised_root_mean_squared_error,
             .after = root_mean_squared_error) %>% 
    relocate(r_squared,
             .after = r) %>% 
    as_tibble()
  
}
