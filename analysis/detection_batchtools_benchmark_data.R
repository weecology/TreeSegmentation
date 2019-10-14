## Detection network training
library(TreeSegmentation)
library(batchtools)

#Location of the training tiles
base_dir = "/home/b.weinstein/logs/batchtools/NeonTreeEvaluation/training/"
log_dir = "/home/b.weinstein/logs/batchtools/"
reg = loadRegistry(file.dir = log_dir,writeable=TRUE)
clearRegistry()
print("registry created")

#Define testing function
silva_benchmark<-function(site, silva_cr_factor,silva_exclusion){

  #check if folder exists
  save_dir="/home/b.weinstein/NeonTreeEvaluation_analysis/Weinstein_unpublished/pretraining"
  results_path<-paste("Results/detection_boxes/benchmark/",site,"/",sep="")
  if(!dir.exists(results_path)){
    dir.create(results_path)
  }

  #Passed checks
  print(paste(site,"Running"))
  detection_training(site=site,silva_cr_factor=silva_cr_factor,silva_exclusion=silva_exclusion,save_dir = save_dir)
}

#batchtools submission
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)

#map each file to a new job
#Set parameters based on whether site is decidous ("D") or coniferous ("C")
site_df<-data.frame(Site=c("SJER","TEAK","NIWO","MLBS","BART","BLAN","BONA","CLBJ","DELA","DSNY","HARV","JERC","LENO","ONAQ","OSBS","SCBI","SOAP","TALL","UNDE","WREF"),Type=c("D","C","C","D","D","D","D","D","D","C","D","D","D","C","C","D","D","D","D","C"))
parameter_df<-data.frame(Type=c("C","D"),max_cr_factor=c(0.2,0.9),exclusion=c(0.4,0.3))
site_df<-merge(site_df,parameter_df)
site_params<-site_df[site_df$Site == site,]

silva_cr_factor<-site_params$max_cr_factor
silva_exclusion<- site_params$exclusion

ids = batchMap(fun = run_detection,
               basedir=basedir,
               site=site,
               silva_cr_factor=silva_cr_factor,
               silva_exclusion=silva_exclusion)

#Run in chunks of 10
ids[, chunk := chunk(job.id, chunk.size = 2)]

print(reg)

# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "12GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())

