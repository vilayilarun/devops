# Kubernetes provider
provider "kubernetes" {
    load_config_file = "false"
    #end point of the cluster
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
    name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.0"
  # insert the 17 required variables here
  # name of the K8s cluster 
  cluster_name = "spark"
  cluster_version = "1.23"
  # list of subnets on worker nodes to be provisioned
  subnets =  module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  tags = {
    env = "development"
  }
  worker_groups = [
    {
        instance_type = "t2.micro"
        name = "worker_group1"
        asg_desired_capacity = 2
    },
    {
        instance_type = "t2.medium"
        name = "worker_group2"
        asg_desired_capacity = 1  
    }
  ]
}