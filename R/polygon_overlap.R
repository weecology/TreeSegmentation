#' Find area of overlap among sets of polygons
#'
#' \code{convex_hull} finds the outer hull of a set of points.
#' @param pol A ground truth polygon
#' @param prediction Whether to plot the results for visualization
#' @return A data frame with the crown ID, the prediction ID and the area of overlap.
#' @export
#' @examples
#'
#' Not usually called directly by user
polygon_overlap<-function(pol,prediction){
  overlap_area<-c()
  for(x in 1:nrow(prediction)){
    pred_poly<-prediction[x,]
    intersect_poly<-suppressWarnings(raster::intersect(pol,pred_poly))
    if(!is.null(intersect_poly)){
      overlap_area[x]<-intersect_poly@polygons[[1]]@area
    } else{
      overlap_area[x]<-0
    }
  }
  data.frame(crown_id=pol@data$crown_id,prediction_id=prediction@data$ID,area=overlap_area)
}
