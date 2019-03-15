#Ec2
library("aws.s3")
library(yaml)
config<-read_yaml(".config.yaml")
print(config)
# specify keys as environment variables
Sys.setenv("AWS_ACCESS_KEY_ID" = config$ID,
           "AWS_SECRET_ACCESS_KEY" = config$key,
           "AWS_S3_ENDPOINT" = config$endpoint)
bucketlist()

