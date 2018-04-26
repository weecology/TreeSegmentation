#' Wrapper for calculating overlap among predictiong and ground truth polygons for lidar-based tree segmentation methods
#'
#' \code{evaluate} computes an lidar based segmentation, assigns polygons to closest match and calculates jaccard stat
#' @param ground_truth A SpatialPolygonDataFrame of ground truth polygons
#' @param algorithm A lidar unsupervised classification algorithm. Currently only "silva" is available.
#' @param path_to_tiles Location of lidar tiles on system.
#' @return dataframe of the jaccard overlap among polygon pairs
#' @export
#'
evaluate<-function(ground_truth,algorithm="silva",path_to_tiles=NULL){
  #set file name
  fname<-get_tile_filname(ground_truth)
  inpath<-paste(path_to_tiles,fname,sep="")

  #Does the file exist?
  if(!file_test("-f",inpath)){
    warning(inpath,"does not exist")
    return(NULL)
  }

  if(algorithm=="silva"){
    silva<-silva2016(path=inpath,extra=T)
    prediction<-silva$silva_convex
  }
  assignment<-assign_trees(ground_truth=ground_truth,prediction=prediction)
  statdf<-calc_jaccard(assignment=assignment,ground_truth = ground_truth,prediction=silva$silva_convex)
  return(statdf)
}
