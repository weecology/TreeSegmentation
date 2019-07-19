#' Site wrapper for calculating recall and precision from IoU overlap for a NEON site.
#' @param lidar_file Character. Path to lidar .laz on disk
#' @param algorithm Character. "Silva","Li", "Dalponte", see lidr::lastrees
#' @param Bounding Box Character. Whether to return the convex hulls or bounding box of predicted clouds
#' @return a dataframe of objects for all plots in a site
#' @export
#'
compute_PR_site<-function(site,algorithm="Silva",threshold=0.5,plot=FALSE,save=FALSE,bounding_box=FALSE){

  #Find ground truth
  ground_annotations <- parse_xml(site)
  plots<-unique(ground_annotations$filename)

  PR_list<-list()
  for(plot_name in plots){
    #Find lidar file
    lidar_file<-paste("../data/NeonTreeEvaluation/",site,"/plots/",stringr::str_match(plot_name,"(\\w+).tif")[,2],".laz",sep="")
    plot_data = ground_annotations %>% filter(filename == plot_name)
    PR_list[[plot_name]]<-computePR(lidar_file,plot_data, algorithm = algorithm, bounding_box=bounding_box)
  }

  maPdf<-dplyr::bind_rows(PR_list)
  recall <- sum(maPdf$true_positives,na.rm=T)/nrow(ground_annotations)
  precision <- sum(maPdf$true_positives,na.rm=T)/nrow(maPdf)
  df<-data.frame(site=site,algorithm=algorithm,recall=recall,precision=precision)
  return(df)
}
