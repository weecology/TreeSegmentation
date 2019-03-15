#' Organize terrestrial data from NEON
#' \code{get_vegetatation_structure} cleans the downloaded NEON data
#' @param prd Product ID number, e.g. DP1.10098.001 (veg structure ) is 10098
#' @return A stacked file in /data/ with desired product across sites
#' @export
#'
get_vegetation_structure <- function(path){

  #TODO: Add subplotypes, canopy position variable, growth form field to the joint table
  file_mapping = read_csv("data/Terrestrial/filesToStack10098/stackedFiles/vst_mappingandtagging.csv") %>%
    select(c("uid", "eventID", "domainID","siteID","plotID","subplotID",
             "nestedSubplotID","pointID","stemDistance","stemAzimuth",
             "cfcOnlyTag","individualID","supportingStemIndividualID","previouslyTaggedAs",
             "taxonID","scientificName"))

  plots<-sf::st_read("data/NEONFieldSites/All_NEON_TOS_Plots_V5/All_Neon_TOS_Points_V5.shp")  %>% filter(str_detect(appMods,"vst"))
  dat<-file_mapping %>% mutate(pointID=as.factor(pointID)) %>% left_join(plots,by=c("plotID","pointID"))

  # get tree coordinates
  dat_apply <- dat %>%
    select(c(stemDistance, stemAzimuth, easting, northing))
  coords <- apply(dat_apply,1,function(params) {
    from_dist_to_utm(params[1],params[2], params[3], params[4])
    }) %>%
    t %>%
    data.frame
  colnames(coords) <- c('UTM_E', 'UTM_N')

  field_tag <- cbind(dat, coords)
  write_csv(field_tag, 'data/Terrestrial/field_data.csv')
}
