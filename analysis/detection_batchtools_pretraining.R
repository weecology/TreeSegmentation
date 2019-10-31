## Detection network training
library(TreeSegmentation)
library(batchtools)
library(stringr)
library(dplyr)

#Location of the training tiles
save_dir="/home/b.weinstein/NeonTreeEvaluation_analysis/Weinstein_unpublished/pretraining"

log_dir = "/home/b.weinstein/logs/detection/"
reg = loadRegistry(file.dir = log_dir,writeable=TRUE)
clearRegistry()
print("registry created")

#batchtools submission
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)

#map each file to a new job
#Set parameters based on whether site is decidous ("D") or coniferous ("C")
site_df<-data.frame(Site=c("KONZ","REDB","SERC","ABBY","YELL","SJER","TEAK","NIWO","MLBS","BART","BLAN","BONA","CLBJ","DELA","DSNY","HARV","JERC","LENO","ONAQ","OSBS","SCBI","SOAP","TALL","UNDE","WREF"),
                    Type=c("D","C","D","C","C","D","C","C","D","D","D","D","D","D","C","D","D","D","C","C","D","D","D","D","C"))
parameter_df<-data.frame(Type=c("C","D"),max_cr_factor=c(0.2,0.9),exclusion=c(0.4,0.3))
site_df<-merge(site_df,parameter_df)

tiles<-list.files("/orange/ewhite/NeonData/",pattern=".laz",full.names = T,recursive = T)
sites<-str_match(tiles,"\\w+_(\\w+)_DP1")[,2]
tile_df<-data.frame(Site=sites,Tile=tiles) %>% filter(!is.na(Site)) %>% filter(!str_detect(Tile,"2017_Campaign")) %>% filter(!str_detect(Tile,"2017/FullSite")) %>% filter(str_detect(Tile,"ClassifiedPointCloud"))
batch_df<-merge(site_df,tile_df)

#For each site, only use most recent year.
batch_df <- batch_df %>% mutate(year=as.numeric(str_match(Tile,"/(\\w+)_\\w+_\\w+/L1")[,2])) %>% group_by(Site) %>% filter(year==max(year))

#find site index
ids = batchMap(fun = detection_training_benchmark,
               site=batch_df$Site,
               path=as.character(batch_df$Tile),
               silva_cr_factor=batch_df$max_cr_factor,
               silva_exclusion=batch_df$exclusion,
               save_dir=save_dir)

#Run in chunks of 30
ids[, chunk := chunk(job.id, chunk.size = 30)]

print(reg)

# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "10GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())

