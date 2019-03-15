#' Clip RGB Data Based on Neon Plots
#'
#' \code{crop_rgb_plots} overlays the polygons of the NEON plots with the RGB airborne data
#' @param siteID NEON site abbreviation (e.g. "HARV")
#' @return Saved tif files for each plot
#' @importFrom magrittr "%>%"
#' @export
#'
  crop_rgb_plots<-function(siteID="SJER",year="2018"){

    plots<-sf::st_read("../data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Polygons_V5.shp")
    dat<-read.csv("../data/Terrestrial/field_data.csv")
    site<-dat[dat$siteID %in% siteID,]
    site_plots<-plots[plots$plotID %in% site$plotID,]
    #Only baseplots
    site_plots<-site_plots[site_plots$subtype=="basePlot",]

    #if no rows
    if(nrow(site_plots)==0){
      print("No site plots with given name")
      return(NULL)
    }

    #get lists of rasters
    inpath<-paste("/orange/ewhite/NeonData/",siteID,"/DP3.30010.001/",sep="")
    fils<-list.files(inpath,full.names = T,pattern=".tif",recursive = T)
    filname<-list.files(inpath,pattern=".tif",recursive = T)
    #drop summary image and L1 data
    fils<-fils[!stringr::str_detect(fils,"all_5m")]
    fils<-fils[stringr::str_detect(fils,"L3")]

    #get current year
    fils<-fils[stringr::str_detect(fils,year)]

    if (length(fils)==0){
      print(paste(siteID,"No rgb files available"))
      return(NULL)
    }

    #grab the first raster for crs
    r<-raster::stack(fils[1])
    #Project
    site_plots<-sf::st_transform(site_plots,crs=raster::projection(r))

    #Create directory if needed
    fold<-paste("/orange/ewhite/b.weinstein/NEON",siteID,year,"NEONPlots/Camera/L3/",sep="/")
    if(!dir.exists(fold)){
      dir.create(fold,recursive = T)
    }

    #Crop by plot extent and write to file

    for(x in 1:nrow(site_plots)){

      plotid<-site_plots[x,]$plotID
      plotextent<-raster::extent(site_plots[x,])

      #construct filename
      cname<-paste(fold,plotid,".tif",sep="")
      print(cname)

      #Check if already complete
      if(file.exists(cname)){
        next
      }

      #Look for corresponding tile
      #loop through rasters and look for intersections
      #empty vector to hold tiles
      matched_tiles <- vector("list", 10)

      for (i in 1:length(fils)){

        #set counter for multiple tiles
        j=1

        #load raster and check for overlap
        try(r<-raster::stack(fils[[i]]))

        if(!exists("r")){
          paste(fils[[i]],"can't be read, skipping...")
          next
        }

        do_they_intersect<-raster::intersect(raster::extent(r),plotextent)

        #Do they intersect?
        if(is.null(do_they_intersect)){
          next
        } else{
          matched_tiles[[j]]<-r
          j<-j+1

          #do they intersect completely? If so, go to next tile
          if(raster::extent(do_they_intersect)==plotextent){
            break
          }
        }
      }

      #bind together tiles if matching more than one tile
      matched_tiles<-matched_tiles[!sapply(matched_tiles,is.null)]

      #If no tile matches, exit.
      if(length(matched_tiles)==0){
        print(paste("No matches ",plotid))
        next
      }

      if(length(matched_tiles)>1){
        tile_to_crop<-do.call(raster::mosaic,matched_tiles)
      } else{
        tile_to_crop<-matched_tiles[[1]]
      }

      #Clip matched tile
      e<-as.vector(sf::st_bbox(site_plots[x,]))[c(1, 3, 2, 4)]
      clipped_rgb<-raster::crop(tile_to_crop,e)


      #rescale to
      raster::writeRaster(clipped_rgb,cname,overwrite=T,datatype='INT1U')
    }
  }
