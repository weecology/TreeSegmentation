### Clip Lidar Data Based on ITCS ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(lidR)
library(parallel)

shps<-list.files("/orange/ewhite/b.weinstein/ITC",pattern=".shp",full.names = T)
itcs<-lapply(shps,readShapePoly)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
})

#Crop lidar by itc extent (buffered by 3x) and write to file
#cores<-detectCores()
cl<-makeCluster(12)
registerDoSNOW(cl)

foreach(x=1:length(itcs),.packages=c("lidR","TreeSegmentation")) %dopar% {
  #plot(itcs[[x]])

  #Get Tile
  fname<-get_tile_filname(itcs[[x]])
  tile<-readLAS(paste("/ufrc/ewhite/s.marconi/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/",fname,sep=""))

  #Clip Tile
  clip_ext<-3.5*extent(itcs[[x]])
  clipped_las<-lasclipRectangle(tile,xleft=clip_ext@xmin,xright=clip_ext@xmax,ytop=clip_ext@ymax,ybottom=clip_ext@ymin)

  #filename
  cname<-paste("/orange/ewhite/b.weinstein/NEON/D03/OSBS/L1/DiscreteLidar/Cropped/","cropped_",fname,sep="")
  writeLAS(clipped_las,cname)
}

