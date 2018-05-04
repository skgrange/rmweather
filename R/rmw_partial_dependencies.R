#' Function to calculate partial dependencies after training with 
#' \strong{rmweather}. 
#' 
#' \code{rmw_plot_partial_dependencies} is rather slow. 
#' 
#' @param model A ranger model object from \code{\link{rmw_train_model}}. 
#' 
#' @param df Input data frame after preparation with 
#' \code{\link{rmw_prepare_data}}.
#' 
#' @param variable Vector of variables to calculate partial dependencies for. 
#' 
#' @param n_cores Number of CPU cores to use for the model calculation. Default
#' is system's total minus one. 
#' 
#' @param verbose Should the function give messages? 
#' 
#' @return Data frame. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples 
#' 
#' \donttest{
#' 
#' # Calculate partial dependencies for wind speed
#' data_partial <- rmw_partial_dependencies(
#'   model = model, 
#'   df = data_for_modelling,
#'   variable = "ws", 
#'   verbose = TRUE
#' )
#' 
#' # Calculate partial dependencies for all independent variables used in model
#' data_partial <- rmw_partial_dependencies(
#'   model = model, 
#'   df = data_for_modelling,
#'   variable = NA, 
#'   verbose = TRUE
#' )
#' 
#' }
#' 
#' @export
rmw_partial_dependencies <- function(model, df, variable, n_cores = NA, 
                                     verbose = FALSE) {
  
  # Check, predict is a generic function and needs to be loaded
  if (!"package:ranger" %in% search())
    stop("The ranger package is not loaded...", call. = FALSE)
    
  # Check inputs
  df <- rmw_check_data(df, prepared = TRUE)
  stopifnot(class(model) == "ranger")
  
  # Default logic for cpu cores
  n_cores <- ifelse(is.na(n_cores), n_cores_default(), n_cores)
  
  # Predict all variables if not given
  if (is.na(variable[1])) variable <- model$forest$independent.variable.names
  
  df_predict <- purrr::map_dfr(
    variable, 
    ~rmw_partial_dependencies_worker(
      model = model,
      df = df, 
      variable = .x,
      n_cores = n_cores,
      verbose = verbose
    )
  )
  
  return(df_predict)
  
}


rmw_partial_dependencies_worker <- function(model, df, variable, n_cores, 
                                            verbose) {
  
  if (verbose) message(str_date_formatted(), ": Predicting `", variable, "`...")
  
  # Predict
  df_predict <- pdp::partial(
    model,
    pred.var = variable,
    train = filter(df, set == "training"),
    num.threads = n_cores
  )
  
  # Alter names and add variable
  df_predict <- df_predict %>% 
    setNames(c("value", "partial_dependency")) %>% 
    mutate(variable = !!variable) %>% 
    select(variable, 
           value, 
           partial_dependency)
  
  # Catch factors, usually weekday
  if ("factor" %in% class(df_predict$value)) 
    df_predict$value <- as.integer(df_predict$value)
  
  return(df_predict)
  
}
