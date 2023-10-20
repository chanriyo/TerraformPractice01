# AWS CICD Example

This repository provides an example of setting up AWS infrastructure and CI/CD using Terraform and AWS CodePipeline.
The system architecture is documented in the 'design.drawio' file.

## Prerequisites

- AWS CLI is installed and configured with access to your AWS environment.

## Getting Started

### Clone the repository

To get started, clone this repository:
```
git clone https://github.com/chanriyo/TerraformPractice01.git
```
### Setting up AWS Infrastructure

#### Install AWS CLI

If you haven't already, install the AWS CLI and configure it with your AWS credentials. 
You can add your AWS credentials in the `~/.aws/credentials` file, using a profile name:
```
[profile_name]
aws_access_key_id = {access_key}
aws_secret_access_key = {secret_access_key}
```

#### Set AWS CLI profile

Before running Terraform, set the AWS CLI profile that you added in the previous step:
```
export AWS_PROFILE="profile_name"
```

#### Deploy AWS Infrastructure
To deploy the AWS infrastructure using Terraform, run the following command:
```
terraform apply
```
Make sure you have the appropriate .tf files with the necessary configurations for your AWS environment.

After the Terraform deployment is complete, you will see the endpoint for the ALB.
Accessing this endpoint will give you a response from the ALB. To access Nginx, append "/app/" to the endpoint.

#### Setting up CI/CD
Drag and drop the contents of the AWS-cloud9 directory into your AWS-Cloud9 environment.
Then, execute the following command in the AWS-Cloud9 terminal:
```
chmod +x Setting.sh
./Setting.sh
```

#### AWS CodePipeline
To test the CI/CD setup, run the AWS CodePipeline.
Currently, it will fail as the pipeline is not fully configured.

### Setting up AWS Infrastructure
To remove the environment and prevent unnecessary charges, use the following command:
```
terraform destroy
```
This command will remove the AWS environment created by Terraform.
