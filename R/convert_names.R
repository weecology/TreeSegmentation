#' Get corresponding tile across data types
#'
#' \code{convert_names} uses the geocode from each NEON data product to find the corresponding tile in another sensor
#' @param from current sensor
#' @param to destination sensor
#' @param rgb Character. RGB pathname
#' @param lidar Character. Lidar pathname
#' @param hyperspectral hyerspectral pathname
#' @export
convert_names<-function(from,to,lidar=NULL,rgb=NULL,hyperspectral=NULL){

  if(from=="rgb" & to=="lidar"){
    #Get corresponding lidar tile
    geo_index<-stringr::str_match(rgb,"_(\\d+_\\d+)_image")[,2]

    fn<-paste("NEON_D03_OSBS_DP1_",geo_index,"_classified_point_cloud.laz",sep="")
    return(fn)
  }

  if(from=="lidar" & to == "rgb"){
    geo_index<-stringr::str_match(lidar,"_(\\d+_\\d+)_classified")[,2]
    fn<-paste("2017_OSBS_3_",geo_index,"_image.tif",sep="")
    return(fn)
  }

}
