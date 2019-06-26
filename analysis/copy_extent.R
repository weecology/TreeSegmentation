library(lidR)
library(raster)
library(stringr)
base<-"/Users/Ben/Documents/DeepLidar/data/TEAK/samples/"
tif<-list.files(base,full.names=T,pattern=".tif")

for(x in 1:length(tif)){
  print(x)
  image<-stack(tif[x])
  lidar_name<-paste(str_match(tif[x],"(\\w+).tif")[,2],".laz",sep="")
  full_path<-paste(base,lidar_name,sep="")
  las<-readLAS(full_path)
  extent(image)<-extent(las)
  proj4string(image)<-proj4string(las)
  chm<-canopy_model(las)
  plotRGB(image)
  plot(chm,add=T,alpha=0.4,axes=F)
  writeRaster(image,tif[x],overwrite=TRUE, datatype='INT1U')
}

#bad<-tif[c(1,9,15,18,30,36)]

#for (x in bad){
#  file.remove(x)
#}

#How to check for a tile like this?
