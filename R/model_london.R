#' Example \strong{ranger} random forest model for the \strong{rmweather} 
#' package.
#' 
#' This example object was created from the observational data included in 
#' \strong{rmweather} and is a random forest model returned by 
#' \code{\link{rmw_train_model}}. This forest is only made from one tree to keep
#' the file size small and is only used for the package's examples. 
# 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{data_london}}, \code{\link{rmw_train_model}}
#' 
#' @format A ranger object, a named list with 14 elements. 
#' 
#' @examples 
#' 
#' # Load rmweather's ranger model example data and see what elements it contains
#' names(model_london)
#' 
#' # Print ranger object
#' print(model_london)
#' 
"model_london"
