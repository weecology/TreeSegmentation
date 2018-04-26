#' Intersection over Union of two polygons
#'
#' \code{IoU} finds the jaccard statistic for two input polygons
#' @param x A SpatialPolygonDataFrame of length 1
#' @param y A SpatialPolygonDataFrame of length 1
#' @return a numeric value indiciating the jaccard overlap
#' @export
IoU<-function(x,y){

  #find area of overlap
  intersection<-raster::intersect(x,y)
  if(is.null(intersection)){
    warning("No intersection, returning zero overlap\n")
    return(0)
  }
  area_intersection<-sum(sapply(intersection@polygons,function(x){x@area}))

  #find area of union
  union_polygon<-raster::union(x,y)
  area_union<-sum(sapply(union_polygon@polygons,function(x){x@area}))

  return(area_intersection/area_union)
}
