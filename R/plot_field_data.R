#' Plot field data on basemaps
#'
#' \code{plot_field data} overlays the woody vegetation structure NEON data on the airborne RGB mosiac.
#' @param siteID NEON site abbreviation (e.g. "HARV")
#' @param image_dir path to the image directory (e.g NeonTreeEvaluation/)
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @import dplyr
#' @export
#'
plot_field_data<-function(site="MLBS",image_dir="/Users/Ben/Documents/NeonTreeEvaluation/evaluation"){

  #Read plot data
  plots<-sf::st_read("data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
  dat<-read.csv("data/Terrestrial/field_data.csv")

  #only higher quality data
  dat<-dat %>% dplyr::filter(!crdSource %in% "GIS")

  #nothing from before 2016.
  dat<-dat[!stringr::str_detect(dat$eventID,c("2014")),]

  #search for bole duplicates, ending in a letter
  field_data<-dat %>% filter(siteID == site)

  #Higher than 3m
  #field_data<-field_data %>% filter(height>3)

  #Individual trees
  trees<-field_data  %>% filter(!is.na(UTM_E))

  #plot data filter
  site_plots<-plots[plots$siteID %in% site,]

  #Only baseplots
  site_plots<-site_plots[site_plots$subtype=="basePlot",]

  #get domain
  #if no rows
  if(nrow(site_plots)==0){
    print("No site plots with given name")
    return(NULL)
  }

  plotIDs<-site_plots$plotID
  plotIDs<-plotIDs[plotIDs %in% trees$plotID]

  for(plotID in plotIDs){
    print(plotID)
    pts<-trees[trees$plotID %in% plotID,]

    image_path = paste(paste(image_dir,"RGB",plotID,sep="/"),".tif",sep="")

    if(file.exists(image_path)){
    #Create a simple features
    pts<-sp::SpatialPointsDataFrame(cbind(pts$UTM_E,pts$UTM_N),pts)
    pts<-sf::st_as_sf(pts)
    ortho<-raster::stack(image_path)
    sf::st_crs(pts)<-raster::projection(ortho)

    #buffer as circles
    tree_diameter<-pts %>% filter(!is.na(stemDiameter))
    tree_buffer = sf::st_buffer(tree_diameter,dist=tree_diameter$stemDiameter/100)
      jpeg(paste("analysis/plots/Recall/",plotID,".jpeg",sep=""))
      raster::plotRGB(ortho)
      plot(sf::st_geometry(tree_buffer),border="red",add=T)
      dev.off()
    }

  }
}
