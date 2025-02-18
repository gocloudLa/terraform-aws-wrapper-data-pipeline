/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Variables |                                                          */
/*----------------------------------------------------------------------*/

variable "create" {
  description = "(Optional) If it is true, the resources will be created."
  type        = bool
  default     = true
}

variable "tags" {
  description = "(Required) A mapping of tags to assign to resources."
  type        = map(string)
}

variable "name" {
  description = "(Required) Glue crawler name."
  type        = string
}

variable "description" {
  description = "(Optional) Glue crawler description."
  type        = string
  default     = null
}

variable "database_name" {
  description = "(Required) Glue catalog database."
  type        = string
}

variable "schedule" {
  description = "(Optional) A cron expression for the schedule."
  type        = string
  default     = null
}

variable "classifiers" {
  description = "(Optional) List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification."
  type        = list(string)
  default     = null
}

variable "configuration" {
  description = "(Optional) JSON string of configuration information."
  type        = string
  default     = null
}

variable "jdbc_target" {
  description = "(Optional) List of nested JBDC target arguments."
  #  type = list(object({
  #    connection_name = string
  #    path            = string
  #    exclusions      = list(string)
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type    = list(any)
  default = null
}

variable "dynamodb_target" {
  description = "(Optional) List of nested DynamoDB target arguments."
  #  type = list(object({
  #    path      = string
  #    scan_all  = bool
  #    scan_rate = number
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type    = list(any)
  default = null
}

variable "s3_target" {
  description = "(Optional) List of nested Amazon S3 target arguments."
  #  type = list(object({
  #    path                = string
  #    connection_name     = string
  #    exclusions          = list(string)
  #    sample_size         = number
  #    event_queue_arn     = string
  #    dlq_event_queue_arn = string
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type    = list(any)
  default = null
}

variable "mongodb_target" {
  description = "(Optional) List of nested MongoDB target arguments."
  #  type = list(object({
  #    connection_name = string
  #    path            = string
  #    scan_all        = bool
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type    = list(any)
  default = null
}

variable "catalog_target" {
  description = "(Optional) List of nested Glue catalog target arguments."
  type = list(object({
    database_name = string
    tables        = list(string)
  }))
  default = null
}

variable "delta_target" {
  description = "(Optional) List of nested Delta target arguments."
  type = list(object({
    connection_name = string
    delta_tables    = list(string)
    write_manifest  = bool
  }))
  default = null
}

variable "table_prefix" {
  description = "(Optional) The table prefix used for catalog tables that are created."
  type        = string
  default     = null
}

variable "security_configuration" {
  description = "(Optional) The name of Security Configuration to be used by the crawler."
  type        = string
  default     = null
}

variable "schema_change_policy" {
  description = "(Optional) Policy for the crawler's update and deletion behavior."
  #  type = object({
  #    delete_behavior = string
  #    update_behavior = string
  #  })

  # Using `type = map(string)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type    = map(string)
  default = null
}

variable "lineage_configuration" {
  description = "(Optional) Specifies data lineage configuration settings for the crawler."
  type = object({
    crawler_lineage_settings = string
  })
  default = null
}

variable "recrawl_policy" {
  description = "(Optional) A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run."
  type = object({
    recrawl_behavior = string
  })
  default = null
}

variable "inline_role_policy" {
  description = "(Optional) Inline policy for custom behaviour por Crawler role."
  #  type = object({
  #    name   = string
  #    policy = string
  #  })

  # Using `type = map(string)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type    = map(string)
  default = null
}