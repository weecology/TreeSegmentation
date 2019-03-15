##ITC Segment

library(itcSegment)

data(imgData)
imgData
se<-itcIMG(imgData,epsg=32632)
summary(se)
plot(se,axes=T)

r<-stack("data/2017/Camera/OSBS_006.tif")
r_img<-itcIMG(r)
