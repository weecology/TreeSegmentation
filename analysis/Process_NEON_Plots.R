### Download NEON tower plots and clip to tile extent
#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)
library(batchtools)
library(TreeSegmentation)
library(neonUtilities)
library(dplyr)

reg = loadRegistry(file.dir = "/home/b.weinstein/logs/batchtools/",writeable=TRUE)
clearRegistry()
print("registry created")
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)


process_site<-function(site){
  fold<-paste("/orange/ewhite/NeonData/",site,sep="")
  #byPointsAOP(dpID="DP3.30010.001",site=site,year="2018",check.size=F, savepath=fold)
  #byPointsAOP(dpID="DP1.30003.001",site=site,year="2018",check.size=F, savepath=fold)
  byPointsAOP(dpID="DP3.30006.001",site=site,year="2018",check.size=F, savepath=fold)

  ##Cut Tiles
  #crop_rgb_plots(sites[x])
  #crop_lidar_plots(sites[x])
  #crop_hyperspectral_plots(sites[x])
}

#sites<-c("ARIK","BARR","BART","BONA","CLBJ","CPER","CUPE","DEJU","DELA","DSNY","GRSM","GUAN",
#"GUIL","HARV","HEAL","HOPB","HOPB","JERC","JORN","KONZ","LAJA","LENO","LIRO","MCDI","MLBS","MOAB","NIWO","NOGP","OAES","OSBS","PRIN","REDB","RMNP","SCBI","SERC","SJER","SOAP","SRER","STEI","STER","TALL","TEAK","TOOL","UKFS","UNDE","WLOU","WOOD","WREF")

sites<-c("TEAK","SJER","MLBS","NIWO")
ids = batchMap(fun = process_site,
               site=sites)

#Run in chunks of 20
ids[, chunk := chunk(job.id, chunk.size = 20)]

# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "5GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())

