#Get training tiles
#The aim is to grab tiles that have lidar/rgb/hyperspec data, but do not overlap with ground truth
library(raster)
library(stringr)
library(lidR)

# Load in ground-truth
shps<-list.files("../data/ITCs/test/",pattern=".shp",full.names = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
  return(id)
})

#Paths on hipergator of tiles
rgb<-list.files("DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01/",full.names=T)
lidar<-list.files("/ufrc/ewhite/s.marconi/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/",full.names = T)

#keep grabbing tiles until we have 1

while(True){
  #pick a random tile
  s<-sample(1:length(rgb),1)

  #load lidar and rgb
  rgb_raster<-stack(rgb[s])
  lidar_tile<-readLAS(lidar[s])

  #check for intersection
  intersect_sum<-c()
  for(x in 1:length(itcs)){
    does_intersect<-intersect(itcs[x],rgb_raster)
    intersect_sum[x]<-is.null(does_intersect)
  }

  #if no intersections, write rasters
  if(sum(intersect_sum)==0){

    #announce we found a match
    print(rgb[s])
    print(lidar[s])

    #get filenames
    #TODO a regex command here to extract filename
    fn_rgb<-str_extract(rgb[s])
    fn_lidar<-str_extract(lidar[s])

     #write
    writeRaster(rgb_raster,paste("../data/training/",fn_rgb,sep=""))
    writeLAS(lidar_tile,paste("../data/training/",fn_rgb,sep=""))

    #break out of while loop
    break
  }
  }



