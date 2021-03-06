
#' geometries
#'
#' Converts a data.frame into a collection of geometries.
#'
#' @param obj data.frame
#' @param id_cols vector of id columns (either integer or string)
#' @param geometry_cols vector of geometry columns (either integer or string)
#' @param class_attributes class attributes to assign to each geometry
#' @param close logical stating if the last row must equal the first row of each geometry
#' @param closed_attribute logical, if true a 'has_been_closed' attribute is added to each
#' matrix that has been closed.
#'
#' @return A list of matrices representing the input object, split by the id column(s).
#'
#' @examples
#'
#' df <- data.frame(
#'   id = c(1,1,1,1,1,2,2,2,2,2)
#'   , x = 1:10
#'   , y = 10:1
#' )
#'
#' gm_geometries(
#'   df
#'   , id_cols = c(1L)
#'   , geometry_cols = c(2L,3L)
#' )
#'
#' ## Adding a class attribute
#' gm_geometries(
#'   df
#'   , id_cols = c(1)
#'   , geometry_cols = c(2,3)
#'   , list( class = "my_line_object" )
#'  )
#'
#' ## Adding a second ID column
#' df$id1 <- c(1,1,1,2,2,1,1,2,2,3)
#'
#' gm_geometries(
#'   df
#'   , id_cols = c(1,4)
#'   , geometry_cols = c(2,3)
#'   , list( class = "my_multiline_object" )
#' )
#'
#' ## Using character column names
#' gm_geometries(
#'   df
#'   , id_cols = c("id","id1")
#'   , geometry_cols = c("x","y")
#'   )
#'
#' ## matrix input
#' m <- as.matrix( df )
#' gm_geometries(
#'   m
#'   , id_cols = c("id","id1")
#'   , geometry_cols = c("x","y")
#'   )
#'
#' gm_geometries(
#'   m
#'   , id_cols = c(1,4)
#'   , geometry_cols = c(2,3)
#'  )
#'
#' ## use close to make the last row the same as the first row
#' df <- data.frame(
#'   id = c(1,1,1,1)
#'   , x = c(1,1,2,2)
#'   , y = c(1,2,2,1)
#' )
#'
#' gm_geometries(
#'   df
#'   , id_cols = "id"
#'   , geometry_cols = c("x","y")
#'   , close = TRUE
#' )
#'
#'
#' @export
gm_geometries <- function( obj, id_cols, geometry_cols, class_attributes = list(), close = FALSE, closed_attribute = FALSE ) {
  id_cols <- index_correct( obj, id_cols )
  geometry_cols <- index_correct( obj, geometry_cols )
  return( rcpp_make_geometries( obj, id_cols, geometry_cols, class_attributes, close, closed_attribute ) )
}


## convert R-index to c++-index integer
index_correct <- function( obj, cols ) {

  if( is.null( cols ) ) {
    stop("columns can't be NULL")
  }

  if( is.numeric( cols ) ) {
    if( any( cols == 0 ) ) {
      stop("invalid column index")
    }
    return( as.integer( cols ) - 1L )
  }

  if( inherits( obj, "data.frame" ) ) {
    #if( is.character( cols ) ) {
      ##
      return( which(names(obj) %in% cols ) - 1L )
    #}
    ## return( cols ) ## can't get here
  } else {
    ## matrix && character cols
    n <- dimnames( obj )[[2]]
    return( which(n %in% cols ) - 1L )
  }
}

