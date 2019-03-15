library(tidyverse)
library(devtools)
library(TreeSegmentation)
library(neonUtilities)
library(downloader)
library(httr)
library(jsonlite)
library(sf)
library(dplyr)
library(maptools)
library(raster)
library(tidyr)
#data products download
# chemical >>  DP1.10026.001
# isotopes >> DP1.10053.001
#get_data(10026)
#get_data(10053)
# vegetation structure >> DP1.10098.001
#get_TOS_data(10098)

#harmonize the three data products to make a single database
#stack_chemical_leaf_products(10026)
#stack_isotopes_leaf_products(10053)

# get coordinates and position of the vegetation structure trees
#get_vegetation_structure()

dat<-read.csv("data/Terrestrial/field_data.csv")

sites<-dat %>% filter(siteID=="OSBS") %>% droplevels()

#accepted species list
species<-read.csv("data/NEONPlots/AcceptedSpecies.csv")
species<-species %>% filter(siteID %in% sites$siteID)

#filter data by species
sites <- sites %>% filter(scientificName %in% species$scientificName)

#search for duplicates, ending in a letter

sites<-sites %>% filter(!is.na(as.numeric(str_sub(individualID,-1))))

#for each plot, max n over years
sites %>% group_by(plotID,eventID) %>% summarise(n=n()) %>% spread(eventID,n) %>% filter(!is.na(vst_OSBS_2017))
treecount<-sites %>% group_by(plotID,eventID) %>% summarise(n=n()) %>% group_by(plotID) %>% summarize(n=max(n))
write.csv(treecount,"data/NEONPlots/OSBS/treecount.csv")

#Individual trees
trees<-sites  %>% filter(!is.na(UTM_E))

#plots with trees
ptrees<-unique(trees$plotID)
for(x in ptrees){
  pts<-trees %>% filter(plotID == x)
  filname<-paste("data/NEONPlots/OSBS/Camera/L3/",x,".tif",sep="")
  if(file.exists(filname)){
    r<-stack(filname)
  } else{
    next
  }
  sp_trees<-SpatialPoints(cbind(pts$UTM_E,pts$UTM_N),proj4string =crs(r) )
  plotRGB(r)
  points(sp_trees)
}
