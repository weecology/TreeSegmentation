#' Clip Hyperspectral Data Based on extent of NEON Tower Plots
#'
#' @param siteID NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
crop_hyperspectral_plots<-function(siteID="TEAK",year="2018",false_color=FALSE){

  #Construct site dir and find plots
  rgb_fold<-paste("/orange/ewhite/b.weinstein/NEON",siteID,year,"NEONPlots/Camera/L3/",sep="/")
  tifs<-list.files(rgb_fold, pattern=".tif",full.names = T)

  #Read in plot list
  data(package="neonUtilities","plots")
  site_plots<-plots[plots$subtype=="basePlot",]

  #Hyperspectral dir
  h5_dir<-paste("/orange/ewhite/NeonData",siteID,"DP3.30006.001",year,sep="/")
  h5_files<-list.files(h5_dir,recursive = TRUE,full.names = T, pattern="*.h5")

  for(plotname in tifs){

    plotID<-stringr::str_match(plotname, "(\\w+).tif")[,2]
    plot_record<-site_plots[site_plots$plotID %in% plotID,]

    #Search for geoindex
    geo_index = paste(trunc(plot_record$easting/1000)*1000,trunc(plot_record$northing/1000)*1000,sep="_")

    #Find corresponding h5 tile
    h5_path<-h5_files[stringr::str_detect(h5_files,geo_index)]

    #example
    rgb_filename <- plotname
    save_dir<-paste("/orange/ewhite/b.weinstein/NEON",siteID,year,"NEONPlots/Hyperspectral/L3/",sep="/")
    if(!dir.exists(save_dir)){
      dir.create(save_dir,recursive=T)
    }

    #Clip in python!
    reticulate::use_condaenv("NEON",required=TRUE)
    reticulate::source_python("generate_h5_raster.py")
    status <-run(rgb_filename=rgb_filename,
                      h5_path=h5_path,
                      save_dir=save_dir,
                      false_color=false_color)

  }
}

