#' Function to
#' 
#' 
#' 
#' @export
met_calculate_model <- function(df, variables, trees = 300, mtry = NULL,
                                min_node_size = 5, n_cores = NULL, 
                                verbose = FALSE) {
  
  # Check input...
  
  # Filter and select input for modelling
  df <- df %>% 
    filter(set == "training") %>% 
    select(value,
           !!variables)
  
  if (verbose) message(str_date_formatted(), ": Growing the forest started...")
  
  model <- ranger::ranger(
    value ~ ., 
    data = df,
    write.forest = TRUE,
    importance = "impurity",
    verbose = verbose,
    num.trees = trees,
    mtry = mtry,
    min.node.size = min_node_size,
    num.threads = n_cores
  )
  
  return(model)
  
}
