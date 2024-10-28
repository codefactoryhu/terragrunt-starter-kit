locals {
    global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

    project     = local.global_vars.locals.project
    region      = local.global_vars.locals.region
    account_id  = local.global_vars.locals.development_account_id
    env         = "production"

    # Modules set true are ignored during Terraform run
    skip_module = {
        acm                         = false
        eks                         = false
        eks-ebs-irsa                = false
        helm-release                = false
        kms                         = false
        vpc                         = false
    } 

    # VPC variables
    vpc_cidr                             = "10.0.0.0/16"
    vpc_nat_gateway                      = true
    vpc_single_nat_gateway               = true
    vpc_create_egress_only_igw           = true
    vpc_enable_dns_hostnames             = true
    vpc_enable_dns_support               = true
    region                               = "eu-west-2"
    availability_zone                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

    # KMS key variabless
    kms_customer_master_key_spec = "SYMMETRIC_DEFAULT"
    kms_key_usage                = "ENCRYPT_DECRYPT"
    kms_key_administrators       = ["${local.iam_role}"]

    # EKS variables
    eks_cluster_name                    = "${local.project}-${local.env}-cluster"
    eks_cluster_version                 = "1.30"
    eks_log_types                       = ["audit", "api", "authenticator"]
    eks_cluster_endpoint_public_access  = true
    eks_cluster_endpoint_private_access = true

    eks_coredns_addon_version            = "v1.11.1-eksbuild.9"
    eks_kube_proxy_addon_version         = "v1.29.3-eksbuild.2"
    eks_vpc_cni_addon_version            = "v1.18.1-eksbuild.3"
    eks_aws_ebs_csi_driver_addon_version = "v1.31.0-eksbuild.1"
    eks_aws_ebs_csi_driver_role_arn      = "arn:aws:iam::${local.aws_id}:role/${local.env}-${local.project}-ebs-csi"

    eks_create_cloudwatch_log_group            = true
    eks_cloudwatch_log_group_retention_in_days = 90

    # EKS nodegroup variables
    eks_nodegroup_desired_size        = 2
    eks_nodegroup_min_size            = 1
    eks_nodegroup_max_size            = 3
    eks_nodegroup_disk_size           = 50
    eks_nodegroup_instance_types      = ["t3.small"]
    eks_nodegroup_capacity_type       = "ON_DEMAND"
    eks_nodegroup_ami_release_version = "1.30.3-20240522"

    # EKS allowed users
    eks_access_entries = {
        exampleuser = {
            principal_arn     = "arn:aws:iam::${local.aws_id}:user/example.user"
            kubernetes_groups = ["eks-admin"]
            policy_associations = {
                clusteradmin = {
                policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
                access_scope = {
                    namespaces = []
                    type       = "cluster"
                    }
                }
            }
        }
    }

    # EBS CSI IRSA variables
    ebs_csi_irsa_role_name                     = "${local.project}-ebs-csi-role"
    ebs_csi_irsa_attach_ebs_csi_policy         = true
    ebs_csi_irsa_namespace_service_accounts    = ["kube-system:ebs-csi-controller-sa"]
    ebs_csi_irsa_ebs_csi_kms_cmk_ids           = []
    ebs_csi_irsa_external_secrets_kms_key_arns = ["arn:aws:kms:*:*:key/*"]

    # Helm release
    helm_releases = {
        reloader = {
            repository           = "https://stakater.github.io/stakater-charts"
            chart                = "reloader"
            chart_version        = "1.0.62"
            create_namespace     = true
            kubernetes_namespace = "infra"
            tags                 = "${local.tags}"
        }

        fluentbit = {
            repository           = "https://fluent.github.io/helm-charts"
            chart                = "fluent-bit"
            chart_version        = "0.34.2"
            kubernetes_namespace = "kube-system"

            values = [
                <<EOF
                serviceAccount:
                create: true
                annotations: 
                    eks.amazonaws.com/role-arn: arn:aws:iam::${local.account_id}:role/${local.env}-${local.project}-fluentbit
                name: aws-for-fluent-bit

                config:
                inputs: |
                    [INPUT]
                        Name cpu
                        Tag cpu

                outputs: |
                    [OUTPUT]
                        Name opensearch
                        Match *
                        Host opensearch-cluster-master
                        Port 9200
                        Index my_index
                        Type my_type
                EOF   
            ]
            tags                 = "${local.tags}"      
        }    
    }

  
    # Tags
    tags = {
        Name            = "${local.env}-${local.project}"
        Environment     = "${local.env}"
        Project         = "${local.project}"
        ManagedBy       = "Terragrunt"
    }
}