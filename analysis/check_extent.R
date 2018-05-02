library(TreeSegmentation)
library(rgdal)

shps<-list.files("../data/ITCs/test/",pattern=".shp",full.names = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
  return(id)
})

for(x in 1:length(itcs)){
  print(x)
  fname<-get_tile_filname(itcs[[x]])

  inpath<-paste("../data/2017/Lidar/cropped_",fname,sep="")
  #Sanity check, does the file exist?
  if(!file_test("-f",inpath)){
    warning(inpath," does not exist")
    next
    }

  try(tile<-readLAS(inpath))
  tile@crs<-CRS("+init=epsg:32617")
  #plot(tile)

  plot(extent(tile),col='red')
  plot(extent(itcs[[x]]),col='blue',add=T)
  title(unique(itcs[[x]]$Plot_ID))

  ground_truth<-raster::crop(itcs[[x]],extent(tile))
  plot(ground_truth,add=T,col='green')
}

