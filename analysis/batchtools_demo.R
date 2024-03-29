library(batchtools)

#Batchtools tmp registry
reg = loadRegistry(file.dir = NA, seed = 1)
print(reg)
print("registry created")

print(reg)
# Toy function which creates a large matrix and returns the column sums
fun = function(n) {
  Sys.sleep(10)
  t<-Sys.time()
  print(paste("worker", n, "time is",t))
  return(t)
}

#batchtools submission
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 1, fs.latency = 65)
ids = batchMap(fun,args=list(n=seq(1:10)), reg = reg)

testJob(id=ids[1,],reg=reg)

# Set resources: enable memory measurement
res = list(walltime = "2:00:00", memory = "4GB")

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
waitForJobs(ids, reg = reg)
getStatus(reg = reg)
print(getJobTable())
