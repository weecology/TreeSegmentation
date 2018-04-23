library(TreeSegmentation)

#LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#convex_hulls <- silva2016(path=LASfile)
silva_convex<-silva2016(path="../tests/data/NEON_D03_OSBS_DP1_404000_3284000_classified_point_cloud.laz")

#write polygons as shapefile
writePolyShape(silva_convex,"Results/silva2016")
