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
  subnet_ids =  module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  tags = {
    env = "development"
  }
  self_managed_node_group_defaults = {
    instance_type                          = "t2.medium"
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]  
  }
#   worker_groups = [
#     {
#         instance_type = "t2.micro"
#         name = "worker_group1"
#         asg_desired_capacity = 2
#     },
#     {
#         instance_type = "t2.medium"
#         name = "worker_group2"
#         asg_desired_capacity = 1  
#     }
#   ]
 }
  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 3
      desired_size = 2

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 10
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          {
            instance_type     = "t2.medium"
            weighted_capacity = "1"
          },
          {
            instance_type     = "t2.medium"
            weighted_capacity = "1"
          },
        ]
      }
    }
  }