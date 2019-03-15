library(lidR)
library(devtools)
install_github("Weecology/TreeSegmentation")

#Load toy data
LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
las = readLAS(LASfile)

#Segmentation methods (takes about 2 minutes.)
silva<-silva2016(tile=las,output="all")
dalponte<-dalponte2016(tile=las,output="all")
li<-li2012(tile=las,output="all")
watershed_result<-watershed(tile=las,output="all")

#View spatial clustering
plot(silva$convex)
plot(dalponte$convex)
plot(li$convex)
plot(watershed_result$convex)

#Attempt 1
ptlist<-list(silva=silva$tile,dalponte=dalponte$tile,li=li$tile,watershed=watershed_result$tile)
consensus_result<-consensus(ptlist=ptlist,method="majority")
consensus_polygons<-get_convex_hulls(consensus_result,consensus_result@data$treeID)
plot(consensus_polygons)
paste(length(consensus_polygons),"consensus clusters found")
length(silva$convex)

#change order of columns
ptlist<-list(li=li$tile,watershed=watershed_result$tile,silva=silva$tile,dalponte=dalponte$tile)
consensus_result<-consensus(ptlist=ptlist,method="majority")
consensus_polygons<-get_convex_hulls(consensus_result,consensus_result@data$treeID)
plot(consensus_polygons)
paste(length(consensus_polygons),"consensus clusters found")
length(li$convex)



