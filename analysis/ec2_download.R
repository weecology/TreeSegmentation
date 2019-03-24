#Ec2
library("aws.s3")
library(yaml)
config<-read_yaml("../.config.yaml")
print(config)
# specify keys as environment variables
Sys.setenv("AWS_ACCESS_KEY_ID" = config$ID,
           "AWS_SECRET_ACCESS_KEY" = config$key,
           "AWS_S3_ENDPOINT" = config$endpoint)
get_bucket(config$bucket)

#compare to
#PATH=/Users/ben/.local/lib/aws/bin/:$PATH
#aws s3 ls neon-aop-product --endpoint-url "https://s3.data.neonscience.org"
