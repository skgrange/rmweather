#' Function to print messages before a CRAN submission. 
#' 
#' @details Not to be exported. 
#' 
#' 
release_questions <- function() {
  
  c(
    "Has README.md been updated?",
    "Has NEWS.md been updated?",
    "Has win-builder been used?", 
    "Have all changes been commited to git?"
  )
  
}
