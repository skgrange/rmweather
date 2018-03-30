#' Function to train a random forest model to predict (usually) pollutant
#' concentrations using meteorological and time variables and then immediately
#' normalise a variable for "average" meteorological conditions. 
#' 
#' @param df Input data frame after preparation with 
#' \code{\link{rmw_prepare_data}}. \code{df} has a number of constraints which 
#' will be checked for before modelling. 
#' 
#' @param variables Independent/explanatory variables used to predict 
#' \code{"value"}. 
#' 
#' @param n_trees Number of trees to grow to make up the forest. 
#' 
#' @param min_node_size Minimal node size. 
#' 
#' @param mtry Number of variables to possibly split at in each node. Default is 
#' the (rounded down) square root of the number variables.
#' 
#' @param n_samples Number of times to sample \code{df} and then predict? 
#' 
#' @param replace Should \code{variables} be sampled with replacement? 
#' 
#' @param n_cores Number of CPU cores to use for the model calculation. Default
#' is system's total minus one. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Named list. 
#' 
#' @seealso \code{\link{rmw_prepare_data}}, \code{\link{rmw_normalise}}
#' 
#' @export
rmw_do_all <- function(df, variables, n_trees = 300, min_node_size = 5, 
                       mtry = NULL, n_samples = 300, replace = TRUE, 
                       n_cores = NA, verbose = FALSE) {
  
  # Get date
  date_start <- as.numeric(lubridate::now())
  
  # Train model
  model <- rmw_train_model(
    df,
    variables = variables,
    n_trees = n_trees,
    mtry = mtry,
    min_node_size = min_node_size,
    n_cores = n_cores,
    verbose = verbose
  )
  
  # Clear
  gc()
  
  # Get date
  date_post_training <- as.numeric(lubridate::now())
  
  # Normalise time series
  df_normalised <- rmw_normalise(
    model, 
    df, 
    variables = NA,
    n_samples = n_samples,
    replace = replace,
    n_cores = n_cores,
    verbose = verbose
  )
  
  # Get date
  date_post_normalise <- as.numeric(lubridate::now())
  
  # Build timing data frame
  df_times <- data.frame(
    date_start,
    date_post_training,
    date_post_normalise
  ) %>% 
    mutate(time_elasped_training = date_post_training - date_start,
           time_elapsed_normalising = date_post_normalise - date_post_training,
           time_elapsed_total = date_post_normalise - date_start)
  
  # Create list
  list_normalisation <- list(
    observations = df,
    model = model,
    normalised = df_normalised,
    elapsed_times = df_times
  )
  
  return(list_normalisation)
  
}
