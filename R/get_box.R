#' Get a bounding box from a data.frame
#'
#' \code{get_box} Takes a data.frame of x,y coordinates and returns the extent
#' @param x data.frame Containing a column of X and Y coordinates
#' @param expand. Numeric. Multiply box size by a factor.
#' @return A list of \code{\link[sp]{SpatialPolygonsDataFrame}} objects containing a bounding box for each defined tree.
#' @export


get_box<-function(x,expand){
  s<-sp::SpatialPoints(cbind(x$X,x$Y))
  e<-raster::extent(s)*expand
  edf<-data.frame(xmin=e@xmin,xmax=e@xmax,ymin=e@ymin,ymax=e@ymax)
  return(edf)
}

