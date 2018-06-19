## Detection network training
library(TreeSegmentation)
library(raster)
library(lidR)
library(dplyr)

path<-"../data/2017/Lidar/OSBS_003.laz"
#path<-"../data/training/NEON_D03_OSBS_DP1_398000_3280000_classified_point_cloud.laz"
tile<-readLAS(path)
algorithm<-"silva"

#Find tree clusters from canopy height model
tclusters<-treeClusters(path=path,threshold=15,res=2,expand=2)

#make sure boxes aren't off edges
e<-extent(tile)

tclusters[tclusters$xmin < e@xmin,]<-e@xmin
tclusters[tclusters$ymin < e@ymin,]<-e@ymin
tclusters[tclusters$xmin > e@xmax,]<-e@xmax
tclusters[tclusters$xmin > e@ymax,]<-e@ymax

#Crop out lidar cloud
crops<-list()
for(x in 1:nrow(tclusters)){
  row<-tclusters[x,]
  crops[[x]]<-lasclipRectangle(tile,xleft=row$xmin,xright=row$xmax,ybottom=row$ymin,ytop=row$ymax)
}

#For each crop compute silva segmentation
result<-list()
for(x in 1:length(crops)){
  result[[x]]<-silva2016(tile=crops[[x]],output = "tile")
}

plot(result[[1]],color="treeID",size=3)

#get list of tree points
las_trees<-lapply(result,function(x){
  trees<-split(x@data, x@data$treeID)
  trees<-bind_rows(trees) %>% select(X,Y,Z,treeID)
})


#Label clusters and bind together
for(x in 1:length(las_trees)){
  las_trees[[x]]$Cluster<-x
}

las_trees<-bind_rows(las_trees)

#Get bounding box around each tree id
las_trees<-las_trees %>% group_by(Cluster,treeID) %>% do(get_box(.,expand=1))

#Append cluster bounding box, rename to make it clearer the different in extents
tclusters<-tclusters %>% select(Cluster=Index,cluster_xmin=xmin,cluster_xmax=xmax,cluster_ymin=ymin,cluster_ymax=ymax)
boxes<-las_trees %>% inner_join(tclusters) %>% select(box=treeID)

#get the corresponding orthophoto naming
boxes$lidar_path<-stringr::str_match(path,"\\/(\\w+.laz)")[,2]
boxes$rgb_path<-convert_names(from="lidar",to="rgb",lidar=path)

#label
boxes$label<-"Tree"

fname<-paste("detection_boxes/",".csv",sep="")

write.csv(boxes,fname)

