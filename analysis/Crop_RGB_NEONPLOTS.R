### Clip RGB Data Based on Neon Plots ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(parallel)
library(rgdal)
library(sf)
library(dplyr)
library(stringr)

#Take the centroid and 10m on either side of the bounding box.

plots<-st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
dat<-read.csv("../data/Terrestrial/field_data.csv")
OSBS<-dat %>% filter(siteID=="HARV") %>% droplevels()
OSBS_plots<-plots[plots$plotID %in% OSBS$plotID,]

#Count trees, only keep basePlots
Trees<-OSBS %>% group_by(plotID) %>% summarize(Trees=n())
OSBS_trees<-OSBS_plots %>% inner_join(Trees) %>% filter(subtype=="basePlot")
OSBS_trees<-st_transform(OSBS_trees,crs=32618)

#projection

#Crop lidar by plot extent and write to file
cl<-makeCluster(10)
registerDoSNOW(cl)

foreach(x=1:nrow(OSBS_trees),.packages=c("TreeSegmentation","sp","raster","sf","stringr"),.errorhandling = "pass") %dopar% {

  plotid<-OSBS_trees[x,]$plotID
  plotextent<-extent(OSBS_trees[x,])
  #Look for corresponding tile
  #get lists of rasters
  inpath<-"/orange/ewhite/NeonData/HARV/DP1.30010.001/2017/FullSite/D01/2017_HARV_4/L3/Camera/Mosaic/V01"
  fils<-list.files(inpath,full.names = T,pattern=".tif")
  filname<-list.files(inpath,pattern=".tif")

  #drop summary image
  fils<-fils[!str_detect(fils,"all_5m")]
  #loop through rasters and look for intersections
  for (i in 1:length(fils)){

    #set counter for multiple tiles
    j=1
    #empty vector to hold tiles
    matched_tiles <- vector("list", 10)

    #load raster and check for overlap
    try(r<-stack(fils[[i]]))

    if(!exists("r")){
    paste(fils[[i]],"can't be read, skipping...")
    next
    }

    do_they_intersect<-raster::intersect(extent(r),plotextent)

    #Do they intersect?
    if(is.null(do_they_intersect)){
      next
    } else{
      matched_tiles[[j]]<-r
      j<-j+1

      #do they intersect completely? If so, go to next tile
      if(extent(do_they_intersect)==plotextent){
        break
      }
    }
  }


  #bind together tiles if matching more than one tile
  matched_tiles<-matched_tiles[!sapply(matched_tiles,is.null)]

  #If no tile matches, exit.
  if(length(matched_tiles)==0){
    return(paste("No matches ",plotid))
  }

  if(length(matched_tiles)>1){
    tile_to_crop<-do.call(mosiac,matched_tiles)
  } else{
    tile_to_crop<-matched_tiles[[1]]
  }

  #Clip matched tile
  e<-as.vector(st_bbox(OSBS_trees[x,]))[c(1, 3, 2, 4)]
  clipped_rgb<-raster::crop(tile_to_crop,e)

  #filename
  cname<-paste("/orange/ewhite/b.weinstein/NEON/HARV/NEONPlots/Camera/L3/",plotid,".tif",sep="")
  print(cname)

  #rescale to
  writeRaster(clipped_rgb,cname,overwrite=T,datatype='INT1U')
  return(cname)
}
