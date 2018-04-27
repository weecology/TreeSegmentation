### Clip Lidar Data Based on ITCS ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(parallel)
library(rgdal)

#Get lists of itcs
shps<-list.files("/orange/ewhite/b.weinstein/ITC",pattern=".shp",full.names = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
})


#Crop lidar by itc extent (buffered by 3x) and write to file
#cores<-detectCores()
cl<-makeCluster(30)
registerDoSNOW(cl)

foreach(x=1:length(itcs),.packages=c("lidR","TreeSegmentation","sp")) %dopar% {
  #plot(itcs[[x]])

  #Look for corresponding tile
  #get lists of rasters
  fils<-list.files("/ufrc/ewhite/s.marconi/NeonData/2017_Campaign/D03/OSBS/L1/Spectrometer/RGBtifs/2017092713/",full.names = T)
  filname<-list.files("/ufrc/ewhite/s.marconi/NeonData/2017_Campaign/D03/OSBS/L1/Spectrometer/RGBtifs/2017092713/")

  for (i in 1:length(fils)){
    r<-stack(fils[[i]])
    do_they_intersect<-intersect(extent(r),extent(itcs[[x]]))
    if(is.null(do_they_intersect)){
      next
    } else{
      matched_tile<-r
    }
  }

  #If no tile matches, exit.
  if(is.null(matched_tile)){
    return(paste("No matches ",itcs[[x]]))
  }

  #Clip matched tile
  clip_ext<-3*extent(itcs[[x]])
  clipped_rgb<-crop(matched_tile,clip_ext)

  #filename
  cname<-paste("/orange/ewhite/b.weinstein/NEON/D03/OSBS/L1/Spectrometer/RGBtifs/2017092713/","cropped_",filname[x],sep="")
  print(cname)
  writeRaster(clipped_rgb,cname)
  return(cname)
}
