# IAM User and a pair of S3 Buckets

This CF/TF template creates an IAM User (named `sally`), a pair of S3 buckets, and an IAM policy that allows/denies access to the buckets. The goal is to explore how IAM policies work by attaching these policies and see how it changes Sally's permissions.

Included for completion's sake are the original files from [Adrian Cantrill](https://cantrill.io/): https://learn-cantrill-labs.s3.amazonaws.com/awscoursedemos/0052-aws-mixed-iam-simplepermissions/simpleidentitypermissions.zip

## Usage

### CloudFormation

Create:

```console
$ CFBUCKETNAME=cfbucket-$RANDOM
$ aws s3api create-bucket --bucket $CFBUCKETNAME
$ aws cloudformation deploy --template-file ./iam-with-buckets.yml --stack-name IAMWithBuckets --s3-bucket $CFBUCKETNAME --parameter-overrides sallypassword=Passw0rd --capabilities CAPABILITY_NAMED_IAM
```

Destroy:

```console
$ aws cloudformation delete-stack --stack-name IAMWithBuckets
$ aws s3 rm s3://$CFBUCKETNAME --recursive
$ aws s3api delete-bucket --bucket $CFBUCKETNAME
```

### Terraform

Create:

```console
$ terraform init
$ VARS=-var="aws_profile=default"
$ terraform plan $VARS
$ terraform apply $VARS
```

Destroy:

```console
$ terraform destroy $VARS
```
