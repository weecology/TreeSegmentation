#' Clip CHM Data Based on Neon Plots
#'
#' \code{crop_CHM_plots} overlays the polygons of the NEON plots with the derived CHM image
#' @param site_name NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_CHM_plots<-function(site_name="TEAK",year="2018"){

  plots<-sf::st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")

  #Only baseplots
  site_plots<-plots %>% filter(siteID==site_name,subtype=="basePlot")

  #get domain
  #if no rows
  if(nrow(site_plots)==0){
    print("No site plots with given name")
    return(NULL)
  }

  #Generic path
  generic_path <- paste("/orange/ewhite/NeonData/",site_name,"/DP3.30015.001/",year,sep="")
  chm_files<-list.files(generic_path,full.names = T,pattern="CHM.tif",recursive = T)

  r<-raster::stack(chm_files[1])
  #Project
  site_plots<-sf::st_transform(site_plots,crs=raster::projection(r))

  if (length(chm_files)==0){
    print(paste(site_name,"No CHM files available"))
    return(NULL)
  }

  #Create directory if needed
  fold<-paste("/orange/ewhite/b.weinstein/NEON/",site_name,"/",year,"/NEONPlots/CHM/",sep="")
  if(!dir.exists(fold)){
    dir.create(fold,recursive = T)
  }

  for(x in 1:nrow(site_plots)){

    plotid<-site_plots[x,]$plotID
    ext<-raster::extent(site_plots[x,])

    #construct filename
    cname<-paste(fold,plotid,"_CHM.tif",sep="")

    #Check if already complete
    if(file.exists(cname)){
      print(paste(cname,"exists"))
      next
    }

    #Find CHM file
    easting <- as.integer(ext@xmin/1000)*1000
    northing <- as.integer(ext@ymin/1000)*1000
    geo_index <- paste(easting,northing,sep="_")

    #Find corresponding h5 tile
    tif_path<-chm_files[stringr::str_detect(chm_files,geo_index)]

    #If exists
    if(length(tif_path)==0){next}

    CHM<-raster::raster(tif_path)
    cropped_CHM<-raster::crop(CHM,ext)

    raster::writeRaster(cropped_CHM,cname,overwrite=T)
    }
}
