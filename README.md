## Architecture

![Infrastructure Architecture](./arch.jpg)

## Prerequisites
- A [AWS](https://aws.amazon.com/) account with a [IAM USER](https://aws.amazon.com/iam/)
- A [AWS](https://aws.amazon.com/) Storage is required for Terraform backend to store the state files.
- A [GitHub account](https://github.com/) 
- The [Terraform CLI](https://releases.hashicorp.com/terraform) installed locally and working
- A [Slack account](https://slack.com/) needs to created and inetgrated with Jenkins Server for sending the notifications.
- A  Jenkins Server is ready and runing.
- Install terraform and AWS CLI on your Jenkins server
- Install Helm on the Jenkins server whcih is used to deploy the container to the cluster.
## Overview
- This is a sample CI/CD project where we are going to deploy an python application the EKS cluetr. 
- The entier process is automated. This will create a docker image and push the image to dockerhub. 
- You guys can modify the repository details on jenkins file to push to the correct repository.
- Once the images has been pushed Jenkins will notify us on the slack
- After it it will create an EKS cluster on AWS. You need to pass the required parameters like Cluster name, region and so on.
- Jenkins will update the Helm charts with the image deatils and deploy it to the satging server first. This can be skipped
- Once the deployment is completed and fine deployment on production will be continued after getting successfull approvals.
- Jenkins will notify us deployment status
