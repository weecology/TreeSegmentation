#Create depth images
library(lidR)
library(TreeSegmentation)
library(RStoolbox)
library(raster)
r<-readLAS("/Users/ben/Documents/NeonTreeEvaluation/evaluation/LiDAR/2018_TEAK_3_316000_4097000_image_493.laz")
plot(canopy_model(r))
r<-ground_model(r,ground = FALSE)
r<-lasfilter(r,Z<30)
plot(r)
writeLAS(r,"/Users/ben/Documents/NeonTreeEvaluation/BART/plots/WREF_075.laz")
chm<-canopy_model(r)
stretched<-stretch(chm)
writeRaster(stretched,"/Users/ben/Documents/NeonTreeEvaluation/BART/plots/BART_028_depth.tif",datatype='INT1U',overwrite=T)

#grab a range based on field data
a<-(chm > 16 & chm < 20)
plot(a)

g<-stack("/Users/ben/Documents/NeonTreeEvaluation/evaluation/Hyperspectral/SERC_062_hyperspectral.tif")
g<-g[[c(17,55,113)]]

#trim quantile
stretched<-stretch(g,maxq=0.95)
plotRGB(stretched)
writeRaster(stretched,"/Users/ben/Documents/NeonTreeEvaluation/evaluation/RGB/SERC_062_depth.tif",overwrite=T)
