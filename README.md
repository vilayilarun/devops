## Architecture

![Infrastructure Architecture](./arch.jpg)

## Prerequisites
- A [AWS](https://aws.amazon.com/) account with a [IAM USER](https://aws.amazon.com/iam/)
- A [AWS](https://aws.amazon.com/) Storage account is required for Terraform backend to store the state files.
- A [GitHub account](https://github.com/) 
- The [Terraform CLI](https://releases.hashicorp.com/terraform) installed locally and working
- A [Slack account](https://slack.com/) needs to created and inetgrated with Jenkins Server for sending the notifications.
- A  Jenkins Server is ready and runing.
- Install [AWS CLI](https://aws.amazon.com/cli/) on your Jenkins server
- Install [helm](https://helm.sh/docs/intro/install/) on the Jenkins server whcih is used to deploy the container to the cluster.
-  A Terraform tfvars file is required with name production.tfvars
## Overview
- This is a simple end to end CI/CD project, where we are going to deploy a python application the EKS cluetr. 
- The entier process is automated and it would require a couple of integrations.
- You have to configure couple of Jenkins secrets and plugins
- Initailly the jenkins will create a Docker image and push the same to the docker-hub. The repository can be modified
- Once the image pushed Jnekins will update the image tag on the charts values.yaml file and push the same back to the GitHub.
- Once the images has been pushed Jenkins will notify us on the slack
- Now Jenkins will create an EKS cluster on AWS. You need to pass the required parameters like Cluster name, region and so on in the production.tfvars file.
- Jenkins will download the EKS configuratio to locally by calling the tfvars file for the helm deployment.
- Once the deployment is completed and fine deployment on production will be continued after getting successfull approvals.
- Jenkins will notify us deployment status
##### Plugins
1. git
2. slack notifications
3. aws cli
3. terraform
#### Secrets
##### You can use your own names for the screts but the code needs to be aligned accordingly.
1. SCM credentials (GitHub/SVN) with name "GitHub"
2. Repositroy Credentials with name "docker-hub"
3. AWS credentials "aws_access_key_id" and "aws_secret_access_key"
4. Slack credentials "slacktoken"
