#' Find tree crown polygons using the Dalponte 2016 algorithm
#'
#' \code{dalponte2016} assigns each point in a lidR cloud to a treeID.
#' @inheritParams li2012
#' @examples
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' convex_hulls <- run_dalponte2016(path=LASfile)
#' @export

run_dalponte2016<-function(path=NULL,tile=NULL,output="all",epsg_numeric){

  if(is.null(tile)){
    tile = lidR::readLAS(path, filter = "-drop_z_below 0")
    lidR::epsg(tile)<-epsg_numeric
  }

  #Read in tile
  print("Normalizing Ground Model")

  #Compute ground model
  tile=ground_model(tile,ground=F)

  #3. canopy model
  print("Computing Canopy Model")
  chm=canopy_model(tile)

  #Compute unsupervised classification method
  print("Clustering Trees")
  print(system.time(results<-segment_trees(las=tile,algorithm = "dalponte2016",chm=chm)))

  if(output=="tile"){
    return(results)
  }

  #create polygons
  print("Creating tree polygons")
  dalponte_convex<-get_convex_hulls(results,results@data$treeID)

  #set outputs
  if(output=="all"){
    return(list(convex=dalponte_convex,tile=results))
  }

  if(output=="convex_hull"){
    return(dalponte_convex)
  }
}

