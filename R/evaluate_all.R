#' Wrapper among tiles for calculating overlap among predicted and ground truth polygons for lidar-based tree segmentation methods
#'
#' \code{evaluate_all} extends evaluate to multiple tiles, optionally run in parallel.
#' @param itcs A SpatialPolygonDataFrame of ground truth polygons
#' @param cores Optional parameter to specify the number of cores to parallelize using \code{\link[foreach]{foreach}}
#' @inheritParams evaluate
#' @return dataframe of the jaccard overlap among polygon pairs
#' @export
#'
evaluate_all<-function(itcs,algorithm = "silva",path_to_tiles=NULL,cores=NULL,compute_consensus=F,extra=F){

  #If running in parallel
  if(!is.null(cores)){
    `%dopar%` <- foreach::`%dopar%`
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }
  results<-foreach::foreach(i=1:length(itcs),.packages=c("TreeSegmentation","sp")) %dopar% {
    ground_truth<-itcs[[i]]
    TreeSegmentation::evaluate(ground_truth=ground_truth,algorithm=algorithm,path_to_tiles=path_to_tiles,compute_consensus = compute_consensus,extra=extra)
  }
  results<-dplyr::bind_rows(results)
  return(results)
}
