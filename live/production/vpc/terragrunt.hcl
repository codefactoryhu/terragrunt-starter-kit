terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//.?version=5.14.0"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  cidr                                 = include.env.locals.vpc_cidr
  azs                                  = include.env.locals.availability_zone
  private_subnets                      = [for k, v in include.env.locals.availability_zone : cidrsubnet(include.env.locals.vpc_cidr, 4, k)]
  public_subnets                       = [for k, v in include.env.locals.availability_zone : cidrsubnet(include.env.locals.vpc_cidr, 8, k + 48)]
 
  create_egress_only_igw               = include.env.locals.vpc_create_egress_only_igw
  enable_dns_hostnames                 = include.env.locals.vpc_enable_dns_hostnames
  enable_dns_support                   = include.env.locals.vpc_enable_dns_support
  enable_nat_gateway                   = include.env.locals.vpc_nat_gateway
  single_nat_gateway                   = include.env.locals.vpc_single_nat_gateway

  private_route_table_tags                                         = { Name = "${include.env.locals.env}-private" }
  private_subnet_tags = {
    "Name"                                                         = "${include.env.locals.env}-private"
    "kubernetes.io/role/internal-elb"                              = 1
    "kubernetes.io/cluster/${include.env.locals.env}-${include.env.locals.eks_cluster_name}" = "owned"
  }
 
  public_route_table_tags                                          = { Name = "${include.env.locals.env}-public"  }
  public_subnet_tags = {
    "Name"                                                         = "${include.env.locals.env}-public"
    "kubernetes.io/role/elb"                                       = 1
    "kubernetes.io/cluster/${include.env.locals.env}-${include.env.locals.eks_cluster_name}" = "owned"
  }

  tags                                  = include.env.locals.tags
}

skip = include.env.locals.skip_module.vpc