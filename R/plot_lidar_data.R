  #' Plot lidar data on NEON stem basemaps
  #'
  #' \code{plot_lidar data} overlays the woody vegetation structure NEON data on the airborne RGB mosiac.
  #' @param siteID NEON site abbreviation (e.g. "HARV")
  #' @param image_dir path to the image directory (e.g NeonTreeEvaluation/)
  #' @return Saved tif files for each plot
  #' @importFrom magrittr "%>%"
  #' @import dplyr
  #' @export
  #'
  plot_lidar_data<-function(plot_name="WREF_078",image_dir="/Users/Ben/Documents/NeonTreeEvaluation/"){

    #Read plot data
    plots<-sf::st_read("data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
    dat<-read.csv("data/Terrestrial/field_data.csv")
    dat<-dat %>% filter(plotID == plot_name)

    #only higher quality data
    dat<-dat %>% dplyr::filter(!crdSource %in% "GIS")

    #nothing from before 2016.
    dat<-dat[!stringr::str_detect(dat$eventID,c("2014")),]

    #Higher than 3m
    field_data<-dat %>% filter(height>3)

    #Individual trees
    trees<-field_data  %>% filter(!is.na(UTM_E)) %>% droplevels()

    #get domain
    #if no rows
    if(nrow(trees)==0){
      print("No tree data with given name")
      return(NULL)
    }

  site = stringr::str_match(plot_name,"(\\w+)_")[,2]
  lidar_path = paste(paste(image_dir,site,"plots",plot_name,sep="/"),".laz",sep="")
  image_path = paste(paste(image_dir,site,"plots",plot_name,sep="/"),".tif",sep="")

    if(file.exists(lidar_path)){

      #Create a simple features
      ortho<-raster::stack(image_path)
      pts_sp<-sp::SpatialPointsDataFrame(cbind(trees$UTM_E,trees$UTM_N),trees,proj4string=ortho@crs)
      tile<-lidR::readLAS(lidar_path)
      raster::projection(tile)<-raster::projection(ortho)

      #buffer as circles
      chm<-TreeSegmentation::canopy_model(tile)
      raster::plot(chm)
      points(pts_sp)
      x = lidR::plot(tile)
      lidR::add_treetops3d(x,pts_sp,z="height")
    }

  }


