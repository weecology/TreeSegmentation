### Random crops for manually annotated data ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(rgdal)

inpath<-"/orange/ewhite/NeonData/SJER/DP1.30010.001/2017/FullSite/D17/2017_SJER_2/L3/Camera/Mosaic/V02/"
fils<-list.files(inpath,full.names = T,pattern="2017_")

for (x in 1:50){
  #pick random tile
  tile<-sample(fils,1)

  #read tile
  rgb<-stack(tile)

  #random crop within the image, padded not to go too close to edge
  center<-sampleRandom(rgb,1,ext=extent(rgb)/2,sp=T)

  xmean<-coordinates(center)[1,1]
  ymean<-coordinates(center)[1,2]

  #add distance
  xmin=xmean-100
  xmax=xmean+100
  ymin=ymean-100
  ymax=ymean+100

  clip_ext<-extent(xmin,xmax,ymin,ymax)
  clipped_rgb<-raster::crop(rgb,clip_ext)

  #filename
  cname<-paste("/orange/ewhite/b.weinstein/NEON/SJER/Random/",x,".tif",sep="")
  print(cname)

  #rescale to
  writeRaster(clipped_rgb,cname,overwrite=T,datatype='INT1U')
}


