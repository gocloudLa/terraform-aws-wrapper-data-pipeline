locals {
  step_function_parameters_tmp = [
    for data_pipeline_key, data_pipeline_config in var.data_pipeline_parameters :
    [
      for step_function_key, step_function_config in try(data_pipeline_config.orchestration, {}) :
      {
        "${step_function_key}" = {
          create                                 = try(step_function_config.create, true)
          name                                   = try(step_function_config.name, "${data_pipeline_key}-${step_function_key}")
          description                            = try(step_function_config.description, "${step_function_key} Step Funtion for ${data_pipeline_key} datapipeline")
          role_custom_policy                     = try(step_function_config.role_custom_policy, {})
          type                                   = try(step_function_config.type, "STANDARD")
          definition                             = try(step_function_config.definition, {})
          publish                                = try(step_function_config.publish, false)
          logging_configuration                  = try(step_function_config.logging_configuration, "OFF")
          cloudwatch_log_group_retention_in_days = try(step_function_config.cloudwatch_log_group_retention_in_days, 30)
          enable_xray_tracing                    = try(step_function_config.enable_xray_tracing, false)
          iam_role_permissions                   = try(step_function_config.iam_role_permissions, {})
          encryption_configuration               = try(step_function_config.encryption_configuration, {})
          scheduler                              = try(step_function_config.scheduler, {})
          tags                                   = merge(lookup(step_function_config, "tags", local.common_tags), { Name = "${local.common_name}-${data_pipeline_key}-${step_function_key}" })
        }
      } if((length(lookup(data_pipeline_config, "orchestration", {})) > 0) && (step_function_config.service == "step-function" ? true : false))
    ]
  ]
  step_function_parameters = merge(flatten(local.step_function_parameters_tmp)...)
}