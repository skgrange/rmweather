#' Function to train a random forest model to predict (usually) pollutant
#' concentrations using meteorological and time variables. 
#' 
#' @param df Input tibble after preparation with \code{\link{rmw_prepare_data}}.
#' \code{df} has a number of constraints which will be checked for before
#' modelling. 
#' 
#' @param variables Independent/explanatory variables used to predict 
#' \code{"value"}. 
#' 
#' @param n_trees Number of trees to grow to make up the forest. 
#' 
#' @param mtry Number of variables to possibly split at in each node. Default is 
#' the (rounded down) square root of the number variables.
#' 
#' @param min_node_size Minimal node size. 
#' 
#' @param keep_inbag Should in-bag data be kept in the \strong{ranger} model 
#' object? This needs to be \code{TRUE} if standard errors are to be calculated
#' when predicting with the model. 
#' 
#' @param n_cores Number of CPU cores to use for the model calculation. Default
#' is system's total minus one. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @author Stuart K. Grange
#' 
#' @return A \strong{ranger} model object, a named list. 
#' 
#' @seealso \code{\link{rmw_prepare_data}}, \code{\link{rmw_normalise}}
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
#' # Calculate a model using common meteorological and time variables
#' model <- rmw_train_model(
#'   data_london_prepared,
#'   variables = c(
#'     "ws", "wd", "air_temp", "rh", "date_unix", "day_julian", "weekday", "hour"
#'   ),
#'   n_trees = 300
#' )
#' 
#' }
#' 
#' @export
rmw_train_model <- function(df, variables, n_trees = 300, mtry = NULL,
                            min_node_size = 5, keep_inbag = TRUE, n_cores = NA, 
                            verbose = FALSE) {
  
  # Check input
  if (verbose) message(str_date_formatted(), ": Checking input data...")
  
  # Extra checks
  if (anyDuplicated(variables) != 0) {
    stop("`variables` contains duplicate elements.", call. = FALSE)
  }
  
  if (!all(variables %in% names(df))) {
    stop("`variables` given are not within input data frame.", call. = FALSE)
  }
  
  # Standard checks
  df <- rmw_check_data(df, prepared = TRUE)
  
  # Filter and select input for modelling
  df <- df %>% 
    filter(set == "training") %>% 
    select(value,
           !!variables)
  
  # Default logic
  n_cores <- as.integer(n_cores)
  n_cores <- if_else(is.na(n_cores), n_cores_default(), n_cores)
  
  if (verbose) message(str_date_formatted(), ": Model training started...")
  
  # Train the model/grow the forest
  model <- ranger::ranger(
    value ~ ., 
    data = df,
    write.forest = TRUE,
    importance = "permutation",
    verbose = verbose,
    num.trees = n_trees,
    mtry = mtry,
    min.node.size = min_node_size,
    splitrule = "variance", 
    seed = NULL,
    keep.inbag = keep_inbag,
    num.threads = n_cores
  )
  
  return(model)
  
}
