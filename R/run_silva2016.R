#' Find tree crown polygons using the Silva 2016 algorithm
#'
#' \code{run_silva2016} assigns each point in a lidR cloud to a treeID.
#' @inheritParams li2012
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- run_silva2016(path=LASfile)
#' @export

run_silva2016<-function(path=NULL,tile=NULL,output=c("all"),epsg_numeric){

  if(is.null(tile)){
    tile = lidR::readLAS(path)
    epsg(tile)<-epsg_numeric
  }

  #Read in tile
  #Compute ground model
  tile<-ground_model(tile,ground=F)


  #3. canopy model
  chm=canopy_model(tile,res=0.5)

  #Compute unsupervised classification method
  result<-segment_trees(las=tile,algorithm = "silva2016",chm=chm)

  if(output=="tile"){
    return(result)
  }

  #create polygons
  silva_convex<-get_convex_hulls(tile = result,ID = result@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=silva_convex,tile=result))
  }
  if(output=="convex_hull"){
    return(silva_convex)
  }

}

