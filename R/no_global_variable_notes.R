#' Squash the global variable notes when building a package. 
#' 
if (getRversion() >= "2.15.1") {
  
  # What variables are causing issues?
  variables <- c(
    ".", "value_predict", "set", "importance", "variable", "value", 
    "partial_dependency", "rowid"
  )
  
  # Squash the notes
  utils::globalVariables(variables)
  
}
