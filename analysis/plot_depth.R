#Create depth images
library(lidR)
library(TreeSegmentation)
r<-readLAS("/USers/ben/Documents/DeepLidar/data/MLBS/plots/MLBS_064.laz")
r<-ground_model(r)
r<-lasfilter(r,Z<30)
chm<-canopy_model(r)
plot(chm)
#normalize to 0-255
stretched<-calc(chm,function(x) x/max(chm[],na.rm=T) * 255)
plot(stretched)
writeRaster(stretched,"/Users/ben/Documents/DeepLidar/data/MLBS/plots/MLBS_064_depth.tif",datatype='INT1U',overwrite=T)
