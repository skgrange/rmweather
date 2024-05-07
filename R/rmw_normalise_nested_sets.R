#' Function to normalise a variable for "average" meteorological conditions in
#' a nested tibble. 
#' 
#' @author Stuart K. Grange
#' 
#' @param df_nest Nested tibble created by \code{\link{rmw_model_nested_sets}}.
#' 
#' @param variables Variables to randomly sample. Default is all variables used
#' for training the model with the exception of \code{date_unix}, the trend term. 
#' 
#' @param n_samples Number of times to sample \code{df} and then predict? 
#' 
#' @param replace Should \code{variables} be sampled with replacement? 
#' 
#' @param se Should the standard error of the predictions be calculated too? 
#' The standard error method is the "infinitesimal jackknife for bagging" and 
#' will slow down the predictions significantly. 
#' 
#' @param aggregate Should all the \code{n_samples} predictions be aggregated? 
#' 
#' @param keep_samples When \code{aggregate} is \code{FALSE}, should the 
#' sampled/shuffled observations be kept? 
#' 
#' @param n_cores Number of CPU cores to use for the model predictions. Default
#' is system's total minus one. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @param progress Should a progress bar be displayed?
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, 
#' \code{\link{rmw_model_nested_sets}}, \code{\link{rmw_model_nested_sets}}, 
#' \code{\link{rmw_normalise}}.
#' 
#' @return Nested tibble.
#' 
#' @export
rmw_normalise_nested_sets <- function(df_nest, variables = NA, n_samples = 10,
                                      replace = TRUE, se = FALSE, 
                                      aggregate = TRUE, keep_samples = FALSE,
                                      n_cores = NA, verbose = FALSE, 
                                      progress = FALSE) {
  
  # Check input
  if (!all(c("observations", "model") %in% names(df_nest))) {
    cli::cli_abort("Input requires `observations` and `model` variables.")
  }
  
  # Normalise the time series
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Normalising with `{nrow(df_nest)}` model{?s}..."
    )
  }
  
  # Use the vectors directly and put into a tibble
  df_normalised <- purrr::map2(
    df_nest$model,
    df_nest$observations,
    ~rmw_normalise(
      model = .x,
      df = .y,
      variables = variables,
      n_samples = n_samples,
      replace = replace,
      aggregate = aggregate,
      keep_samples = keep_samples,
      n_cores = n_cores,
      verbose = FALSE
    ),
    .progress = progress
  ) %>% 
    purrr::map(~rename(., value_normalised = value_predict)) %>%
    tibble(normalised = .)
  
  # Add normalised time series to nested tibble
  df_nest <- df_nest %>% 
    dplyr::bind_cols(df_normalised) %>% 
    mutate(
      observations = list(left_join(observations, normalised, by = join_by(date)))
    ) %>% 
    select(-normalised)
  
  return(df_nest)
  
}
