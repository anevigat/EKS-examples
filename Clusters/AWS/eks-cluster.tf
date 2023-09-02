
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.22.0
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.22.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  subnets                         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  enable_irsa                     = true
  write_kubeconfig                = false

  tags = {
    "Owner" = var.owner
    "Env"   = var.env
    "Name"  = var.cluster_name
  }

  vpc_id = module.vpc.vpc_id

  map_roles = [
    {
      "groups" : ["system:masters"],
      "rolearn" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role}",
      "username" : "admin"
    },
    {
      "groups" : [],
      "rolearn" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.dev_role}",
      "username" : "dev-user"
    }
  ]

  worker_groups = [
    for x in var.worker_groups : {
      name                 = x.name
      instance_type        = try(x.instance_type, var.workers_instance_type)
      root_volume_type     = try(x.root_volume_type, var.workers_root_volume_type)
      root_volume_size     = try(x.root_volume_size, var.workers_root_volume_size)
      asg_desired_capacity = try(x.asg_desired_capacity, var.workers_asg_desired_capacity)
      asg_min_size         = try(x.asg_min_size, var.workers_asg_min_size)
      asg_max_size         = try(x.asg_max_size, var.workers_asg_max_size)
      tags = [
        {
          "key"                 = "Owner"
          "propagate_at_launch" = "false"
          "value"               = var.owner
        },
        {
          "key"                 = "Env"
          "propagate_at_launch" = "false"
          "value"               = var.env
        },
        {
          "key"                 = "EKS"
          "propagate_at_launch" = "false"
          "value"               = var.cluster_name
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    }
  ]
}