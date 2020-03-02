#Find crops
library(raster)
rgb_filename<-"/Users/Ben/Dropbox/Weecology/Benchmark/NEON_field_polygons/crops/1.tif"

#CROP CHM
crop_target_CHM(siteID="MLBS",rgb_filename,year="2018",tif_base_dir="/orange/ewhite/NeonData",save_base_dir="/orange/ewhite/b.weinstein/NEON")

#crop Hyperspectral 3 band
ext <- raster::extent(raster::raster(rgb_filename))
easting <- as.integer(ext@xmin/1000)*1000
northing <- as.integer(ext@ymin/1000)*1000
geo_index <- paste(easting,northing,sep="_")

crop_target_hyperspectral(siteID="TEAK",rgb_filename,geo_index,false_color=FALSE, year="2019",h5_base_dir="/orange/ewhite/NeonData",save_base_dir="/orange/ewhite/b.weinstein/NEON")
