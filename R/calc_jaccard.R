#' Collect jaccard statistic for ground truth and prediction polygons
#'
#' \code{calc_jaccard} finds the jaccard statistic for two input polygons, defined as the area of intersection over the area of union.
#' @param assignment A dataframe that connects ground truth and prediction poylgons see \code{\link{assign_trees}} SpatialPolygonDataFrame of length 1
#' @param ground_truth A SpatialPolygonDataFrame of ground truth polygons
#' @param prediction A SpatialPolygonDataFrame of ground truth polygons
#' @return dataframe of the jaccard overlap among polygon pairs
#' @export
calc_jaccard<-function(assignment,ground_truth,prediction){
  jaccard_stat<-c()
  for(i in 1:nrow(assignment)){
    polygon_row<-assignment[i,]
    x<-ground_truth[ground_truth$crown_id==polygon_row$crown_id,]
    y<-prediction[prediction$ID==polygon_row$prediction_id,]
    jaccard_stat[i]<-IoU(x,y)
  }

  statdf<-data.frame(crown_id=assignment$crown_id,prediction_id=assignment$prediction_id,IoU=jaccard_stat)
  return(statdf)
}
