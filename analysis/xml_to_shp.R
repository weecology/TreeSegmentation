#quick export to shp
library(sf)
library(NeonTreeEvaluation)

a<-load_ground_truth("LENO_066")
b<-st_as_sf(a)
write_sf(b,"/Users/Ben/Dropbox/Weecology/Benchmark/ForStephanie/LENO_066_Ben.shp")
