### Clip Lidar Data Based on ITCS ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(lidR)
library(parallel)
library(rgdal)

shps<-list.files("/orange/ewhite/b.weinstein/ITC",pattern=".shp",full.names = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
})

#Crop lidar by itc extent (buffered by 3x) and write to file
#cores<-detectCores()
cl<-makeCluster(15)
registerDoSNOW(cl)

foreach(x=1:length(itcs),.packages=c("lidR","TreeSegmentation","sp")) %dopar% {
  #plot(itcs[[x]])

  #path_to_tiles<-"/Users/ben/Dropbox/Weecology/NEON/"
  path_to_tiles<-"/ufrc/ewhite/s.marconi/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"

  #Create raster catalog
  ctg<-catalog(path_to_tiles)

  #create extent polygon
  extent_polygon<-as(2.5*extent(itcs[[x]]),"SpatialPolygons")
  extent_polygon<-extent_polygon@polygons[[1]]@Polygons[[1]]

  #clip to extent
  clipped_las<-lasclip(ctg,extent_polygon)

  #filename
  plotid<-unique(itcs[[x]]$Plot_ID)
  cname<-paste("/orange/ewhite/b.weinstein/NEON/D03/OSBS/L1/DiscreteLidar/Cropped/2017/",plotid,".laz",sep="")
  print(cname)
  writeLAS(clipped_las,cname)

  return(cname)
}
