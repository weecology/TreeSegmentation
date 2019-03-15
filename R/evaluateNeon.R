#' Wrapper for calculating recall statistics for NEON tree centroids.
#'
#' \code{evaluateNeon} computes an lidar based segmentation, assigns polygons to closest match and calculates recall statistic
#' @param ground_truth SpatialPolygonDataFrame of ground truth polygons
#' @param algorithm  Character. A vector of lidar unsupervised classification algorithm(s). Currently "silva","dalponte","li" and "watershed" are implemented. See \code{\link[lidR]{lastrees}}
#' @param path_to_tiles Character. Location of lidar tiles on system.
#' @param plot_results Logical. Generate a plot of ground truth and predicted polygons
#' @param basemap Character Directory of rgb images for basemap
#' @param extra Logical. Return a list of segmented lidar tiles, predicted convex hull polygons, and the calculated evaluation statistics.
#' @return dataframe of the jaccard overlap among polygon pairs for each selected method. If extra=T, \code{evaluate} will return a list object of results, predicted polygons, as well as output lidR tiles. See e.g. \code{\link{silva2016}}
#' @export
#'
evaluateNeon<-function(trees,plotID,algorithm="silva",path_to_tiles=NULL,extra=F,plot_results=F,basemap="",epsg_numeric=32611){

  #Select points for the plot
  pts<-trees[trees$plotID %in% plotID,]

  if(nrow(pts)==0){
    print("No points in plot")
    return(NULL)
  }

  pts<-SpatialPoints(cbind(pts$UTM_E,pts$UTM_N))

  inpath<-paste(path_to_tiles,plotID,".laz",sep="")

  #Sanity check, does the file exist?
  if(!file_test("-f",inpath)){
    warning(inpath,"does not exist")
    return(NULL)
  }

  #Run segmentation methods
  predictions<-list()
  tiles<-list()
  if("silva" %in% algorithm){
    print("Silva")
    silva<-run_silva2016(path = inpath, epsg_numeric = epsg_numeric)
    predictions$silva<-silva$convex
    tiles$silva<-silva$tile
  }

  if("dalponte" %in% algorithm){
    print("Dalponte")
    dalponte<-run_dalponte2016(path=inpath,epsg_numeric = epsg_numeric)
    predictions$dalponte<-dalponte$convex
    tiles$dalponte<-dalponte$tile
  }

  if("li" %in% algorithm){
    print("li")
    li<-run_li2012(path=inpath,epsg_numeric = epsg_numeric)
    predictions$li<-li$convex
    tiles$li<-li$tile
  }

  if("watershed" %in% algorithm){
    print("Watershed")
    watershed_result<-run_watershed(path=inpath,epsg_numeric = epsg_numeric)
    predictions$watershed<-watershed_result$convex
    tiles$watershed<-watershed_result$tile
  }


  #For each method compute result statistics

  #set CRS
  raster::projection(pts)<-predictions[[1]]@proj4string

  statdf<-list()
  for(i in 1:length(predictions)){
      inside <- !is.na(over(pts, as(predictions[[i]], "SpatialPolygons")))
      Recall<-sum(inside)/length(inside)
      statdf[[i]]<-data.frame(Method=names(predictions)[i],Recall)
  }

  statdf<-dplyr::bind_rows(statdf)

  #if plot, overlay ground truth and predictions
  if(plot_results){
    #which was the best performing method
    best_method<-statdf %>% arrange(desc(Recall))
    ortho<-raster::stack(paste(basemap,plotID,".tif",sep=""))
    svg(paste("plots/Recall/",plotID,".svg",sep=""))
    par(oma=c(0,0,2,0))
    raster::plotRGB(ortho,main=paste(plotID,":",best_method$Method[1],"=",round(best_method$Recall[1],2)),axes=T)
    plot(pts,col="red",add=TRUE,pch=19)
    plot(predictions[[best_method$Method[1]]],add=T,border="white",axes=F)
    title()
    dev.off()
  }

    return(inside)

}
