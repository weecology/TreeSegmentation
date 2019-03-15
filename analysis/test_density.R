r<-readLAS("/Users/ben/Documents/DeepLidar/data/TEAK/NEON_D17_TEAK_DP1_315000_4091000_classified_point_cloud_colorized.laz")
#dtm <- grid_terrain(r, 1, kriging(k = 10L))
#r <- lasnormalize(r, dtm)

sample_40x40<-function(r){
  e<-extent(r)
  new_xmin <- runif(e@xmin,e@xmax,n=1)
  new_xmax <- new_xmin + 40
  
  new_ymin <- runif(e@ymin,e@ymax,n=1)
  new_ymax <- new_ymin + 40
  new_extent <- extent(new_xmin,new_xmax,new_ymin,new_ymax)
  crop<-lasclip(r,new_extent)
  
}

plot(grid_density(r,40))

plot(grid_density(r,40) <  3,colNA="red")

plotRGB(stack(x = "/Users/ben/Documents/DeepLidar/data/TEAK/2018_TEAK_3_315000_4091000_image.tif"))


