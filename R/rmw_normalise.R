#' Function to normalise a variable for "average" meteorological conditions. 
#' 
#' @param model A ranger model object from \code{\link{rmw_train_model}}. 
#' 
#' @param df Input data used to calculate \code{model} using 
#' \code{\link{rmw_prepare_data}}.
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
#' @param verbose Should the function give messages and display a progress bar? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Tibble. 
#' 
#' @seealso \code{\link{rmw_prepare_data}}, \code{\link{rmw_train_model}}
#' 
#' @examples 
#' 
#' \donttest{
#' 
#' # Load package
#' library(dplyr)
#' 
#' # Keep things reproducible
#' set.seed(123)
#' 
#' # Prepare example data
#' data_london_prepared <- data_london %>% 
#'   filter(variable == "no2") %>% 
#'   rmw_prepare_data()
#' 
#' # Normalise the example no2 data
#' data_normalised <- rmw_normalise(
#'   model_london, 
#'   df = data_london_prepared, 
#'   n_samples = 300,
#'   verbose = TRUE
#' )
#' 
#' }
#' 
#' @export
rmw_normalise <- function(model, df, variables = NA, n_samples = 300, 
                          replace = TRUE, se = FALSE, aggregate = TRUE, 
                          keep_samples = FALSE, n_cores = NA, verbose = FALSE) {
  
  # Check inputs
  df <- rmw_check_data(df, prepared = TRUE)
  stopifnot(class(model) == "ranger")
  
  # Default logic for cpu cores
  n_cores <- as.integer(n_cores)
  n_cores <- if_else(is.na(n_cores), n_cores_default(), n_cores)
  
  # `keep_samples` can only be true when `aggregate` is false
  if (keep_samples && aggregate) {
    cli::cli_alert_info(
      "{str_date_formatted()}: `keep_samples` has been set to `FALSE` because `aggregate` is `TRUE`..."
    )
    keep_samples <- FALSE
  }
  
  # Use all variables except the trend term in default usage
  if (is.na(variables[1])) {
    # Get model's variables
    variables <- model$forest$independent.variable.names
    # Drop trend component
    variables <- setdiff(variables, "date_unix")
  }
  
  # Sample the time series
  if (verbose) {
    cli::cli_alert_info(
      "{str_date_formatted()}: Sampling and predicting `{n_samples}` time{?s}..."
    )
  }
  
  # If no samples are passed
  if (n_samples == 0) {
    df <- tibble()
  } else {
    
    # Do, not piping seq_len due to a package check note
    df <- seq_len(n_samples) %>% 
      purrr::map(
        ~rmw_normalise_worker(
          index = .x,
          model = model,
          df = df,
          variables = variables,
          replace = replace,
          se = se,
          n_cores = n_cores,
          n_samples = n_samples,
          keep_samples = keep_samples
        ),
        .progress = verbose
      ) %>% 
      purrr::list_rbind(names_to = "n_sample")
    
    # Aggregate predictions
    if (aggregate) {
      
      if (verbose) {
        cli::cli_alert_info("{str_date_formatted()}: Aggregating predictions...")
      }
      
      df <- df %>% 
        select(-n_sample) %>% 
        group_by(date) %>% 
        dplyr::summarise_if(is.numeric, ~mean(., na.rm = TRUE)) %>% 
        ungroup()
      
    }
    
  }
  
  return(df)
  
}


rmw_normalise_worker <- function(index, model, df, variables, replace, 
                                 n_samples, se, keep_samples, n_cores) {
  
  # Randomly sample observations
  n_rows <- nrow(df)
  index_rows <- sample(1:n_rows, replace = replace)
  
  # Transform data frame to include sampled variables
  df[variables] <- lapply(df[variables], function(x) x[index_rows])
  
  # Use model to predict
  value_predict <- rmw_predict(model, df, se = se, n_cores = n_cores)
  
  # Build data frame of predictions
  if (inherits(value_predict, "list")) {
    # With se
    df_predict <- tibble(
      date = df$date,
      se = value_predict$se,
      value_predict = value_predict$predictions
    )
  } else {
    # Without se
    df_predict <- tibble(
      date = df$date,
      value_predict = value_predict
    )
  }
  
  # If desired, keep the sampled/shuffled tibble and join the predictions to it
  if (keep_samples) {
    df_predict <- left_join(df, df_predict, by = join_by(date))
  }
  
  return(df_predict)
  
}
