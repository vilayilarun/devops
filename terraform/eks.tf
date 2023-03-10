# Kubernetes provider
provider "kubernetes" {
    # load_config_file = "false"
    #end point of the cluster
    # host = data.aws_eks_cluster.myapp-cluster.endpoint
    host = module.eks.cluster_endpoint
    # token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# data "aws_eks_cluster" "myapp-cluster" {
#     name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "myapp-cluster" {
#     name = module.eks.cluster_id
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.myapp-vpc.vpc_id
  subnet_ids               = module.myapp-vpc.private_subnets
  control_plane_subnet_ids = module.myapp-vpc.private_subnets
  # Self Managed Node Group(s)
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.large"]
      capacity_type  = "SPOT"
    }
  }
  
  # self_managed_node_group_defaults = {
  #   instance_type                          = "t2.medium"
  #   update_launch_template_default_version = true
  #   iam_role_additional_policies = {
  #     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  #   }
  # }

  #   self_managed_node_groups = {
  #   one = {
  #     name         = "mixed-1"
  #     max_size     = 2
  #     desired_size = 1

  #     use_mixed_instances_policy = true
  #     mixed_instances_policy = {
  #       instances_distribution = {
  #         on_demand_base_capacity                  = 0
  #         on_demand_percentage_above_base_capacity = 10
  #         spot_allocation_strategy                 = "capacity-optimized"
  #       }

  #       override = [
  #         {
  #           instance_type     = "t2.large"
  #           weighted_capacity = "1"
  #         },
  #         {
  #           instance_type     = "t2.medium"
  #           weighted_capacity = "1"
  #         },
  #       ]
  #     }
  #   }
  # }
}
