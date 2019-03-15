### Clip Lidar Data Based on ITCS ###
library(maptools)
library(raster)
library(TreeSegmentation)
library(doSNOW)
library(foreach)
library(lidR)
library(parallel)
library(rgdal)
library(sf)
library(dplyr)

plots<-st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V4/All_Neon_TOS_Polygon_V4.shp")
dat<-read.csv("../data/Terrestrial/field_data.csv")
OSBS<-dat %>% filter(siteID=="HARV") %>% droplevels()
OSBS_plots<-plots[plots$plotID %in% OSBS$plotID,]

#Count trees, only keep basePlots
Trees<-OSBS %>% group_by(plotID) %>% summarize(Trees=n())
OSBS_trees<-OSBS_plots %>% inner_join(Trees) %>% filter(subtype=="basePlot")
OSBS_trees<-st_transform(OSBS_trees,crs=32618)

#Crop lidar by plot extent and write to file
#cores<-detectCores()
cl<-makeCluster(10)
registerDoSNOW(cl)

foreach(x=1:nrow(OSBS_trees),.packages=c("lidR","TreeSegmentation","sp"),.errorhandling = "pass") %dopar% {

  plotid<-OSBS_trees[x,]$plotID
  plotextent<-extent(OSBS_trees[x,])

  #path_to_tiles<-"/Users/ben/Dropbox/Weecology/NEON/"
  path_to_tiles<-"/orange/ewhite/NeonData/HARV/DP1.30003.001/2017/FullSite/D01/2017_HARV_4/L1/DiscreteLidar/ClassifiedPointCloud/"

  #Create raster catalog
  ctg<-catalog(path_to_tiles)

  extent_polygon<-as(plotextent,"SpatialPolygons")
  extent_polygon<-extent_polygon@polygons[[1]]@Polygons[[1]]

  #clip to extent
  clipped_las<-lasclip(ctg,extent_polygon)

  #if null, return NA
  if(is.null("clipped_las")){
    return(NA)
  }

  #Make canopy model
  #canopy_model(clipped_las)

  #filename
  cname<-paste("/orange/ewhite/b.weinstein/NEON/HARV/NEONPlots/Lidar/",plotid,".laz",sep="")
  print(cname)
  writeLAS(clipped_las,cname)

  return(cname)
}
