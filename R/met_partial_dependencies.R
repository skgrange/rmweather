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
met_partial_dependencies <- function(model, df, variable, two_way = FALSE, 
                                   verbose = FALSE) {
  
  # Check inputs
  df <- met_check_data(df, prepared = TRUE)
  stopifnot(class(model) == "ranger")
  
  df_predict <- purrr:::map_dfr(
    variable, 
    ~met_partial_dependencies_worker(
      model = model,
      df = df, 
      variable = .x,
      verbose = verbose
    )
  )
  
  return(df_predict)
  
}


met_partial_dependencies_worker <- function(model, df, variable, verbose) {
  
  if (verbose) message(str_date_formatted(), ": Predicting `", variable, "`...")
  
  df_predict <- pdp::partial(
    model,
    pred.var = variable,
    train = filter(df, set == "training")
  )
  
  # Alter names and add variable
  df_predict <- df_predict %>% 
    setNames(c("value", "partial_dependency")) %>% 
    mutate(variable = !!variable) %>% 
    select(variable, 
           value, 
           partial_dependency)
  
  return(df_predict)
  
}
