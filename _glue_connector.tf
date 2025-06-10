locals {
  glue_connector_parameters_tmp = [
    for data_pipeline_key, data_pipeline_config in var.data_pipeline_parameters :
    [
      for glue_connector_key, glue_connector_config in try(data_pipeline_config.connectors, {}) :
      {
        "${data_pipeline_key}-${glue_connector_key}" = {
          create                           = try(glue_connector_config.create, true)
          name                             = try(glue_connector_config.name, "${local.common_name}-${data_pipeline_key}-${glue_connector_key}")
          description                      = try(glue_connector_config.description, "${glue_connector_key} glue job for ${data_pipeline_key} pipeline.")
          connection_type                  = try(glue_connector_config.connection_type, "JDBC")
          connection_properties            = try(glue_connector_config.connection_properties, null)
          catalog_id                       = try(glue_connector_config.catalog_id, null)
          match_criteria                   = try(glue_connector_config.match_criteria, [])
          physical_connection_requirements = try(glue_connector_config.physical_connection_requirements, null)
          tags                             = merge(lookup(glue_connector_config, "tags", local.common_tags), { Name = "${local.common_name}-${data_pipeline_key}-${glue_connector_key}" })
        }
      } if((length(lookup(data_pipeline_config, "jobs", {})) > 0))
    ]
  ]
  glue_connector_parameters = merge(flatten(local.glue_connector_parameters_tmp)...)
}