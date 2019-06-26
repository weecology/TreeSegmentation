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

process_site<-function(site, year="2018"){
  fold<-paste("/orange/ewhite/NeonData/",site,sep="")
  crop_hyperspectral_plots(site,year)
}

#sites<-c("ARIK","BARR","BART","BONA","CLBJ","CPER","CUPE","DEJU","DELA","DSNY","GRSM","GUAN",
#"GUIL","HARV","HEAL","HOPB","HOPB","JERC","JORN","KONZ","LAJA","LENO","LIRO","MCDI","MLBS","MOAB","NIWO","NOGP","OAES","OSBS","PRIN","REDB","RMNP","SCBI","SERC","SJER","SOAP","SRER","STEI","STER","TALL","TEAK","TOOL","UKFS","UNDE","WLOU","WOOD","WREF")

sites<-c("TEAK","SJER","MLBS","NIWO")
ids = batchMap(fun = process_site,
               site=sites)

#Run in chunks of 20
ids[, chunk := chunk(job.id, chunk.size = 2)]

# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "5GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())

