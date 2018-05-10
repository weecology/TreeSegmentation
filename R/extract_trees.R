#' Extract individual las files for segmented trees
#'
#' \code{extra_trees} computes an lidar-based segmentation, based on multiple available methods, and splits the results into individual las files for each predicted tree.
#' @param las Character or Vector. Path to lidar tiles on system to be processed. May be a single tile or vector of tiles.
#' @param algorithm  Character. A vector of lidar unsupervised classification algorithm(s). Currently "silva","dalponte","li" and "watershed" are implemented. See \code{\link[lidR]{lastrees}}
#' @param output  Character. A set of "las" objects or a dataframe "df" of the xyz data, depending on the next processing step.
#' @return A list object for each las tile processed. Each list is a list of segmented trees, either in las or dataframes, based on the output argument.
#' @export
#'
extract_trees<-function(las=NULL,algorithm="silva",cores=NULL,output){

  #If running in parallel
  `%dopar%` <- foreach::`%dopar%`
  if(!is.null(cores)){
    cl<-parallel::makeCluster(cores)
    doSNOW::registerDoSNOW(cl)
  }

  #set file name
  #for each tile in path_to_tiles
  results<-foreach::foreach(g=1:length(las),.packages=c("TreeSegmentation","lidR","sp")) %dopar% {

    #Select tile
    inpath<-las[g]

    #Run segmentation methods
    tiles<-list()
    if("silva" %in% algorithm){
      print("silva")
      tiles$silva<-silva2016(path=inpath,output="tile")
    }

    if("dalponte" %in% algorithm){
      print("Dalpone")
      tiles$dalponte<-dalponte2016(path=inpath,output="tile")
    }

    if("li" %in% algorithm){
      print("li")
      tiles$li<-li2012(path=inpath,output="tile")
    }

    if("watershed" %in% algorithm){
      print("watershed")
      tiles$watershed<-watershed(path=inpath,output="tile")
    }

    #remove ground class
    tiles<-lapply(tiles,function(x){
      x<-lasfilter(x,!Classification==2)
    })

    #return dataframe of results or convert back to lidR object
    if(output=="df"){
      tree_las<-list()
      for(i in 1:length(tiles)){
        tree_las[[i]]= split(tiles[[i]]@data, tiles[[i]]@data$treeID)
      }

      names(tree_las)<-names(tiles)
      return(tree_las)
    } else{

      #For each method compute result statistics
      tree_las<-list()
      for(i in 1:length(tiles)){
        ind_trees= split(tiles[[i]]@data, tiles[[i]]@data$treeID)
        tree_las[[i]] = lapply(ind_trees, lidR::LAS, header = tiles[[i]]@header)
      }
      names(tree_las)<-names(tiles)
      return(tree_las)
    }

  }

  #give result list the input file names
  names(results)<-las

  #Stop cluster if needed.
  if(!is.null(cores)){
    parallel::stopCluster(cl)
  }

  return(results)
}
