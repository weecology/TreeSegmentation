#prd = "10026"
get_data <- function(prd=NULL){
  req <- GET(paste("http://data.neonscience.org/api/v0/products/DP1.",prd,".001", sep=""))
  # make this JSON readable -> "text"
  req.text <- content(req, as="text")
  # Flatten data frame to see available data. 
  avail <- fromJSON(req.text, simplifyDataFrame=T, flatten=T)
  sitesID <- unlist(avail$data$siteCodes$siteCode)
  
  for(id in sitesID){
    zipsByProduct(dpID=paste("DP1.", prd, ".001", sep=""), site=id, package="basic", savepath="./Retriever/tmp/", check.size=F)
  }
  stackByTable(filepath=paste("./Retriever/tmp/filesToStack", prd, "/",sep=""), folder=T)
  
}
