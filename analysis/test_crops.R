#Crop
library(dplyr)
library(rgdal)
library(raster)

#load bounding boxes
dat<-read.csv("/Users/ben/Documents/DeepForest/data/bounding_boxes_NEON_D03_OSBS_DP1_398000_3280000_classified_point_cloud_laz.csv")

#load raster
rgb<-raster::stack("/Users/ben/Documents/TreeSegmentation/data/training/2017_OSBS_3_398000_3280000_image.tif")

make_box<-function(x){
  extent(x$xmin,x$xmax,x$ymin,x$ymax)
}

results<-list()
for(x in sample(1:nrow(dat),100)){
  print(dat$box[x])
  e<-make_box(dat[x,])
  results[[x]]<-crop(rgb,e)
  print(dim(results[[x]]))
  plotRGB(results[[x]],main=dat$box[x],axes=T)
  Sys.sleep(1)
}


