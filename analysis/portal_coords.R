library(raster)
library(sf)
coords<-st_read("/Users/ben/Documents/TreeSegmentation/analysis/Portal_UTMCoords.csv",options=c("X_POSSIBLE_NAMES=east","Y_POSSIBLE_NAMES=north"))
e<-extent(coords)
p<- as(e, 'SpatialPolygons')
crs(p) <- "+proj=utm +zone=12 +datum=WGS84 +units=m +no_defs"
shapefile(p, 'portal_extent.shp')


r<-stack("/Users/ben/Downloads/NAIP/East_clip2.tif")
writeRaster(x=r[[1:3]],datatype="INT1U",filename="/Users/ben/Downloads/NAIP/East_ben.tiff",overwrite=T)
plotRGB(r[[1:3]])
res(r)

b<-stack("/Users/ben/Downloads/NAIP/East_ben.tif")
plotRGB(b)
