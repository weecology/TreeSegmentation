## Detection network training
library(TreeSegmentation)
library(batchtools)

#Location of the training tiles
save_dir="/home/b.weinstein/NeonTreeEvaluation_analysis/Weinstein_unpublished/pretraining"
log_dir = "/home/b.weinstein/logs/batchtools/"
reg = loadRegistry(file.dir = log_dir,writeable=TRUE)
clearRegistry()
print("registry created")

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

tiles<-list.files("/orange/ewhite/b.weinstein/NeonTreeEvaluation",pattern=".laz")
sites<-str_match(tiles,"NEON_\\w+_(\\w+)_DP1")[,2]
tile_df<-data.frame(Site=sites,Tile=tiles)
batch_df<-merge(site_df,tile_df)

#find site index

ids = batchMap(fun = detection_training_benchmark,
               site=batch_df$Site,
               path=batch_df$Tile,
               silva_cr_factor=batch_df$max_cr_factor,
               silva_exclusion=batch_df$exclusion)

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

