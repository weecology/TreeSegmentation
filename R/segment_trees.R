#' Find individual tree crowns using normalized las and a canopy height model
#'
#' \code{segment_trees} assigns each point in a lidR cloud to a treeID.
#' @param las A lidar cloud read in by lidR package
#' @param algorithm a segmentation method, see \code{\link[lidR]{lastrees}}
#' @param chm a canopy height model see \code{\link{canopy_model}}
#' @param plots generate useful plots for visualization. This can be time-consuming for very large tiles
#' @return A las object with treeID field updated based on individual tree segmentation.
#' @examples
#' library(lidR)
#' LASfile <- system.file("extdata", "MixedConifer.laz", package="lidR")
#' tile = readLAS(LASfile, select = "xyz", filter = "-drop_z_below 0"
#' chm=canopy_model(tile)
#' treelas=segment_trees(tile,algorithm="watershed",chm=chm)
#' @export
segment_trees<-function(las,algorithm="watershed",chm=chm,plots=F){

  if(algorithm=="watershed"){
    # tree segmentation
    crowns = lidR::lastrees(las, algorithm = algorithm, chm, th = 4, extra = TRUE)

    # display
    tree = lidR::lasfilter(las, !is.na(treeID))

    # More stuff
    contour = raster::rasterToPolygons(crowns, dissolve = TRUE)

    if(plots){
      plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1)
      plot(chm, col = height.colors(50))
      plot(contour, add = T)
    }

    return(las)
  }
  if (algorithm=="dalponte2016"){

    # Dalponte 2016
    ttops = lidR::tree_detection(chm, 5, 2)
    crowns <- lidR::lastrees_dalponte(las, chm, ttops,extra=T)

    contour = raster::rasterToPolygons(crowns, dissolve = TRUE)

    if(plots){
      plot(crowns, color = "treeID", colorPalette = col)
      plot(chm, col = height.colors(50))
      plot(contour, add = T)
    }

    return(las)
  }

  if(algorithm=="li2012"){
    # tree segmentation
    lidR::lastrees(las, "li2012", R = 5)

    # display
    tree = lidR::lasfilter(las, !is.na(treeID))

    if(plots){
      plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1)
    }

    return(las)
  }

  if(algorithm=="silva2016"){

    ttops = lidR::tree_detection(chm, 5, 2)
    crowns<-lidR::lastrees_silva(las, chm, ttops, max_cr_factor = 0.6, exclusion = 0.3,
                           extra = T)

    # display
    tree = lidR::lasfilter(las, !is.na(treeID))

    # More stuff
    contour = raster::rasterToPolygons(crowns, dissolve = TRUE)

    if(plots){
      plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1,backend="rgl")
      plot(chm, col = height.colors(50))
      plot(contour, add = T)
    }
    return(las)
  }

}
