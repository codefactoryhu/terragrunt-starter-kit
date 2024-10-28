terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks/.?version=5.47.1"
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
  role_name                      = include.env.locals.ebs_csi_irsa_role_name
  attach_ebs_csi_policy          = include.env.locals.ebs_csi_irsa_attach_ebs_csi_policy
  ebs_csi_kms_cmk_ids            = include.env.locals.ebs_csi_irsa_ebs_csi_kms_cmk_ids
  external_secrets_kms_key_arns  = include.env.locals.ebs_csi_irsa_external_secrets_kms_key_arns
  oidc_providers = {
    main = {
      provider_arn               = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = include.env.locals.ebs_csi_irsa_namespace_service_accounts
    }
  }
  tags = include.env.locals.tags
}

dependency "eks" {
  config_path = "${get_original_terragrunt_dir()}/../eks"

  mock_outputs = {
    oidc_provider_arn       = "arn:::"
  }
}

skip = include.env.locals.skip_module.ebs_csi_irsa