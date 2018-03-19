#' Function to normalise a variable for "average" meteorological conditions. 
#' 
#' @param model A ranger model object from \code{met_calculate_model}. 
#' 
#' @param df Input data used to calculate \code{model}. 
#' 
#' @param variables Variables to randomly sample. \code{variables} will be all
#' variables used for calculating the model in \code{met_calculate_model} with
#' the exception of \code{date_unix}, the trend term. 
#' 
#' @param n_samples Number of times to sample \code{df} and then predict? 
#' 
#' @param replace Should \code{variables} be sampled with replacement? 
#' 
#' @param n_cores Number of CPU cores to use for the model calculation. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @seealso \code{\link{met_prepare_data}}, \code{\link{met_calculate_model}}
#' 
#' @examples 
#' \dontrun{
#' 
#' # Normalise a time series
#' data_normalised <- met_normalise(
#'   model, 
#'   data_for_modelling, 
#'   n_samples = 300,
#'   n_cores = 7, 
#'   verbose = TRUE
#' )
#' 
#' }
#' 
#' @export
met_normalise <- function(model, df, n_samples = 300, replace = TRUE, 
                          n_cores = NULL, verbose = FALSE) {
  
  # Sample the time series
  if (verbose) message(str_date_formatted(), ": Sampling and predicting...")
  
  df <- purrr::rerun(n_samples) %>% 
    purrr::map_dfr(~met_normalise_worker(
      model = model,
      df = df,
      replace = replace,
      n_cores = n_cores
    )
  )
  
  # Aggregate predictions
  if (verbose) message(str_date_formatted(), ": Aggregating predictions...")
  
  df <- df %>% 
    group_by(date) %>% 
    summarise(value_predict = mean(value_predict, na.rm = TRUE)) %>% 
    ungroup() %>% 
    mutate(n_samples = n_samples)
  
  return(df)
  
}


met_normalise_worker <- function(model, df, variables, replace, n_cores) {
  
  # Randomly sample observations
  n_rows <- nrow(df)
  index_rows <- sample(1:n_rows, replace = replace)
  
  # Transform data frame to include sampled variables
  df[variables] <- lapply(df[variables], function(x) x[index_rows])
  
  # Use model to predict
  value_predict <- met_predict(model, df, n_cores = n_cores)
  
  # Build data frame of predictions
  df <- data.frame(
    date = df$date,
    value_predict = value_predict
  )
  
  return(df)
  
}
