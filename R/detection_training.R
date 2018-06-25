#' Generate detection network training files
#'
#' \code{detection training} is the pipeline for generating training data for a detection based nueral net (RCNN).
#' @param path Character Location of the lidar tile to process.
#' @param expand Numeric.
#' @inheritParams treeClusters
#' @return A .csv file is written to disk containing detections
#' @export
#'
#'
detection_training<-function(path,threshold=15,res=2,expand=1){
  tile<-lidR::readLAS(path)
  algorithm<-"silva"

  #normalize
  ground_model(tile,ground=F)

  #Find tree clusters from canopy height model
  tclusters<-treeClusters(path=path,threshold=threshold,res=res,expand=expand)

  #make sure boxes aren't off edges
  e<-raster::extent(tile)

  tclusters[tclusters$xmin < e@xmin,]<-e@xmin
  tclusters[tclusters$ymin < e@ymin,]<-e@ymin
  tclusters[tclusters$xmin > e@xmax,]<-e@xmax
  tclusters[tclusters$xmin > e@ymax,]<-e@ymax

  print(paste(nrow(tclusters),"clusters found in",path))

  #Crop out lidar cloud
  crops<-list()
  for(x in 1:nrow(tclusters)){
    row<-tclusters[x,]
    crops[[x]]<-lidR::lasclipRectangle(tile,xleft=row$xmin,xright=row$xmax,ybottom=row$ymin,ytop=row$ymax)
  }

  #For each crop compute silva segmentation
  result<-list()
  for(x in 1:length(crops)){
    print(paste("Cluster",x))
    result[[x]]<-silva2016(tile=crops[[x]],output = "tile",ground=F)
  }

  print("Tree Segmentation Complete")
  #plot(result[[1]],color="treeID",size=3)

  #get list of tree points
  las_trees<-lapply(result,function(x){
    trees<-split(x@data, x@data$treeID)
    trees<-bind_rows(trees) %>% select(X,Y,Z,treeID)
  })

  print(paste(length(las_trees),"trees predicted"))

  #Label clusters and bind together
  for(x in 1:length(las_trees)){
    las_trees[[x]]$Cluster<-x
  }

  las_trees<-dplyr::bind_rows(las_trees)

  #Get bounding box around each tree id
  las_trees<-las_trees %>% group_by(Cluster,treeID) %>% do(get_box(.,expand=1))

  #Append cluster bounding box, rename to make it clearer the different in extents
  tclusters<-tclusters %>% select(Cluster=Index,cluster_xmin=xmin,cluster_xmax=xmax,cluster_ymin=ymin,cluster_ymax=ymax)
  boxes<-las_trees %>% inner_join(tclusters) %>% rename(box=treeID)

  print("Bounding boxes complete")

  #get the corresponding orthophoto naming
  boxes$lidar_path<-stringr::str_match(path,"\\/(\\w+.laz)")[,2]
  boxes$rgb_path<-convert_names(from="lidar",to="rgb",lidar=path)

  #label
  boxes$label<-"Tree"

  #give the results a filename and label the lidar tile
  sanitized_fn<-stringr::str_extract(string=path,pattern="(NEON.*)")
  sanitized_fn<-stringr::str_replace_all(sanitized_fn,"\\.","_")

  #Format according the keras-retinet requirements "CSV datasets" https://github.com/fizyr/keras-retinanet
  #Create a unique index
  boxes<-boxes %>% mutate(numeric_label=as.numeric(as.factor(label)))
  fname<-paste("Results/detection_boxes/",sanitized_fn,".csv",sep="")

  write.csv(boxes,fname,row.names = T)
}
