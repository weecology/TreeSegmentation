library(raster)
library(lidR)
#crop out a piece of tile to annotate

r<-stack("/Users/ben/Dropbox/Weecology/temp_training/2019_OSBS_5_405000_3287000_image_crop2.tif")
tile<-readLAS("/Users/ben/Downloads/NEON_D03_OSBS_DP1_405000_3287000_classified_point_cloud_colorized.laz")

plotRGB(r)
e <- drawExtent()
plot(e,add=T,col="red")

f<-e
#f@xmin<-e@xmin - 40*15
#f@ymax<- e@ymax + 40*15
plot(f,add=T,col="red")

rcrop<-crop(r,f)

writeRaster(rcrop,"/Users/ben/Dropbox/Weecology/temp_training/2019_OSBS_5_405000_3287000_image2.tif",datatype='INT1U',overwrite=T)
las_crop<-lasclip(tile,extent(r))
chm<-canopy_model(las_crop)
plot(chm)
writeLAS(las_crop,"/Users/ben/Dropbox/Weecology/temp_training/NEON_D03_OSBS_DP1_405000_3287000_classified_point_cloud_colorized_image_crop2.laz")

#Crop hyperspec


library(lidR)
library(TreeSegmentation)
r<-readLAS("/Users/ben/Downloads/NEON_D03_OSBS_DP1_405000_3287000_classified_point_cloud_colorized.laz")
r<-ground_model(r)
r<-lasfilter(r,Z<50)
chm<-canopy_model(r)
plot(chm)
#normalize to 0-255
stretched<-calc(chm,function(x) x/max(chm[],na.rm=T) * 255)
plot(stretched)
writeRaster(stretched,"/Users/ben/Documents/DeepLidar/data/MLBS/training/2018_MLBS_3_541000_4140000_image_crop2_depth.tif",datatype='INT1U',overwrite=T)
