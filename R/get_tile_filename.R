#' Get correpsonding .laz tile from file based on the ground truth polygon
#'
#' \code{get_tile_filname} returns the path on file based on extent of the polygon
#' @param polygon The SpatialPolygon file for the ground truth polygon
#' @param basename The directory containing the .laz files.
#' @return A file path
#' @examples
#' Not usually called directly by user.
#' @export
get_tile_filname<-function(polygon,basename="NEON_D03_OSBS_DP1_",extension="_classified_point_cloud.laz"){
  extnt<-raster::extent(polygon)
  #get extent name
  exname<-paste(as.integer(extnt@xmin/1000)*1000,as.integer(extnt@ymax/1000)*1000, sep="_")

  #get plot ID
  plotid<-unique(polygon$Plot_ID)
  fullpath<-paste(plotid,"_",basename,exname,extension,sep="")
  return(fullpath)
}
