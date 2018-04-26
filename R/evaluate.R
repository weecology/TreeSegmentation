#' Wrapper for calculating overlap among predictiong and ground truth polygons for lidar-based tree segmentation methods
#'
#' \code{evaluate} computes an lidar based segmentation, assigns polygons to closest match and calculates jaccard stat
#' @param ground_truth A SpatialPolygonDataFrame of ground truth polygons
#' @param algorithm A character or vector of lidar unsupervised classification algorithm(s). Currently only "silva" is implemented.
#' @param path_to_tiles Location of lidar tiles on system.
#' @return dataframe of the jaccard overlap among polygon pairs for each selected method
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

  #Run segmentation methods
  predictions<-list()
  if("silva" %in% algorithm){
    predictions$silva<-silva2016(path=inpath)
  }

  if("dalponte" %in% algorithm){
    predictions$dalponte<-dalponte2016(path=inpath)
  }

  if("li" %in% algorithm){
    predictions$li<-li2012(path=inpath)
  }

  #For each method compute result statistics
  statdf<-list()
  for(i in 1:length(predictions)){

    #Assign ground truth based on overlap
    assignment<-assign_trees(ground_truth=ground_truth,prediction=predictions[[i]])
    statdf[[i]]<-calc_jaccard(assignment=assignment,ground_truth = ground_truth,prediction=predictions[[i]]) %>% mutate(Method=algorithm[i])
  }

  statdf<-dplyr::bind_rows(statdf)
  return(statdf)
}
