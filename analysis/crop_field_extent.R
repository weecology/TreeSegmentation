#Find crops
library(raster)
library(TreeSegmentation)
rgb_filename<-"/home/b.weinstein/TreeSegmentation/data/field_crowns/2.tif"
basename <- stringr::str_match(rgb_filename,"/(\\w+).tif")[,2]

#CROP CHM
crop_target_CHM(siteID="MLBS",rgb_filename,year="2018",tif_base_dir="/orange/ewhite/NeonData",save_base_dir="/orange/ewhite/b.weinstein/NEON")

#crop Hyperspectral 3 band
ext <- raster::extent(raster::raster(rgb_filename))
easting <- as.integer(ext@xmin/1000)*1000
northing <- as.integer(ext@ymin/1000)*1000
geo_index <- paste(easting,northing,sep="_")

crop_target_hyperspectral(siteID="MLBS",
                          rgb_filename,
                          geo_index,
                          false_color=TRUE,
                          year="2019",
                          h5_base_dir="/orange/ewhite/NeonData/",
                          save_base_dir="/orange/ewhite/b.weinstein/NEON/")
