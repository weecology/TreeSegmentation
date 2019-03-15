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

  #Compute tree tops
  ttops <- lidR::tree_detection(las, lmf(ws = 5))

  if(algorithm=="watershed"){
    # tree segmentation

    crowns = lidR::lastrees(las, mcwatershed(chm, ttops))

    # display
    tree = lidR::lasfilter(crowns, !is.na(treeID))

    # More stuff
    contour = raster::rasterToPolygons(crowns, dissolve = TRUE)

    if(plots){
      plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1)
      plot(chm, col = height.colors(50))
      plot(contour, add = T)
    }
  }
  if (algorithm=="dalponte2016"){

    # Dalponte 2016
    crowns <- lidR::lastrees(las, dalponte2016(chm, ttops,max_cr = 7))
    contour = lidR::tree_hulls(crowns)

    if(plots){
      plot(crowns, color = "treeID", colorPalette = col)
      plot(chm, col = height.colors(50))
      plot(contour, add = T)
    }
  }

  if(algorithm=="li2012"){

    # tree segmentation
    crowns<-lidR::lastrees(las, li2012(dt1 = 1,dt2=2,hmin=2,speed_up = 10))

    # display
    tree = lidR::lasfilter(crowns, !is.na(treeID))

    if(plots){
      plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1)
    }

  }

  if(algorithm=="silva2016"){

    crowns<-lidR::lastrees(las, silva2016(chm, ttops, max_cr_factor = 0.8, exclusion = 0.2))

    # display
    tree = lidR::lasfilter(crowns, !is.na(treeID))

    # More stuff
    contour = lidR::tree_hulls(crowns)

    if(plots){
      plot(tree, color = "treeID", colorPalette = pastel.colors(100), size = 1,backend="rgl")
      plot(chm, col = height.colors(50))
      plot(contour, add = T)
    }
  }

  return(crowns)
}
