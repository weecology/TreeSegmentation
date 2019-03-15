#' Wrapper among tiles for calculating overlap among predicted and ground truth polygons for lidar-based tree segmentation methods
#' \code{evaluate_all} extends evaluate to multiple tiles, optionally run in parallel.
#' @param itcs A SpatialPolygonDataFrame of ground truth polygons
#' @param cores Optional parameter to specify the number of cores to parallelize using \code{\link[foreach]{foreach}}
#' @inheritParams evaluate
#' @return dataframe of the jaccard overlap among polygon pairs
#' @export
evaluate_all<-function(itcs,algorithm = "silva",path_to_tiles=NULL,cores=NULL,extra=F,plot_results=F,basemap=""){

  #If running in parallel
  `%dopar%` <- foreach::`%dopar%`
  if(!is.null(cores)){
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }
  results<-foreach::foreach(i=1:length(itcs),.packages=c("TreeSegmentation","sp","lidR"),.errorhandling = "remove") %dopar% {
    ground_truth<-itcs[[i]]
    TreeSegmentation::evaluate(ground_truth=ground_truth,algorithm=algorithm,path_to_tiles=path_to_tiles,extra=extra,plot_results=plot_results,basemap=basemap)
  }

  #Report empty results
  #print(paste("ITC",which(sapply(results,is.null)),"has no overlap with cropped tile"))

  #remove empty results
  results<-results[!sapply(results,is.null)]

  #bind into single list
  results<-dplyr::bind_rows(results)

  #Stop cluster if needed
  if(!is.null(cores)){
    parallel::stopCluster(cl)
  }
  return(results)
}
