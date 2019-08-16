#Create depth images
library(lidR)
library(TreeSegmentation)
r<-readLAS("/USers/ben/Documents/DeepLidar/data/MLBS/plots/MLBS_064.laz")
r<-ground_model(r)
r<-lasfilter(r,Z<30)
chm<-canopy_model(r)
stretched<-stretch(chm)
writeRaster(stretched,"/Users/ben/Documents/NeonTreeEvaluation/BONA/plots/BONA_005_false_color.tif",datatype='INT1U',overwrite=T)
s
