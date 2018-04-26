if (getRversion() >= "2.15.1") {
  
  # What variables are causing issues?
  variables <- c(
    ".", "value_predict", "set", "importance", "variable", "value", 
    "partial_dependency", "rowid"
  )
  
  # Squash the note
  utils::globalVariables(variables)
  
}
