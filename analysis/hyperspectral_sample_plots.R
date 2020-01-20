  library(TreeSegmentation)
  library(stringr)

  sample_plots<-list.files("/home/b.weinstein/NeonTreeEvaluation/evaluation/RGB/",full.names=T,pattern="2018_SJER")
  p<-sample_plots[1]
  for(p in sample_plots){
    geo_index<-str_match(p,"SJER_3_(\\w+_\\w+)_image")[,2]
    crop_target_hyperspectral(siteID = "SJER",year="2018",rgb_filename =p,geo_index = geo_index)
  }
    #get geoindex
