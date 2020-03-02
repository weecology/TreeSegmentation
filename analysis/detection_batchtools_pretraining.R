## Detection network training
library(TreeSegmentation)
library(batchtools)
library(stringr)
library(dplyr)

#Location of the training tiles
save_dir="/home/b.weinstein/DeepForest_Model/pretraining"

log_dir = "/home/b.weinstein/logs/detection/"
reg = loadRegistry(file.dir = log_dir,writeable=TRUE)
clearRegistry()
print("registry created")

#batchtools submission
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)

#map each file to a new job
#Set parameters based on whether site is decidous ("D") or coniferous ("C")
site_df<-data.frame(Site=c("YELL","WLOU","UKFS","SRER","SERC","RMNP","REDB","OAES","NOGP","MOAB","KONZ","HOPB","HEAL","DEJU","CUPE","ABBY","SJER","TEAK","NIWO","MLBS","BART","BLAN","BONA","CLBJ","DELA","DSNY","HARV","JERC","LENO","ONAQ","OSBS","SCBI","SOAP","TALL","UNDE","WREF"),
                    Type=c("D","D","D","C","D","D","D","D","D","D","D","D","C","D","D","C","D","C","C","D","D","D","D","D","D","C","D","D","D","C","C","D","D","D","D","C"))

parameter_df<-data.frame(Type=c("C","D"),max_cr_factor=c(0.2,0.9),exclusion=c(0.4,0.3))
site_df<-merge(site_df,parameter_df)

#Find LiDAR tiles
lidar_tiles<-list.files("/orange/ewhite/NeonData/",pattern=".laz",full.names = T,recursive = T)
sites<-str_match(lidar_tiles,"\\w+_(\\w+)_DP1")[,2]
tile_df<-data.frame(Site=sites,Tile=lidar_tiles) %>% filter(!is.na(Site)) %>% filter(!str_detect(Tile,"Metadata")) %>% filter(str_detect(Tile,"ClassifiedPointCloud"))
batch_df<-merge(site_df,tile_df)

#Find matching RGB tile and give the index and year metadata
rgb_tiles<-list.files("/orange/ewhite/NeonData/",pattern=".tif",full.names = T,recursive = T)
rgb_tiles<-data.frame(RGB=rgb_tiles) %>% filter(str_detect(RGB,"Mosaic")) %>% filter(str_detect(RGB,"image"))
rgb_tiles$geo_index<-str_match(rgb_tiles$RGB,"(\\d+_\\d+)_image")[,2]
rgb_tiles$year<-str_match(rgb_tiles$RGB,"DP3.30010.001/(\\d+)/FullSite/")[,2]

#For each site, only use most recent year.
batch_df <- batch_df %>% mutate(year=as.numeric(str_match(Tile,"/(\\w+)_\\w+_\\w+/L1")[,2])) %>% group_by(Site) %>% filter(year==max(year))

#Print number of tiles per site
print(paste("Total tiles:",nrow(batch_df)))

print("Number of tiles per site")
batch_df %>% group_by(Site) %>% summarize(n=n()) %>% as.data.frame() %>% arrange(desc(n))

#find site index
ids = batchMap(fun = detection_training_benchmark,
               rgb_tiles=rgb_tiles,
               path=as.character(batch_df$Tile),
               silva_cr_factor=batch_df$max_cr_factor,
               silva_exclusion=batch_df$exclusion,
               save_dir=save_dir)

#Run in chunks of 20
ids[, chunk := chunk(job.id, chunk.size = 20)]

print(reg)

# Set resources: enable memory measurement
res = list(measure.memory = TRUE,walltime = "12:00:00", memory = "10GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
print(getJobTable())

