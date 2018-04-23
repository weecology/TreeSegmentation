#' Find convex hull that outlines an individual tree
#'
#' \code{convex_hull} finds the outer hull of a set of points.
#' @param x A two column matrix with column names "X" and "Y"
#' @param plot Whether to plot the results for visualization
#' @return A \code{\link[sp]{SpatialPolygons}} object containing a convex hull based on input points.
#' @examples
#' Not usually called directly, see \code{\link{get_convex_hulls}}
convex_hull<-function(x,plot=FALSE){
  ch<-chull(x$X,x$Y)
  poly_coords<-x[c(ch,ch[1]),c("X","Y")]
  sp_poly <- SpatialPolygons(list(Polygons(list(Polygon(poly_coords)), ID=1)))
  return(sp_poly)
  if(plot){
    plot(sp_poly)
    points(cbind(x$X,x$Y))
  }
}
