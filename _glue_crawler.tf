locals {
  glue_crawler_parameters_tmp = [
    for data_pipeline_key, data_pipeline_config in var.data_pipeline_parameters :
    [
      for glue_crawler_key, glue_crawler_config in try(data_pipeline_config.crawlers, {}) :
      {
        "${data_pipeline_key}-${glue_crawler_key}" = {
          create                 = try(glue_crawler_config.create, true)
          name                   = try(glue_crawler_config.name, "${local.common_name}-${data_pipeline_key}-${glue_crawler_key}")
          description            = try(glue_crawler_config.description, "${glue_crawler_key} glue Crawler for ${data_pipeline_key} pipeline.")
          database_name          = try(glue_crawler_config.database_name, null)
          role                   = try(glue_crawler_config.role, null)
          schedule               = try(glue_crawler_config.schedule, null)
          classifiers            = try(glue_crawler_config.classifiers, [])
          configuration          = try(glue_crawler_config.configuration, null)
          jdbc_target            = try(glue_crawler_config.jdbc_target, [])
          dynamodb_target        = try(glue_crawler_config.dynamodb_target, [])
          s3_target              = try(glue_crawler_config.s3_target, [])
          mongodb_target         = try(glue_crawler_config.mongodb_target, [])
          catalog_target         = try(glue_crawler_config.catalog_target, [])
          delta_target           = try(glue_crawler_config.delta_target, [])
          table_prefix           = try(glue_crawler_config.table_prefix, null)
          security_configuration = try(glue_crawler_config.security_configuration, null)
          schema_change_policy   = try(glue_crawler_config.schema_change_policy, {})
          lineage_configuration  = try(glue_crawler_config.lineage_configuration, null)
          recrawl_policy         = try(glue_crawler_config.recrawl_policy, null)
          tags                   = merge(lookup(glue_crawler_config, "tags", local.common_tags), { Name = "${local.common_name}-${data_pipeline_key}-${glue_crawler_key}" })
        }
      } if((length(lookup(data_pipeline_config, "crawlers", {})) > 0))
    ]
  ]
  glue_crawler_parameters = merge(flatten(local.glue_crawler_parameters_tmp)...)
}