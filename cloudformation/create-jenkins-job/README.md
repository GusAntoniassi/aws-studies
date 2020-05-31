# Create Jenkins Job Lambda

## Configuration
- Configure the job/parameters.json
- Upload the Lambda code in S3
    - `pip install -r ./lambda/requirements.txt --target ./lambda/package`
    - `./create-zip.sh`
    - `aws s3 cp create-jenkins-job-lambda.zip s3://mybucketname/create-jenkins-job-lambda.zip`
- Deploy the Lambda stack passing the S3 bucket name and key as parameters
- [Create a Jenkins API token](https://stackoverflow.com/a/45466184/2272346)
- Deploy the CloudFormation job custom resource with the parameters