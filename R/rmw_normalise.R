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
#' @param n_cores Number of CPU cores to use for the model predictions. Default
#' is system's total minus one. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @seealso \code{\link{rmw_prepare_data}}, \code{\link{rmw_train_model}}
#' 
#' @examples 
#' \dontrun{
#' 
#' # Normalise a time series
#' data_normalised <- rmw_normalise(
#'   model, 
#'   data_for_modelling, 
#'   n_samples = 300,
#'   verbose = TRUE
#' )
#' 
#' }
#' 
#' @export
rmw_normalise <- function(model, df, variables = NA, n_samples = 300, 
                          replace = TRUE, n_cores = NA, verbose = FALSE) {
  
  # Check inputs
  df <- rmw_check_data(df, prepared = TRUE)
  stopifnot(class(model) == "ranger")
  
  # Default logic for cpu cores
  n_cores <- ifelse(is.na(n_cores), system_cpu_core_count() - 1, n_cores)
  
  # Use all variables except the trend term
  if (is.na(variables[1])) {
    
    # Get model's variables
    variables <- model$forest$independent.variable.names
    
    # Drop trend component
    variables <- setdiff(variables, "date_unix")
    
  }
  
  # Sample the time series
  if (verbose)
    message(str_date_formatted(), ": Sampling and predicting ", n_samples, " times...")
  
  # Do
  df <- seq_len(n_samples) %>% 
    purrr:::map_dfr(
      ~rmw_normalise_worker(
        index = .x,
        model = model,
        df = df,
        variables = variables,
        replace = replace,
        n_cores = n_cores,
        n_samples = n_samples,
        verbose = verbose
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


rmw_normalise_worker <- function(index, model, df, variables, replace, n_cores, 
                                 n_samples, verbose) {
  
  if (verbose) {
    
    # Calculate percent
    message_precent <- round((index / n_samples) * 100, 2)
    # Always have 2 dp
    message_precent <- format(message_precent, nsmall = 1) 
    message_precent <- stringr::str_c(message_precent, " %")
    
    # Print
    message(
      str_date_formatted(), 
      ": Predicting ", 
      index, 
      " of ", 
      n_samples, 
      " times (", 
      message_precent, 
      ")..."
    )
    
  }
  
  # Randomly sample observations
  n_rows <- nrow(df)
  index_rows <- sample(1:n_rows, replace = replace)
  
  # Transform data frame to include sampled variables
  df[variables] <- lapply(df[variables], function(x) x[index_rows])
  
  # Use model to predict
  value_predict <- rmw_predict(model, df, n_cores = n_cores)
  
  # Build data frame of predictions
  df <- data.frame(
    date = df$date,
    value_predict = value_predict,
    stringsAsFactors = FALSE
  )
  
  return(df)
  
}
