#Get training tiles
#The aim is to grab tiles that have lidar/rgb/hyperspec data, but do not overlap with ground truth
library(raster)
library(stringr)
library(lidR)
library(rgdal)

# Load in ground-truth
shps<-list.files("/orange/ewhite/b.weinstein/ITC",pattern=".shp",full.names = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
  return(id)
})

#Paths on hipergator of tiles
rgbfn<-list.files("/orange/ewhite/b.weinstein/NEON/D03/OSBS/DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01",full.names=F,pattern=".tif")
rgb<-list.files("/orange/ewhite/b.weinstein/NEON/D03/OSBS/DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01",full.names=T,pattern=".tif")
lidar_path<-"/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/"
lidarfn<-list.files("/orange/ewhite/NeonData/2017_Campaign/D03/OSBS/L1/DiscreteLidar/Classified_point_cloud/",pattern=".laz")

#keep grabbing tiles until we have 1

while(TRUE){
  #pick a random tile
  s<-sample(1:length(rgb),1)

  #load lidar and rgb
  rgb_raster<-stack(rgb[s])

  #Get corresponding lidar tile
  geo_index<-str_match(rgb[s],"_(\\d+_\\d+)_image")[,2]

  fn<-paste("NEON_D03_OSBS_DP1_",geo_index,"_classified_point_cloud.laz",sep="")
  full_path<-paste(lidar_path,fn,sep="")

  #check if exists
  if(!file.exists(full_path)){
    print("no corresponding lidar tile")
    next
  }

  #check for intersection
  intersect_sum<-c()
  for(x in 1:length(itcs)){
    print(x)
    does_intersect<-intersect(itcs[[x]],rgb_raster)
    intersect_sum[x]<-is.null(does_intersect)
  }

  #if no intersections, write rasters
  if(sum(!intersect_sum)==0){

    #announce we found a match
    print(rgb[s])
    print(full_path)

    print("Found file, saving...")
    lidar_tile<-readLAS(full_path)
    writeRaster(rgb_raster,paste("../data/training/",rgbfn[s],sep=""))
    writeLAS(lidar_tile,paste("../data/training/",fn,sep=""))

    #break out of while loop
    break
  }
  }



