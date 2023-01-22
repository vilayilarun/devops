# Provider deatils and the region
provider "aws" {
  region = "ap-south-1"
}

#Query list of Az in the region 

data "aws_availability_zones" "azs" {}

# AWS VPC module from the Terraform registry
module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  # name of the VPC inside the AWS
  name = "myapp-vpc"
  # cidr block for the VPC
  cidr = var.vpc_cidr_block
  #Specifiy the Cidr blocks of subnets.  For EKS the best practice is create one public and one private subnets in each AZ
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  #define that the subnets need to be deployed on all three AZ
  azs = data.aws_availability_zones.azs.name

  #enable nat gateway
  # All the private subnet will routr thier internet traffic thorugh this Single nat gateway.
  enable_nat_gateway = true
  single_nate_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/spark" = "shared"
  }

  public_subtnet_tags = {
    "kubernetes.io/cluster/spark" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_submet_tags = {
    "kubernetes.io/cluster/spark" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}