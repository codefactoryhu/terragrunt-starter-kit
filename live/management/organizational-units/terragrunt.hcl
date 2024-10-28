terraform {
  source = "tfr:///blackbird-cloud/organization/aws//modules/organizational-units/.?version=3.0.5"
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
    organization_units = {
        "monitoring" = {
          name      = "monitoring"
          parent_id = include.env.locals.organization_root_id
          tags      = include.env.locals.tags
        }
        "production" = {
          name      = "production"
          parent_id = include.env.locals.organization_root_id
          tags      = include.env.locals.tags
        }
        "development" = {
          name      = "development"
          parent_id = include.env.locals.organization_root_id
          tags      = include.env.locals.tags
        }
    }
}

skip = include.env.locals.skip_module.organization_units

