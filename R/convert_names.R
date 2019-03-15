#' Get corresponding tile across data types
#'
#' \code{convert_names} uses the geocode from each NEON data product to find the corresponding tile in another sensor
#' @param from current sensor
#' @param to destination sensor
#' @param rgb Character. RGB pathname
#' @param lidar Character. Lidar pathname
#' @param hyperspectral hyerspectral pathname
#' @export
convert_names<-function(from,to,lidar=NULL,rgb=NULL,hyperspectral=NULL,site='OSBS'){

  #domain lookup
  dlookup<-data.frame(site=c("OSBS","SJER","GRSM","HARV","TEAK"),domain=c("D03","D17","D07","D01","D17"))
  if(from=="rgb" & to=="lidar"){
    #Get corresponding lidar tile
    geo_index<-stringr::str_match(rgb,"_(\\d+_\\d+)_image")[,2]

    domain<-dlookup[dlookup$site==site,"domain"]

    fn<-paste("NEON_",domain,"_",site,"_DP1_",geo_index,"_classified_point_cloud_colorized.laz",sep="")
    return(fn)
  }

  if(from=="lidar" & to == "rgb"){
    geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified")[,2]

    if(site=="OSBS"){
      fn<-paste("2017",site,"_3_",geo_index,"_image.tif",sep="")
    }

    if(site=="SJER"){
      fn<-paste("2018","_",site,"_3_",geo_index,"_image.tif",sep="")
    }

    if(site=="HARV"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud.laz")[,2]
      fn<-paste("2017_HARV_4_",geo_index,"_image.tif",sep="")
    }

    if(site=="TEAK"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_TEAK_3_",geo_index,"_image.tif",sep="")
    }

    return(fn)
  }

}
