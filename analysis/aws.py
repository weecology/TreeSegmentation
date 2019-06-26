#in amazon env - aws configure already set
import boto3
import yaml
import os

with open("../.config.yaml") as f:
    config = yaml.load(f)

#set config
os.environ["AWS_ACCESS_KEY_ID"] =  config["ID"]
os.environ["AWS_SECRET_ACCESS_KEY"] = config["key"]

# Let's use Amazon S3
s3 = boto3.resource('s3', endpoint_url="https://s3.data.neonscience.org")
bucket = s3.Bucket(config["bucket"])

for obj in bucket.objects.filter(Prefix="2016"):
    print(obj.key)