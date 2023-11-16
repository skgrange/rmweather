#' Function to make predictions by meteorological year from a random forest 
#' models using a nested tibble.
#' 
#' @param df_nest Nested tibble created by \code{\link{rmw_model_nested_sets}}.
#' 
#' @param variables Variables to randomly sample. Default is all variables used
#' for training the model with the exception of \code{date_unix}, the trend term. 
#' 
#' @param n_samples Number of times to sample the observations from each 
#' meteorological year and then predict. 
#' 
#' @param aggregate Should all the \code{n_samples} predictions be aggregated? 
#' 
#' @param n_cores Number of CPU cores to use for the model calculations. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @seealso \code{\link{rmw_nest_for_modelling}}, 
#' \code{\link{rmw_model_nested_sets}}
#' 
#' @author Stuart K. Grange
#' 
#' @return Nested tibble. 
#' 
#' @export
rmw_predict_nested_sets_by_year <- function(df_nest, variables = NA, 
                                            n_samples = 10, aggregate = TRUE,
                                            n_cores = NULL, verbose = FALSE) {
  
  # Check input
  if (!all(c("observations", "model") %in% names(df_nest))) {
    cli::cli_abort("Input requires `observations` and `model` variables.")
  }
  
  # Add normalised set to nested input
  df_nest <- df_nest %>% 
    mutate(
      normalised_met_year = list(
        rmw_predict_nested_sets_by_year_worker(
          model,
          observations,
          variables = variables,
          n_samples = n_samples,
          aggregate = aggregate,
          n_cores = n_cores,
          verbose = verbose
        )
      )
    )
  
  return(df_nest)
  
}


rmw_predict_nested_sets_by_year_worker <- function(model, df, variables, 
                                                   n_samples, aggregate, n_cores,
                                                   verbose) {

  # Get model's variables
  if (is.na(variables[1])) {
    variables <- model$forest$independent.variable.names
  }
  
  # Get years to sample for
  years_met <- df %>% 
    pull(date) %>% 
    lubridate::year() %>% 
    unique() %>% 
    purrr::set_names(.)
  
  # Two levels of iteration here, pass the year_met to be sampled n times
  df_predict <- years_met %>% 
    purrr::map(
      ~predict_using_a_met_year_worker(
        model = model,
        df = df,
        year_met = .,
        variables = variables,
        n_samples = n_samples,
        aggregate = aggregate,
        n_cores = n_cores,
        verbose = verbose
      )
    ) %>% 
    purrr::list_rbind(names_to = "year_met")
  
  return(df_predict)
  
}


predict_using_a_met_year_worker <- function(model, df, year_met, 
                                            variables, n_samples, aggregate, 
                                            n_cores, verbose) {
  
  # A message to users
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Sampling and predicting using `{year_met}`'s observations... "
    )
  }
  
  # Build a named index
  index <- seq_len(n_samples)
  index <- purrr::set_names(index, index)
  
  # Do the sampling n times (from n_samples)
  df <- index %>% 
    purrr::map(
      ~predict_using_a_met_year_prediction_worker(
        model = model,
        df = df,
        year_met = year_met,
        variables = variables,
        n_cores = n_cores
      )
    ) %>% 
    purrr::list_rbind(names_to = "n_sample")
  
  # Aggregate the predictions
  if (aggregate) {
    df <- df %>% 
      group_by(date) %>% 
      summarise(value_predict = mean(value_predict, na.rm = TRUE),
                .groups = "drop")
  }
  
  return(df)
  
}


predict_using_a_met_year_prediction_worker <- function(model, df, year_met, 
                                                       variables, n_cores) {
  
  # Check inputs
  stopifnot(c("date", "date_unix", "value") %in% names(df))
  
  # Get the concentrations, the complete time series
  df_values <- df %>% 
    select(date,
           value)
  
  # Get met data for the target met year
  df_met <- df %>% 
    filter(lubridate::year(date) == !!year_met) %>% 
    select(!!variables,
           date,
           -date_unix)
  
  # How many values to we have?
  n_values <- nrow(df_values)
  n_met <- nrow(df_met)
  
  # Number of times to replicate each observation
  n_replicate <- ceiling(n_values / n_met)
  
  # Replicate the met data, immediately sample the entire set, and make sure
  # the sampled set has the same length as the values tibble
  df_met_replicate <- df_met %>% 
    dplyr::slice(rep(1:dplyr::n(), each = n_replicate)) %>% 
    dplyr::sample_frac(size = 1, replace = FALSE) %>% 
    dplyr::slice(1:n_values) %>% 
    select(-date)
  
  # Bind
  df_bind <- df_values %>% 
    dplyr::bind_cols(df_met_replicate) %>% 
    mutate(date_unix = as.numeric(date))
  
  # Predict the concentrations on sampled set
  value_predict <- rmweather::rmw_predict(
    model, df = df_bind, n_cores = n_cores, verbose = FALSE
  )
  
  # Build the tibble return
  df <- df_bind %>% 
    select(date) %>% 
    mutate(value_predict = !!value_predict)
  
  return(df)
  
}
