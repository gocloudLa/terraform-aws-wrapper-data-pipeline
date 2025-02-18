locals {

  enable_logging = try(var.logging_configuration["level"], "OFF") != "OFF" && var.create == true

  create_role_policy_lambda              = var.create && try(length(var.iam_role_permissions["lambda_integration_arns"]), 0) > 0 ? 1 : 0
  create_role_policy_glue_jobs           = var.create && try(length(var.iam_role_permissions["glue_jobs_integration_arns"]), 0) > 0 ? 1 : 0
  create_role_policy_step_functions      = var.create && try(length(var.iam_role_permissions["step_functions_integration_arns"]), 0) > 0 ? 1 : 0
  create_role_policy_event_bridge_events = var.create && try(length(var.iam_role_permissions["event_bridge_events_integration_arns"]), 0) > 0 ? 1 : 0
}

locals {
  metadata = var.metadata

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])
}