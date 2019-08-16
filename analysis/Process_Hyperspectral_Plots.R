### Download NEON tower plots and clip to tile extent
library(batchtools)
library(TreeSegmentation)
library(dplyr)

reg = loadRegistry(file.dir = "/home/b.weinstein/logs/batchtools/",writeable=TRUE)
clearRegistry()
print("registry created")
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)

process_site<-function(site="TEAK", year="2019",false_color=FALSE){
  TreeSegmentation::crop_hyperspectral_plots(site,year,false_color=false_color)
}

#sites<-c("ABBY","ARIK","BARR","BART","BLAN","BONA","CLBJ","CPER","CUPE","DEJU","DELA","DSNY","GRSM","GUAN",
#"GUIL","HARV","HEAL","HOPB","JERC","JORN","KONZ","LAJA","LENO","LIRO","MCDI","MLBS","MOAB","NIWO","NOGP",
#"OAES","OSBS","PRIN","PUUM","REDB","RMNP","SCBI","SERC","SJER","SOAP","SRER","STEI","STER","TALL","TEAK","TOOL","UKFS","UNDE","WLOU","WOOD","WREF","YELL")

sites<-c("BLAN","LENO","DELA","PUUM")
ids = batchMap(fun = process_site,
               site=sites)

#Run in chunks of 4
ids[, chunk := chunk(job.id, chunk.size = 4)]

# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "7GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())
