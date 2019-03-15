#' Generate training crop data from lidar tiles
#'
#' \code{training_crops} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @param lidar Character. list of lidar paths
#' @param cores Numeric. Available cores to process data
#' @param expand Numeric. Factor to enlarge (or decrease) bounding box size
#' @export
#'
generate_training<-function(lidar=NULL,algorithm="silva",cores=NULL,expand=1){

  #If running in parallel
  `%dopar%` <- foreach::`%dopar%`
  if(!is.null(cores)){
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }

  result<-foreach::foreach(x=1:length(lidar)) %dopar%{
    training_crops(path_las=lidar[x],expand=expand)
  }

  if(!is.null(cores)){
    doSNOW::StopCluster(cl)
  }

  return(result)
}

