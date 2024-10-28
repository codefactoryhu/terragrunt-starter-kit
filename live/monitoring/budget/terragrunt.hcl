terraform {
  source = "tfr:///ganexcloud/budget/aws//.?version=2.0.0"
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
  name              = include.env.locals.budget_name
  budget_type       = include.env.locals.budget_type
  limit_amount      = include.env.locals.budget_limit_amount
  limit_unit        = include.env.locals.budget_limit_unit
  time_unit         = include.env.locals.budget_time_unit
  time_period_start = include.env.locals.budget_time_period_start
  cost_types        = include.env.locals.budget_cost_types
  cost_filters      = include.env.locals.cost_filters
  notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = include.env.locals.budget_subscriber_email_addresses
    }
  ]

}

skip = include.env.locals.skip_module.budget
