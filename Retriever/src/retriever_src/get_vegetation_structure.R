get_vegetation_structure <- function(){
  file_tos_coordinates = read_csv("./Retriever/tmp/filesToStack10098/stackedFiles/vst_perplotperyear.csv") %>%
    select(c("plotID","plotType", "utmZone", "easting", "northing", "coordinateUncertainty", "nlcdClass"))
  
  file_mapping = read_csv("./Retriever/tmp/filesToStack10098/stackedFiles/vst_mappingandtagging.csv") %>%
    select(c("uid", "eventID", "domainID","siteID","plotID","subplotID",
             "nestedSubplotID","pointID","stemDistance","stemAzimuth",
             "cfcOnlyTag","individualID","supportingStemIndividualID","previouslyTaggedAs",
             "taxonID","scientificName"))
  dat = inner_join(file_mapping,file_tos_coordinates,  by = "plotID") %>%
    drop_na(stemAzimuth) %>%
    unique

  # get tree coordinates
  dat_apply <- dat %>%
    select(c(stemDistance, stemAzimuth, easting, northing)) 
  coords <- apply(dat_apply,1,function(params)from_dist_to_utm(params[1],params[2], params[3], params[4])) %>%
    t %>%
    data.frame
  colnames(coords) <- c('UTM_E', 'UTM_N')
  
  field_tag <- cbind(dat, coords)
  write_csv(field_tag, './Retriever/out/field_data.csv')                          
}
