terraform {
  source = "tfr:///blackbird-cloud/organization/aws//modules/accounts/.?version=3.0.5"
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
    accounts = {
        "production" = {
            email                            = include.env.locals.production_account_email
            delegated_administrator_services = []
            parent_id                        = dependency.organizational-units.outputs.ous["production"].id
            close_on_deletion                = include.env.locals.account_close_on_deletion 
        }
        "monitoring" = {
            email                            = include.env.locals.monitoring_account_email
            delegated_administrator_services = []
            parent_id                        = dependency.organizational-units.outputs.ous["monitoring"].id
            close_on_deletion                = include.env.locals.account_close_on_deletion 
        }
        "development" = {
            email                            = include.env.locals.development_account_email
            delegated_administrator_services = []
            parent_id                        = dependency.organizational-units.outputs.ous["development"].id
            close_on_deletion                = include.env.locals.account_close_on_deletion 
        }
    }
    contacts = {
        primary_contact = include.env.locals.org_primary_contact
        billing_contact = include.env.locals.org_billing_contact
        security_contact = include.env.locals.org_security_contact
        operations_contact = include.env.locals.org_operations_contact
    }
    tags     = include.env.locals.tags
}

dependency "organizational-units" {
  config_path = "${get_original_terragrunt_dir()}/../organizational-units"

  mock_outputs = {
    ous = {
        "production" = {
            id = "000000"
        }
        "monitoring" = {
            id = "000000"
        }
        "development" = {
            id = "000000"
        }
    } 
  }
}

skip = include.env.locals.skip_module.accounts

