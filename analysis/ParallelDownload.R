### Download AOP data tiles in parallel

#devtools::install_github("Weecology/Neon-Utilities/neonUtilities",dependencies=F)
## Detection network training
library(TreeSegmentation)
library(batchtools)
library(stringr)
library(neonUtilities)

pdownload<-function(site,year="2019"){
  print(site)
  fold<-paste("/orange/ewhite/NeonData/",site=site,sep="")

  #RGB
  neonUtilities::ParallelFileAOP(dpID = "DP3.30010.001",site = site,year="2019",check.size=F, savepath=fold,cores=20)

  #LIDAR
  #ParallelFileAOP(dpID = "DP1.30003.001",site = site,year="2018",check.size=F, savepath=fold,cores=5)

  #Hyperspec
  #ParallelFileAOP(dpID = "DP3.30006.001",site = site,year="2018",check.size=F, savepath=fold,cores=5)
}


sites=c("SJER","TEAK","NIWO","MLBS","BART","BLAN","BONA","CLBJ","DELA","DSNY","HARV","JERC","LENO","ONAQ","OSBS","SCBI","SOAP","TALL","UNDE","WREF")

#Location of the training tiles
log_dir = "/home/b.weinstein/logs/batchtools/"
reg = loadRegistry(file.dir = log_dir,writeable=TRUE)
clearRegistry()
print("registry created")

#batchtools submission
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)

#map each file to a new job
#find site index
ids = batchMap(fun = pdownload,
               site=sites,
               year="2019")

#Run in chunks of 1
ids[, chunk := chunk(job.id, chunk.size = 1)]

print(reg)
# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "4GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())

