terraform {
  source = "tfr:///terraform-aws-modules/eks/aws//.?version=20.26.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = file("../../../provider-config/eks/eks.tf")
}

inputs = {
  cluster_version                       = include.env.locals.eks_cluster_version
  cluster_name                          = "${include.env.locals.env}-${include.env.locals.eks_cluster_name}"
  cluster_enabled_log_types             = include.env.locals.eks_log_types
  cluster_endpoint_public_access        = include.env.locals.eks_cluster_endpoint_public_access
  cluster_endpoint_private_access       = include.env.locals.eks_cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs  = include.env.locals.eks_cluster_endpoint_public_access_cidrs
  vpc_id                                = dependency.vpc.outputs.vpc_id
  subnet_ids                            = dependency.vpc.outputs.private_subnets

  # Authentication
  authentication_mode                   = "API_AND_CONFIG_MAP"
  access_entries                        = include.env.locals.eks_access_entries

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = dependency.kms.outputs.key_arn
  }

  # Cloudwatch log group
  create_cloudwatch_log_group            = include.env.locals.eks_create_cloudwatch_log_group 
  cloudwatch_log_group_retention_in_days = include.env.locals.eks_cloudwatch_log_group_retention_in_days

  # Cluster tags
  cluster_tags                            = include.env.locals.tags
  cluster_encryption_policy_tags          = include.env.locals.tags
  iam_role_tags                           = include.env.locals.tags

  # Cluster security group
  cluster_security_group_name             = "${include.env.locals.env}-${include.env.locals.eks_cluster_name}-cluster-sg"
  cluster_security_group_tags             = include.env.locals.tags

  # Node security group
  node_security_group_name                     = "${include.env.locals.env}-${include.env.locals.eks_cluster_name}-node-sg"
  node_security_group_tags                     = include.env.locals.tags

  cluster_addons = {
    coredns = {
      addon_version               = include.env.locals.eks_coredns_addon_version
    }
    kube-proxy = {
      addon_version               = include.env.locals.eks_kube_proxy_addon_version
    }
    vpc-cni = {
      addon_version               = include.env.locals.eks_vpc_cni_addon_version
    }
    aws-ebs-csi-driver = {
      addon_version               = include.env.locals.eks_aws_ebs_csi_driver_addon_version
      service_account_role_arn    = include.env.locals.eks_aws_ebs_csi_driver_role_arn
    }
  }

  eks_managed_node_groups = {
    "${include.env.locals.env}-${include.env.locals.eks_cluster_name}-ng" = {
                     description  = "EKS managed general node group launch template"
                     disk_size    = include.env.locals.eks_nodegroup_disk_size
                     desired_size = include.env.locals.eks_nodegroup_desired_size
                     min_size     = include.env.locals.eks_nodegroup_min_size
                     max_size     = include.env.locals.eks_nodegroup_max_size
      
      ami_release_version = include.env.locals.eks_nodegroup_ami_release_version

      labels = {
        role = "general"
      }

      instance_types                 = include.env.locals.eks_nodegroup_instance_types
      
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      capacity_type                  = include.env.locals.eks_nodegroup_capacity_type
    }
  }
  
  tags = {
    Name            = "${include.env.locals.env}-${include.env.locals.project}"
    Environment     = "${include.env.locals.env}"
  }
}

dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000"
    private_subnets = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
  }
}


dependency "kms" {
  config_path = "${get_original_terragrunt_dir()}/../kms"

  mock_outputs = {
    key_arn = "arn:aws:::::"
  }
}

skip = include.env.locals.skip_module.eks