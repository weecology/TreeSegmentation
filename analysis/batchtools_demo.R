library(batchtools)

#Batchtools tmp registry
reg = makeRegistry(file.dir = NA, seed = 1)
print(reg)
print("registry created")

print(reg)
# Toy function which creates a large matrix and returns the column sums
fun = function(n, p) colMeans(matrix(runif(n*p), n, p))

# Arguments to fun:
args = CJ(n = c(1e4, 1e5), p = c(10, 50)) # like expand.grid()
print(args)

#batchtools submission
reg$cluster.functions=makeClusterFunctionsSlurm(template = "detection_template.tmpl", array.jobs = TRUE,nodename = "localhost", scheduler.latency = 5, fs.latency = 65)
ids = batchMap(fun, args = args, reg = reg)

# Set resources: enable memory measurement
res = list(measure.memory = TRUE)

# Submit jobs using the currently configured cluster functions
submitJobs(ids, resources = res, reg = reg)
