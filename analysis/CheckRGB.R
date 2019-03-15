csvs<-list.files("/home/b.weinstein/TreeSegmentation/analysis/Results/detection_boxes/SJER")


for(x in 1:length(csvs)){

  lidar<-str_match(csvs[x],"(\\w+.laz)")[,2]
  lidar<-gsub("_laz",".laz",lidar)
  rgb_path<-convert_names(from="lidar",to="rgb",lidar=lidar_files[x],site=site)
  flag<-rgb_path %in% rgb_files

  if(!flag){
    print(x)
    sanitized_fn<-stringr::str_match(string=lidar,pattern="(\\w+).laz")[,2]
    fn<-paste("/home/b.weinstein/TreeSegmentation/analysis/Results/detection_boxes/SJER/",sanitized_fn,"_laz.csv",sep="")
    print(fn)
    #file.remove(fn)
  }
}
