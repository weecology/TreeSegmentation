#main
retrieve_field_data <- function(){
  library(tidyverse)
  library(devtools)
  library(neonUtilities)
  library(downloader)
  library(httr)
  library(jsonlite)
  
  #source files
  file.sources = paste("./Retriever/src/retriever_src", list.files("./Retriever/src/retriever_src", pattern="*.R"), sep="/")
  sapply(file.sources,source,.GlobalEnv)
  
  #data products download
  # chemical >>  DP1.10026.001
  # isotopes >> DP1.10053.001
  # vegetation structure >> DP1.10098.001
  get_data(10026)
  get_data(10053)
  get_data(10098)
  
  #harmonize the three data products to make a single database
  stack_chemical_leaf_products(10026)
  stack_isotopes_leaf_products(10053)
  
  # get coordinates and position of the vegetation structure trees
  get_vegetation_structure()
  
  #now connect with field data and position
  get_joint_dataset()
}