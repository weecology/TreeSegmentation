#' Wrapper for calculating recall and precision from IoU overlap for a NEON site.
#' \code{computeMAP} computes an lidar based segmentation, assigns polygons to closest match and calculates recall statistic
#' @param lidar_file Character. Path to lidar .laz on disk
#' @param plot_data Data.Frame ground truth annotations from parse_xml().
#' @param algorithm Character. "Silva","Li", "Dalponte", see lidr::lastrees
#' @return A dataframe of matched objects
#' @export
#'
computePR<-function(lidar_file,plot_data,algorithm="Silva",threshold=0.5,plot=TRUE,save=FALSE,bounding_box=FALSE){

  ######### Hard coded epsg and other params ######
  epsg_df<-data.frame(site=c("SJER","TEAK","NIWO","MLBS"),epsg=c("32611","32611","32613","32618"))
  epsg_numeric<-epsg_df[epsg_df$site %in% site,"epsg"]

  silva_params<-data.frame(Site=c("SJER","TEAK","NIWO","MLBS"),max_cr_factor=c(0.9,0.2,0.2,0.9),exclusion=c(0.3,0.5,0.5,0.3))
  site_params<-silva_params[silva_params$Site == site,]

  #check if exists
  if(!file.exists(lidar_file)){
    print("File does not exist")
    return(NULL)
  }

  #Tree predictions
  if(algorithm=="Dalponte"){
    results<-run_dalponte2016(path=lidar_file,epsg_numeric=epsg_numeric)
  }

  if(algorithm=="Li"){
    results<-run_li2012(path=lidar_file,epsg_numeric=epsg_numeric)
  }

  if(algorithm=="Silva"){
    #Hard code site params?
    results<-run_silva2016(path=lidar_file,epsg_numeric=epsg_numeric, max_cr_factor=site_params$max_cr_factor, exclusion=site_params$exclusion)

  }

  #Project
  projection_extent<-raster::extent(lidR::readLAS(lidar_file))

  ground_truth<-list()
  for(x in 1:nrow(plot_data)){

    e<-raster::extent( projection_extent@xmin + plot_data$xmin[x],
               projection_extent@xmin + plot_data$xmax[x],
               (projection_extent@ymax - plot_data$ymax[x]),
               (projection_extent@ymax - plot_data$ymax[x]) + (plot_data$ymax[x] - plot_data$ymin[x]) )
    ground_truth[[x]]<-as(e, 'SpatialPolygons')
    ground_truth[[x]]@polygons[[1]]@ID<-as.character(x)
  }

  ground_truth <- as(sp::SpatialPolygons(lapply(ground_truth,
                                            function(x) slot(x, "polygons")[[1]])),"SpatialPolygonsDataFrame")
  ground_truth@data$crown_id=1:nrow(ground_truth)
  sp::proj4string(ground_truth)<-raster::projection(results$tile)

  #predictions
  if(bounding_box){
    predictions<-lidR::delineate_crowns(results$tile,type="bbox")
  } else{
    predictions<-lidR::delineate_crowns(results$tile)
  }


  #match names
  predictions$ID<-1:nrow(predictions)

  if(plot){
    r<-raster::stack(paste("../data/NeonTreeEvaluation/",site,"/plots/",plot_name,sep=""))
    tiff(paste("plots/",algorithm,"/",plot_name,sep=""))
    raster::plotRGB(r)
    #plot(ground_truth,add=T,border="green",bg="transparent")
    plot(predictions,add=T,border="orange",bg="transparent",lwd=4)
    dev.off()
  }

  #If there is only one prediction, skip assignment
  if(nrow(predictions) > nrow(ground_truth)){
    assignment<-assign_trees(ground_truth=ground_truth,prediction=predictions)

    statdf<-calc_jaccard(assignment=assignment,ground_truth = ground_truth,prediction=predictions)
  } else{

    #Find max overlap
    po<-polygon_overlap_all(ground_truth,predictions)
    statdf<-po %>% group_by(prediction_id) %>% filter(area==max(area)) %>% group_by(crown_id,prediction_id) %>% do(data.frame(IoU=IoU(ground_truth[.$crown_id,],predictions[.$prediction_id,])))
  }

  plot_name = unique(plot_data$filename)
  results<-data.frame(plot_name,true_positives = statdf$IoU > threshold, false_positives = statdf$IoU < threshold)
  return(results)
}
