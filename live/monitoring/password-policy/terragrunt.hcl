terraform {
  source = "tfr:///plus3it/tardigrade-iam-account/aws//.?version=3.0.0"
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
  create_accessanalyzer = include.env.locals.create_access_analyzer
  tags                  = include.env.locals.tags
} 

skip = include.env.locals.skip_module.password_policy