## Detection network training
library(TreeSegmentation)
library(batchtools)

#metadata
testing=F
site="TEAK"
basedir = "/orange/ewhite/NeonData/"

reg = loadRegistry(file.dir = "/home/b.weinstein/logs/batchtools/",writeable=TRUE)
clearRegistry()
print("registry created")

#Define optimal parameters
silva_params<-data.frame(Site=c("SJER","TEAK","NIWO"),max_cr_factor=c(0.9,0.2,0.2),exclusion=c(0.3,0.5,0.5))
site_params<-silva_params[silva_params$Site == site,]

#Quick debug option
if(testing){
  path<-"../data/NeonTreeEvaluation/TEAK/plots/TEAK_044.laz"
  system.time(results<-detection_training(path,site,year,site_params$max_cr_factor,site_params$exclusion))
 } else {

  #Lidar dir
  lidar_dir<-paste(basedir,site,"/DP1.30003.001/2018/FullSite/D17/2018_",site,"_3/L1/DiscreteLidar/ClassifiedPointCloud",sep="")
  lidar_files<-list.files(lidar_dir,full.names = T,pattern=".laz")
  #lidar_files<-lidar_files[!str_detect(lidar_files,"colorized")]

  rgb_dir<-paste(basedir,site,"/DP3.30010.001/2018/FullSite/D17/2018_",site,"_3/L3/Camera/Mosaic/V01/",sep="")

  #batchtools submission
  reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)

  #map each file to a new job
  #debugging
  lidar_files = lidar_files[1:50]
  silva_cr_factor<- site_params$max_cr_factor
  silva_exclusion<- site_params$exclusion

  ids = batchMap(fun = run_detection,
                 lidar_file=lidar_files,
                 site=site,
                 rgb_dir=rgb_dir,
                 year=year,
                 silva_cr_factor=silva_cr_factor,
                 silva_exclusion=silva_exclusion)

  #Run in chunks of 10
  ids[, chunk := chunk(job.id, chunk.size = 10)]

  print(reg)

  # Set resources: enable memory measurement
  res = list(measure.memory = TRUE)

  # Submit jobs using the currently configured cluster functions
  submitJobs(ids, resources = res, reg = reg)

  submitJobs(resources = list(walltime = "12:00:00", memory = "10GB"), reg = reg)
  waitForJobs(ids, reg = reg)
  getStatus(reg = reg)
  getErrorMessages(ids, missing.as.error = TRUE, reg = reg)
  print(getJobTable())
 }
