library(TreeSegmentation)
library(rgdal)
library(raster)

shps<-list.files("../data/ITCs/test/",pattern=".shp",full.names = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
  return(id)
})

for(x in 1:length(itcs)){

  print(x)
  fname<-unique(itcs[[x]]$Plot_ID)

  inpath<-paste("../data/2017/Lidar/",fname,".laz",sep="")
  #Sanity check, does the file exist?
  if(!file_test("-f",inpath)){
    warning(inpath," does not exist")
    next
  }

  #add rgb
  ortho<-raster::stack(paste("../data/2017/RGB/cropped_",fname,".tif",sep=""))


  png(paste("plots/",fname,".png",sep=""))

  plotRGB(stretch(ortho/10000*255),ext=extent(itcs[[x]])*1.6)

  try(tile<-readLAS(inpath))
  tile@crs<-CRS("+init=epsg:32617")
  #plot(tile)

  #plot(extent(tile),col='red')
  title(unique(itcs[[x]]$Plot_ID))

  ground_truth<-raster::crop(itcs[[x]],extent(tile))
  plot(ground_truth,add=T,border="red")
  dev.off()
}



