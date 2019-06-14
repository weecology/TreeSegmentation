library(raster)
library(lidR)
#crop out a piece of tile to annotate

r<-stack("/Users/Ben/Documents/DeepLidar/data/MLBS/training/2018_MLBS_3_541000_4140000_image.tif")
tile<-readLAS("/Users/Ben/Documents/DeepLidar/data/MLBS/training/NEON_D07_MLBS_DP1_541000_4140000_classified_point_cloud.laz")


plotRGB(r)
e <- drawExtent()
plot(e,add=T,col="red")

f<-e
#f@xmin<-e@xmin - 40*15
#f@ymax<- e@ymax + 40*15
plot(f,add=T,col="red")

rcrop<-crop(r,f)

writeRaster(rcrop,"/Users/Ben/Documents/DeepLidar/data/MLBS/training/2018_MLBS_3_541000_4140000_image_crop2.tif",datatype='INT1U',overwrite=T)
las_crop<-lasclip(tile,f)
writeLAS(las_crop,"/Users/Ben/Documents/DeepLidar/data/MLBS/training/NEON_D07_MLBS_DP1_541000_4140000_classified_point_cloud_crop2.laz")

library(lidR)
library(TreeSegmentation)
r<-readLAS("/USers/ben/Documents/DeepLidar/data/MLBS/training/NEON_D07_MLBS_DP1_541000_4140000_classified_point_cloud_crop.laz")
r<-ground_model(r)
r<-lasfilter(r,Z<25)
chm<-canopy_model(r)
plot(chm)
#normalize to 0-255
stretched<-calc(chm,function(x) x/max(chm[],na.rm=T) * 255)
plot(stretched)
writeRaster(stretched,"/Users/ben/Documents/DeepLidar/data/MLBS/training/2018_MLBS_3_541000_4140000_image_crop_depth.tif",datatype='INT1U',overwrite=T)
