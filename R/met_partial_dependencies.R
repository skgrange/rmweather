met_partial_dependencies <- function(model, variable) {
  
  pdp::partial(
    model,
    pred.var = variable
  )
  
}
