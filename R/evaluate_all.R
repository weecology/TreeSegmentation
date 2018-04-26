#' Wrapper among tiles for calculating overlap among predictiong and ground truth polygons for lidar-based tree segmentation methods
#'
#' \code{evaluate_all} extends evaluate to multiple tiles
#' @param ground_truth A SpatialPolygonDataFrame of ground truth polygons
#' @param algorithm A lidar unsupervised classification algorithm. Currently only "silva" is available.
#' @param path_to_tiles Location of lidar tiles on system.
#' @return dataframe of the jaccard overlap among polygon pairs
#' @export
#'
evaluate_all<-function(itcs,algorithm = "silva",path_to_tiles=NULL,cores=NULL){

  #If running in parallel
  if(!is.null(cores)){
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }
  results<-foreach(i=1:length(itcs)){
    ground_truth<-itcs[[i]]
    evaluate(ground_truth=ground_truth,algorithm=algorithm,path_to_tiles=path_to_tiles)
  }
  results<-dplyr::bind_rows(results)
  return(results)
}
