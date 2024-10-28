locals {
    global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))

    project                     = local.global_vars.locals.project
    region                      = local.global_vars.locals.region
    account_id                  = local.global_vars.locals.monitoring_account_id
    env                         = "monitoring"

    # Modules set true are ignored during Terraform run
    skip_module = {
      budget                          = false
      password_policy                 = false
    }

    # Access Analyzer 
    create_access_analyzer = false

    # Budget variables
    budget_name              = "Monthly Budget"
    budget_type              = "COST"
    budget_limit_amount      = "50"
    budget_limit_unit        = "USD"
    budget_time_unit         = "MONTHLY"
    budget_time_period_start ="2024-08-01_15:00"
    cost_filters = [
    {
      name      = "LinkedAccount"
      values    = ["${local.account_id}"]
    }
    ]
    budget_cost_types        = {
        include_credit                = false
        include_discount              = true
        include_other_subscription    = true
        include_recurring             = true
        include_refund                = false
        include_subscription          = true
        include_support               = true
        include_tax                   = true
        include_upfront               = true

    }
    budget_subscriber_email_addresses = ["monitoring@example.com"]

    # Tags
    tags = {
        Name            = "${local.env}-${local.project}"
        Environment     = "${local.env}"
        Project         = "${local.project}"
        ManagedBy       = "Terragrunt"
    }
}