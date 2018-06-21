#' Function to train a random forest model to predict (usually) pollutant
#' concentrations using meteorological and time variables and then immediately
#' normalise a variable for "average" meteorological conditions. 
#' 
#' \code{rmw_do_all} is a user-level function to conduct the meteorological 
#' normalisation process in one step. 
#' 
#' @param df Input data frame after preparation with 
#' \code{\link{rmw_prepare_data}}. \code{df} has a number of constraints which 
#' will be checked for before modelling. 
#' 
#' @param variables Independent/explanatory variables used to predict 
#' \code{"value"}. 
#' 
#' @param variables_sample Variables to use for the normalisation step. If not 
#' used, the default of all variables used for training the model with the 
#' exception of \code{date_unix}, the trend term (see 
#' \code{\link{rmw_normalise}}).
#' 
#' @param n_trees Number of trees to grow to make up the forest. 
#' 
#' @param min_node_size Minimal node size. 
#' 
#' @param mtry Number of variables to possibly split at in each node. Default is 
#' the (rounded down) square root of the number variables.
#' 
#' @param keep_inbag Should in-bag data be kept in the \strong{ranger} model 
#' object? This needs to be \code{TRUE} if standard errors are to be calculated
#' when predicting with the model. 
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
#' @param n_cores Number of CPU cores to use for the model calculation. Default
#' is system's total minus one. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return Named list. 
#' 
#' @seealso \code{\link{rmw_prepare_data}},  \code{\link{rmw_train_model}}, 
#' \code{\link{rmw_normalise}}
#' 
#' @examples 
#' 
#' \donttest{
#' 
#' # Keep things reproducible
#' set.seed(123)
#' 
#' # Prepare example data
#' data_london_prepared <- rmw_prepare_data(data_london, value = "no2")
#' 
#' # Use the example data to conduct the steps needed for meteorological
#' # normalisation
#' list_normalised <- rmw_do_all(
#'   df = data_london_prepared,
#'   variables = c(
#'     "ws", "wd", "air_temp", "rh", "date_unix", "day_julian", "weekday", "hour"
#'   ),
#'   n_trees = 300,
#'   n_samples = 300
#' )
#' 
#' }
#' 
#' @export
rmw_do_all <- function(df, variables, variables_sample = NA, n_trees = 300, 
                       min_node_size = 5, mtry = NULL, keep_inbag = TRUE,
                       n_samples = 300, replace = TRUE, se = FALSE, 
                       aggregate = TRUE, n_cores = NA, verbose = FALSE) {
  
  # Check inputs
  if (se && !keep_inbag) {
    
    stop(
      "To calculate standard errors, `keep_inbag` needs to be `TRUE`...", 
      call. = FALSE
    )
    
  }
  
  # Get date
  date_start <- as.numeric(lubridate::now())
  
  # Train model
  model <- rmw_train_model(
    df,
    variables = variables,
    n_trees = n_trees,
    mtry = mtry,
    min_node_size = min_node_size,
    keep_inbag = keep_inbag,
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
    variables = variables_sample,
    n_samples = n_samples,
    replace = replace,
    se = se,
    aggregate = aggregate,
    n_cores = n_cores,
    verbose = verbose
  )
  
  # Get date
  date_post_normalise <- as.numeric(lubridate::now())
  
  # Build timing data frame
  df_times <- data.frame(
    hostname = as.character(Sys.info()["nodename"]),
    date_start,
    date_post_training,
    date_post_normalise,
    stringsAsFactors = FALSE
  ) %>% 
    mutate(time_elasped_training = date_post_training - date_start,
           time_elapsed_normalising = date_post_normalise - date_post_training,
           time_elapsed_total = date_post_normalise - date_start)
  
  # Create list
  list_normalisation <- list(
    observations = df,
    model = model,
    n_samples = as.integer(n_samples),
    normalised = df_normalised,
    elapsed_times = df_times
  )
  
  return(list_normalisation)
  
}
