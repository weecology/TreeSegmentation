library(raster)

#crop out a piece of tile to annotate

r<-stack("/Users/ben/Dropbox/Weecology/NEON/Orthophotos/2018 4/FullSite/D17/2018_TEAK_3/L3/Camera/Mosaic/V01/2018_TEAK_3_315000_4094000_image.tif")

xy<-sampleRandom(r,1,xy=T)

e<-extent(SpatialPoints(xy))
plotRGB(r)
plot(e,add=T,col="red")

f<-e
f@xmin<-e@xmin - 40*15
f@ymax<- e@ymax + 40*15
plot(f,add=T,col="red")

rcrop<-crop(r,f)

writeRaster(rcrop,"/Users/Ben/Documents/DeepForest/data/TEAK/2018_TEAK_3_315000_4094000_image_crop.tif",datatype='INT1U',overwrite=T)
