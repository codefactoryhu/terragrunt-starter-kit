locals {
    global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

    project                     = local.global_vars.locals.project
    region                      = local.global_vars.locals.region
    organization_id             = local.global_vars.locals.organization_id
    organization_root_id        = local.global_vars.locals.organization_root_id
    account_id                  = local.global_vars.locals.management_account_id
    monitoring_account_id       = local.global_vars.locals.monitoring_account_id
    monitoring_account_email    = local.global_vars.locals.monitoring_account_email
    production_account_id       = local.global_vars.locals.production_account_id
    production_account_email    = local.global_vars.locals.production_account_email
    development_account_id      = local.global_vars.locals.development_account_id
    development_account_email   = local.global_vars.locals.development_account_email

    env                         = "management"

    # Modules set true are ignored during Terraform run
    skip_module = {
        accounts                        = false
        organization_units              = false
    }

    # Account variables
    account_close_on_deletion = true
    org_primary_contact                   = {
        address_line_1  = "110 Maplewood Avenue, Apartment 5B"
        city            = "Springfield"
        country_code    = "USA"
        full_name       = "Emily Harper"
        phone_number    = "+12345678910"
        postal_code     = "1234"
        state_or_region = "California"
    }
    org_billing_contact                   = {
        name          = "Liam Chen"
        title         = "Billing"
        email_address = "liam.chen@example.com"
        phone_number  = "+12345678910"
    }
    org_operations_contact                = {
        name          = "Sophie Martínez"
        title         = "Operations"
        email_address = "sophie.martínez@example.com"
        phone_number  = "+12345678910"
    }
    org_security_contact                  = {
        name          = "Arjun Patel"
        title         = "Security"
        email_address = "arjun.patel@example.com"
        phone_number  = "+12345678910"
    }

    # Tags
    tags = {
        Name            = "${local.env}-${local.project}"
        Environment     = "${local.env}"
        Project         = "${local.project}"
        ManagedBy       = "Terragrunt"
    }
}