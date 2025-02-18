locals {
  glue_workflow_parameters_tmp = [
    for data_pipeline_key, data_pipeline_config in var.data_pipeline_parameters :
    [
      for glue_workflow_key, glue_workflow_config in try(data_pipeline_config.orchestration, {}) :
      {
        "${data_pipeline_key}-${glue_workflow_key}" = {
          create                 = try(glue_workflow_config.create, true)
          name                   = try(glue_workflow_config.name, "${local.common_name}-${data_pipeline_key}-${glue_workflow_key}")
          description            = try(glue_workflow_config.description, "${glue_workflow_key} glue workflow for ${data_pipeline_key} datapipeline")
          default_run_properties = try(glue_workflow_config.default_run_properties, {})
          max_concurrent_runs    = try(glue_workflow_config.max_concurrent_runs, 1)
          triggers               = try(glue_workflow_config.triggers, {})
          tags                   = merge(lookup(glue_workflow_config, "tags", local.common_tags), { Name = "${local.common_name}-${data_pipeline_key}-${glue_workflow_key}" })
        }
      } if((length(lookup(data_pipeline_config, "orchestration", {})) > 0) && (glue_workflow_config.service == "glue-workflow" ? true : false))
    ]
  ]
  glue_workflow_parameters = merge(flatten(local.glue_workflow_parameters_tmp)...)
}