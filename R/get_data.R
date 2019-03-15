#' Download terrestrial data from NEON
#' \code{get_TOS_data} looks up which sites have data for a given terrestrial product.
#' @param prd Product ID number, e.g. DP1.10098.001 (veg structure ) is 10098
#' @return A stacked file in /data/ with desired product across sites
#' @export
#'

get_TOS_data <- function(prd=NULL){
  req <- httr::GET(paste("http://data.neonscience.org/api/v0/products/DP1.",prd,".001", sep=""))
  # make this JSON readable -> "text"
  req.text <- httr::content(req, as="text")
  # Flatten data frame to see available data.
  avail <- jsonlite::fromJSON(req.text, simplifyDataFrame=T, flatten=T)
  sitesID <- unlist(avail$data$siteCodes$siteCode)

  for(id in sitesID){
    zipsByProduct(dpID=paste("DP1.", prd, ".001", sep=""), site=id, package="basic", savepath="data/Terrestrial/", check.size=F)
  }
  stackByTable(filepath=paste("data/Terrestrial/filesToStack", prd, "/",sep=""), folder=T)

}
