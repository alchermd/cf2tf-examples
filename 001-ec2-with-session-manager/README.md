# Single EC2 instance with SessionManager

This CF/TF template creates an EC2 instance inside the default VPC with security group rules for SSH and HTTP access. No key pair is used, so the intended instance connection is via the SessionManager. The necessary role and instance profile is also included.

Original CF file from [Adrian Cantrill](https://cantrill.io/): https://learn-cantrill-labs.s3.amazonaws.com/awscoursedemos/0058-aws-simplecfn/ec2instance.yaml

## Usage

### CloudFormation

Create:

```console
$ CFBUCKETNAME=cfbucket-$RANDOM
$ aws s3api create-bucket --bucket $CFBUCKETNAME
$ aws cloudformation deploy --template-file ./ec2-instance.yml --stack-name BasicEC2Deployment --s3-bucket $CFBUCKETNAME
```

Destroy:

```console
$ aws cloudformation delete-stack --stack-name BasicEC2Deployment
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
