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
#shps<-list.files("data/ITCs",pattern=".shp",full.names = T,recursive = T)
itcs<-lapply(shps,readOGR,verbose=F)

names(itcs)<-sapply(itcs,function(x){
  id<-unique(x$Plot_ID)
})

#Crop lidar by itc extent (buffered by 3x) and write to file
cl<-makeCluster(15)
#cl<-makeCluster(2)
registerDoSNOW(cl)

foreach(x=1:length(itcs),.packages=c("TreeSegmentation","sp","raster"),.errorhandling = "pass") %dopar% {
  #plot(itcs[[x]])

  #Look for corresponding tile
  #get lists of rasters
  inpath<-"/orange/ewhite/NeonData/OSBS/DP1.30010.001/2017/FullSite/D03/2017_OSBS_3/L3/Camera/Mosaic/V01"
  fils<-list.files(inpath,full.names = T,pattern=".tif")
  filname<-list.files(inpath,pattern=".tif")

  #loop through rasters and look for intersections
  for (i in 1:length(fils)){

    #set counter for multiple tiles
    j=1
    #empty vector to hold tiles
    matched_tiles <- vector("list", 10)

    #load raster and check for overlap
    r<-stack(fils[[i]])
    do_they_intersect<-raster::intersect(extent(r),extent(itcs[[x]]))

    #Do they intersect?
    if(is.null(do_they_intersect)){
      next
    } else{
      matched_tiles[[j]]<-r
      j<-j+1

      #do they intersect completely? If so, go to next tile
      if(extent(do_they_intersect)==extent(itcs[[x]])){
        break
      }
    }
  }


  #bind together tiles if matching more than one tile
  matched_tiles<-matched_tiles[!sapply(matched_tiles,is.null)]

  #If no tile matches, exit.
  if(length(matched_tiles)==0){
    return(paste("No matches ",unique(itcs[[x]]$Plot_ID)))
  }

  if(length(matched_tiles)>1){
    tile_to_crop<-do.call(mosiac,matched_tiles)
  } else{
    tile_to_crop<-matched_tiles[[1]]
  }

  #Clip matched tile
  #Create a window of equal size, centered
  #center point
  e<-extent(itcs[[x]])

  xmean=mean(c(e@xmin,e@xmax))
  ymean=mean(c(e@ymin,e@ymax))

  #add distance
  xmin=xmean-100
  xmax=xmean+100
  ymin=ymean-100
  ymax=ymean+100

  clip_ext<-extent(xmin,xmax,ymin,ymax)
  clipped_rgb<-raster::crop(tile_to_crop,clip_ext)

  #filename
  cname<-paste("/orange/ewhite/b.weinstein/NEON/2017/Camera/L3/",unique(itcs[[x]]$Plot_ID),".tif",sep="")
  print(cname)

  #rescale to
  writeRaster(clipped_rgb,cname,overwrite=T,datatype='INT1U')
  return(cname)
}
