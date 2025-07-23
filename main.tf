module "wrapper_glue_job" {
  source = "./wrapper_glue_job"

  for_each = local.glue_job_parameters

  metadata = var.metadata

  create                      = each.value.create
  name                        = each.value.name
  description                 = each.value.description
  role_custom_policy          = each.value.role_custom_policy
  connections                 = each.value.connections
  glue_version                = each.value.glue_version
  create_parameter_store      = each.value.create_parameter_store
  custom_parameter_store_name = each.value.custom_parameter_store_name
  default_arguments           = each.value.default_arguments
  non_overridable_arguments   = each.value.non_overridable_arguments
  security_configuration      = each.value.security_configuration
  timeout                     = each.value.timeout
  execution_class             = each.value.execution_class
  max_capacity                = each.value.max_capacity
  max_retries                 = each.value.max_retries
  worker_type                 = each.value.worker_type
  number_of_workers           = each.value.number_of_workers
  command                     = each.value.command
  execution_property          = each.value.execution_property
  notification_property       = each.value.notification_property
  kms_arn                     = each.value.kms_arn
  tags                        = each.value.tags
}

module "wrapper_glue_connector" {
  source = "./wrapper_glue_connector"

  for_each = local.glue_connector_parameters

  metadata = var.metadata

  create                           = each.value.create
  name                             = each.value.name
  description                      = each.value.description
  catalog_id                       = each.value.catalog_id
  connection_properties            = each.value.connection_properties
  connection_type                  = each.value.connection_type
  match_criteria                   = each.value.match_criteria
  physical_connection_requirements = each.value.physical_connection_requirements
  tags                             = each.value.tags
}

module "wrapper_glue_crawler" {
  source = "./wrapper_glue_crawler"

  for_each = local.glue_crawler_parameters

  metadata = var.metadata

  create                 = each.value.create
  name                   = each.value.name
  description            = each.value.description
  database_name          = each.value.database_name
  schedule               = each.value.schedule
  classifiers            = each.value.classifiers
  configuration          = each.value.configuration
  jdbc_target            = each.value.jdbc_target
  dynamodb_target        = each.value.dynamodb_target
  s3_target              = each.value.s3_target
  mongodb_target         = each.value.mongodb_target
  catalog_target         = each.value.catalog_target
  delta_target           = each.value.delta_target
  table_prefix           = each.value.table_prefix
  security_configuration = each.value.security_configuration
  schema_change_policy   = each.value.schema_change_policy
  lineage_configuration  = each.value.lineage_configuration
  recrawl_policy         = each.value.recrawl_policy
  tags                   = each.value.tags
}

module "wrapper_step_function" {
  source = "./wrapper_step_function"

  for_each = local.step_function_parameters

  metadata = var.metadata

  create                                 = each.value.create
  name                                   = each.value.name
  description                            = each.value.description
  type                                   = each.value.type
  definition                             = each.value.definition
  publish                                = each.value.publish
  logging_configuration                  = each.value.logging_configuration
  cloudwatch_log_group_retention_in_days = each.value.cloudwatch_log_group_retention_in_days
  encryption_configuration               = each.value.encryption_configuration
  enable_xray_tracing                    = each.value.enable_xray_tracing
  iam_role_permissions                   = each.value.iam_role_permissions
  scheduler                              = each.value.scheduler
  tags                                   = each.value.tags
}

# module "wrapper_glue_workflow" {
#   source = "./wrapper_glue_workflow"

#   for_each = local.glue_workflow_parameters

#   metadata = var.metadata

#   create                 = each.value.create
#   name                   = each.value.name
#   description            = each.value.description
#   default_run_properties = each.value.default_run_properties
#   max_concurrent_runs    = each.value.max_concurrent_runs
#   triggers               = each.value.triggers
#   tags                   = each.value.tags
# }