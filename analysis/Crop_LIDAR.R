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

#Crop lidar by itc extent and write to file
#cores<-detectCores()
cl<-makeCluster(10)
registerDoSNOW(cl)

foreach(x=1:length(itcs),.packages=c("lidR","TreeSegmentation","sp"),.errorhandling = "pass") %dopar% {
  #plot(itcs[[x]])

  #path_to_tiles<-"/Users/ben/Dropbox/Weecology/NEON/"
  path_to_tiles<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"

  #Create raster catalog
  ctg<-catalog(path_to_tiles)

  #create extent polygon
  e<-extent(itcs[[x]])

  xmean=mean(c(e@xmin,e@xmax))
  ymean=mean(c(e@ymin,e@ymax))

  #add distance
  xmin=xmean-100
  xmax=xmean+100
  ymin=ymean-100
  ymax=ymean+100

  clip_ext<-extent(xmin,xmax,ymin,ymax)

  extent_polygon<-as(clip_ext,"SpatialPolygons")
  extent_polygon<-extent_polygon@polygons[[1]]@Polygons[[1]]

  #clip to extent
  clipped_las<-lasclip(ctg,extent_polygon)

  #if null, return NA
  if(is.null("clipped_las")){
    return(NA)
  }

  #Make canopy model
  canopy_model(clipped_las)

  #filename
  plotid<-unique(itcs[[x]]$Plot_ID)
  cname<-paste("/orange/ewhite/b.weinstein/NEON/2017/Lidar/",plotid,".laz",sep="")
  print(cname)
  writeLAS(clipped_las,cname)

  return(cname)
}
