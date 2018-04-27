#' Wrapper for calculating overlap among predictiong and ground truth polygons for lidar-based tree segmentation methods
#'
#' \code{evaluate} computes an lidar based segmentation, assigns polygons to closest match and calculates jaccard stat
#' @param ground_truth SpatialPolygonDataFrame of ground truth polygons
#' @param algorithm  Character. A vector of lidar unsupervised classification algorithm(s). Currently "silva","dalponte","li" and "watershed" are implemented. See \code{\link[lidR]{lastrees}}
#' @param path_to_tiles Character. Location of lidar tiles on system.
#' @param compute_consensus Generate a consensus from selected methods, see \code{\link{consensus}}.
#' @param extra logical. Indicating whether convexs and lidar tiles should be returned
#' @return dataframe of the jaccard overlap among polygon pairs for each selected method. If extra=T, \code{evaluate} will return a list object of results, predicted polygons, as well as output lidR tiles.
#' @export
#'
evaluate<-function(ground_truth,algorithm="silva",path_to_tiles=NULL,compute_consensus=F,extra=F){
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
  tiles<-list()
  if("silva" %in% algorithm){
    print("silva")
    silva<-silva2016(path=inpath,extra=T)
    predictions$silva<-silva$convex
    tiles$silva<-silva$tile
  }

  if("dalponte" %in% algorithm){
    print("Dalpone")
    dalponte<-dalponte2016(path=inpath,extra=T)
    predictions$dalponte<-dalponte$convex
    tiles$dalponte<-dalponte$tile
  }

  if("li" %in% algorithm){
    print("li")
    li<-li2012(path=inpath,extra=T)
    predictions$li<-li$convex
    tiles$li<-li$tile
  }

  if("watershed" %in% algorithm){
    print("watershed")
    watershed_result<-watershed(path=inpath,extra=T)
    predictions$watershed<-watershed_result$convex
    tiles$watershed<-watershed_result$tile
  }

  if(compute_consensus){
    print("consensus")
    tiles$consensus<-consensus(ptlist=tiles)

    #create consensus polygons
    predictions$consensus<-get_convex_hulls(tiles$consensus,tiles$consensus@data$treeID)
  }

  #For each method compute result statistics
  statdf<-list()
  for(i in 1:length(predictions)){

    #Assign ground truth based on overlap
    assignment<-assign_trees(ground_truth=ground_truth,prediction=predictions[[i]])
    statdf[[i]]<-calc_jaccard(assignment=assignment,ground_truth = ground_truth,prediction=predictions[[i]]) %>% mutate(Method=names(predictions)[i])
  }

  statdf<-dplyr::bind_rows(statdf)

  if(extra){
    return(list(results=statdf,predictions=predictions,tiles=tiles))
  } else{
    return(statdf)
  }

}
