#' Generate training crop data from lidar tiles
#'
#' \code{training_crops} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree. It then writes the resulting files in h5 format for machine learning input
#' @param lidar Character. list of lidar paths
#' @param rgb Character. list of rgb image paths
#' @param hyperspec Character. list of hyperspec paths
#' @param cores Numeric. Available cores to process data
#' @param outdir Character. Location on disk to write training crops
#' @return Writes training crops to file
#' @export
#'
generate_training<-function(lidar=NULL,rgb=NULL,hyperspec=NULL,algorithm="silva",cores=NULL,outdir=NULL,write=T){

  #check if lists are of same length
  assertthat::are_equal(len(lidar),len(rgb))

  #If running in parallel
  `%dopar%` <- foreach::`%dopar%`
  if(!is.null(cores)){
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }

  result<-foreach(x=1:length(lidar)) %dopar%{
    training_crops(path_lidar=lidar[x],path_rgb=rgb[x],path_hyperspec=hyperspec[x],write=T,outdir=outdir)
  }

  if(!is.null(cores)){
    doSNOW::StopCluster(cl)
  }

  return(result)
}

