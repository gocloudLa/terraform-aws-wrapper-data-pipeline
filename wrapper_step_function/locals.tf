locals {

  schedule_parameters_tmp = [
    for schedule_key, schedule_config in var.scheduler :
    {
      "${schedule_key}" = {
        create              = try(schedule_config.create, true)
        name                = try(schedule_config.name, schedule_key)
        description         = try(schedule_config.description, "${schedule_key} rule to trigger Step Function datapipeline")
        timezone            = try(schedule_config.timezone, "America/BuenosAires")
        schedule_expression = try(schedule_config.cron, null)
        input               = try(schedule_config.input, "")
      }
    }
    if length(try(schedule_config, {})) > 0
  ]
  schedule_parameters = merge(flatten(local.schedule_parameters_tmp)...)

  enable_logging = try(var.logging_configuration["level"], "OFF") != "OFF" && var.create == true

  create_role_policy_lambda              = var.create && try(var.iam_role_permissions.create_lambda_integration, false) != false ? 1 : 0
  create_role_policy_glue_jobs           = var.create && try(var.iam_role_permissions.create_glue_jobs_integration, false) != false ? 1 : 0
  create_role_policy_step_functions      = var.create && try(var.iam_role_permissions.create_step_functions_integration, false) != false ? 1 : 0
  create_role_policy_event_bridge_events = var.create && try(var.iam_role_permissions.create_event_bridge_events_integration, false) != false ? 1 : 0
}

locals {
  metadata = var.metadata

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])
}