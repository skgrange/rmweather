#' Function to 
#' 
#' 
#' @param df Input data frame. 
#' 
#' 
#' 
#' 
#' @return Data frame. 
#' 
#' @author Stuart K. Grange
#' 
#' @export
met_partial_dependencies <- function(model, df, variable = NA, two_way = FALSE, 
                                     n_cores = NA, verbose = FALSE) {
  
  if (!"package:ranger" %in% search())
    stop("The ranger package is not loaded...", call. = FALSE)
    
  # Check inputs
  df <- met_check_data(df, prepared = TRUE)
  stopifnot(class(model) == "ranger")
  
  # Default logic for cpu cores
  n_cores <- ifelse(is.na(n_cores), system_cpu_core_count() - 1, n_cores)
  
  # Predict all variables if not given
  if (is.na(variable[1])) variable <- model$forest$independent.variable.names
  
  df_predict <- purrr:::map_dfr(
    variable, 
    ~met_partial_dependencies_worker(
      model = model,
      df = df, 
      variable = .x,
      n_cores = n_cores,
      verbose = verbose
    )
  )
  
  return(df_predict)
  
}


met_partial_dependencies_worker <- function(model, df, variable, n_cores, 
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
  
  # Catch factors, weekday
  if ("factor" %in% class(df_predict$value)) 
    df_predict$value <- as.integer(df_predict$value)
  
  return(df_predict)
  
}
