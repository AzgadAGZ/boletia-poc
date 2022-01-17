locals {
  cluster_name       = "poc-eks"
  vpc_id             = ""
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  ami_id             = "ami-0193ebf9573ebc9f7"
  map_roles = [
    {
      rolearn  = "arn:aws:iam::149140628678:role/AWSReservedSSO_DevOps-dev_e3341c45fc92288c"
      username = "devops:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::149140628678:role/AWSReservedSSO_DevOps-stg_a39a86e9deccdb87"
      username = "devops:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::149140628678:role/AWSReservedSSO_DevOps-prod_bc2cf536d45227b8"
      username = "devops:{{SessionName}}"
      groups   = ["system:masters"]
    }
  ]
}

module "eks" {
  source                    = "git::git@github.com:AzgadAGZ/eks-module?ref=0.0.1"
  version                   = "0.0.1"
  cluster_name              = local.cluster_name
  cost-center               = "ENGINEERING"
  environment               = "dev"
  resource                  = "EKS"
  team                      = "SRE"
  vpc_id                    = local.vpc_id
  private_subnet_ids        = local.private_subnet_ids
  endpoint_public_access    = true
  aws_eks_managed_node      = false
  aws_eks_self_managed_node = true
  prometheus_enable         = true
  cluster_autoscaler_enable = true
  enable_irsa               = true
  map_additional_iam_roles  = local.map_roles
  worker_groups = [
    {
      name                 = "spot-a"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 200
      spot_price           = "0.10"
      instance_type        = "t3.xlarge"
      subnets              = ["${local.private_subnet_ids[0]}"]
      autoscaling_enabled  = true
      root_volume_size     = 150
      root_volume_type     = "gp2",
      ami_id               = local.ami_id
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
  },
  {
      name                 = "spot-b"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 200
      spot_price           = "0.10"
      instance_type        = "t3.xlarge"
      subnets              = ["${local.private_subnet_ids[1]}"]
      autoscaling_enabled  = true
      root_volume_size     = 150
      root_volume_type     = "gp2",
      ami_id               = local.ami_id
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
  },
  {
      name                 = "spot-c"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 200
      spot_price           = "0.10"
      instance_type        = "t3.xlarge"
      subnets              = ["${local.private_subnet_ids[2]}"]
      autoscaling_enabled  = true
      root_volume_size     = 150
      root_volume_type     = "gp2",
      ami_id               = local.ami_id
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "true"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "true"
          "value"               = "true"
        }
      ]
  }
  ]
}