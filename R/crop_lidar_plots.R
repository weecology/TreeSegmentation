#' Clip Lidar Data Based on Neon Plots
#'
#' \code{crop_lidar_plots} overlays the polygons of the NEON plots with the lidar airborne data
#' @param site_name NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_lidar_plots<-function(site_name="TEAK",year="2018"){

  plots<-sf::st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V7/All_NEON_TOS_Plot_Polygons_V7.shp")
  #dat<-read.csv("../data/Terrestrial/field_data.csv")
  #site_plots<-plots[plots$plotID %in% site$plotID,]

  #Only baseplots
  site_plots<-plots %>% filter(siteID==site_name,subtype=="basePlot")

  #get domain
  #if no rows
  if(nrow(site_plots)==0){
    print("No site plots with given name")
    return(NULL)
  }

  #get lists of lidar tiles
  domainID<-unique(site_plots$domainID)

  #Generic path
  generic_path <- paste("/orange/ewhite/NeonData/",site_name,"/DP1.30003.001/",year,"/FullSite/",domainID,"/",year,"_",site_name, "_*/L1/DiscreteLidar/ClassifiedPointCloud/",sep="")
  inpath<-Sys.glob(generic_path)

  fils<-list.files(inpath,full.names = T,pattern=".laz",recursive = T)
  filname<-list.files(inpath,pattern=".tif",recursive = T)

  #find classified directory
  fils<-fils[stringr::str_detect(fils,"_classified_")]

  if (length(fils)==0){
    print(paste(site_name,"No lidar files available"))
    return(NULL)
  }

  path_to_tiles<-dirname(fils[1])

  #grab the first cloud for crs
  r<-lidR::readLAS(fils[1])

  #Project
  site_plots<-sf::st_transform(site_plots,crs=raster::projection(r))

  #create lidar catalog
  ctg<-lidR::catalog(path_to_tiles)

  #Create directory if needed
  fold<-paste("/orange/ewhite/b.weinstein/NEON/",site_name,"/",year,"/NEONPlots/Lidar/",sep="")
  if(!dir.exists(fold)){
    dir.create(fold,recursive = T)
  }

  for(x in 1:nrow(site_plots)){

    plotid<-site_plots[x,]$plotID
    plotextent<-raster::extent(site_plots[x,])

    #construct filename
    cname<-paste(fold,plotid,".laz",sep="")

    #Check if already complete
    if(file.exists(cname)){
      print(paste(cname,"exists"))
      next
    }

    #clip
    clipped_las<-lidR::lasclip(ctg,plotextent)

    #if null, return NA
    if(nrow(clipped_las@data)==0){
      next
      }

    lidR::writeLAS(clipped_las,cname)
    print(cname)
  }
}
