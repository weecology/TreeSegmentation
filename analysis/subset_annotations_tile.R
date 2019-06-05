library(raster)
library(lidR)
#crop out a piece of tile to annotate

r<-stack("/Users/Ben/Documents/DeepLidar/data/NIWO/training/2018_NIWO_2_450000_4426000_image.tif")
tile<-readLAS("/Users/Ben/Documents/DeepLidar/data/NIWO/training/NEON_D13_NIWO_DP1_450000_4426000_classified_point_cloud.laz")

e <- drawExtent()

plotRGB(r)
plot(e,add=T,col="red")

f<-e
#f@xmin<-e@xmin - 40*15
#f@ymax<- e@ymax + 40*15
plot(f,add=T,col="red")

rcrop<-crop(r,f)

writeRaster(rcrop,"/Users/Ben/Documents/DeepLidar/data/NIWO/training/2018_NIWO_2_450000_4426000_image_crop.tif",datatype='INT1U',overwrite=T)
las_crop<-lasclip(tile,f)
writeLAS(las_crop,"/Users/Ben/Documents/DeepLidar/data/NIWO/training/NEON_D13_NIWO_DP1_450000_4426000_classified_point_cloud_crop.laz")
