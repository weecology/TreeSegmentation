#' Find area of overlap among sets of polygons
#'
#' \code{convex_hull} is a wrapper function to iterate through a SpatialPolygonsDataFrame
#' @param pol A ground truth polygon
#' @param prediction prediction polygons
#' @return A data frame with the crown ID, the prediction ID and the area of overlap.
#' @examples
#'
#' @export
polygon_overlap_all<-function(ground_truth,prediction){
  results<-list()
  for(x in 1:nrow(ground_truth)){
    results[[x]]<-polygon_overlap(ground_truth[x,],prediction)
  }
  return(dplyr::bind_rows(results))
}
