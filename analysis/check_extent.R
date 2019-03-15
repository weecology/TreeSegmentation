library(TreeSegmentation)
library(rgdal)
library(raster)
library(stringr)
library(lidR)

shps<-list.files("../data/ITCs/",pattern=".shp",full.names = T,recursive = T)

#take out missing polygon
shps<-shps[!str_detect(shps,"009")]
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
  rgb_path<-paste("../data/2017/Camera/L3/",fname,".tif",sep="")
  if(file.exists(rgb_path)){
    ortho<-raster::stack(rgb_path)
    #select bands
    #rgb<-ortho[[c(17,86,177)]]/10000
    #rgb[rgb>1]<-NA
    #get rid of NA

  }else{
    next
  }

  png(paste("plots/RGB_2017_larger/",fname,".png",sep=""))

  plotRGB(ortho,ext=)

  try(tile<-readLAS(inpath))
  tile@crs<-CRS("+init=epsg:32617")
  #plot(tile)

  #plot(extent(tile),col='red')
  title(unique(itcs[[x]]$Plot_ID))

  #ground_truth<-raster::crop(itcs[[x]],extent(tile))
  plot(itcs[[x]],add=T,border="red")
  dev.off()
}
