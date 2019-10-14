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
  dlookup<-data.frame(site=c("OSBS","SJER","GRSM","HARV","TEAK","NIWO"),domain=c("D03","D17","D07","D01","D17","D13"))
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
      fn<-paste("2019",site,"_5_",geo_index,"_image.tif",sep="")
    }
    if(site=="SJER"){
      fn<-paste("2018","_",site,"_3_",geo_index,"_image.tif",sep="")
    }
    if(site=="HARV"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud.laz")[,2]
      fn<-paste("2018_HARV_5_",geo_index,"_image.tif",sep="")
    }
    if(site=="TEAK"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_TEAK_3_",geo_index,"_image.tif",sep="")
    }
    if(site=="NIWO"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_NIWO_2_",geo_index,"_image.tif",sep="")
    }
    if(site=="MLBS"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_MLBS_3_",geo_index,"_image.tif",sep="")
    }
    if(site=="BART"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_BART_4_",geo_index,"_image.tif",sep="")
    }
    if(site=="BONA"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_BONA_2_",geo_index,"_image.tif",sep="")
    }
    if(site=="BLAN"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_BLAN_3_",geo_index,"_image.tif",sep="")
    }
    if(site=="CLBJ"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_CLBJ_4_",geo_index,"_image.tif",sep="")
    }
    if(site=="DSNY"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_DSNY_5_",geo_index,"_image.tif",sep="")
    }
    if(site=="DELA"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_DELA_5_",geo_index,"_image.tif",sep="")
    }
    if(site=="JERC"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_JERC_4_",geo_index,"_image.tif",sep="")
    }
    if(site=="ONAQ"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_ONAQ_2_",geo_index,"_image.tif",sep="")
    }
    if(site=="LENO"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_LENO_5_",geo_index,"_image.tif",sep="")
    }
    if(site=="TALL"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_TALL_5_",geo_index,"_image.tif",sep="")
    }
    if(site=="SOAP"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2019_SOAP_4_",geo_index,"_image.tif",sep="")
    }
    if(site=="WREF"){
      geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified_point_cloud")[,2]
      fn<-paste("2018_WREF_2_",geo_index,"_image.tif",sep="")
    }
    return(fn)
  }

}
