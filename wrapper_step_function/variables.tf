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

variable "description" {
  description = "(Optional) resources description."
  type        = string
  default     = null
}

variable "name" {
  description = "(Required) Name of the resources to be created."
  type        = string
}

variable "role_custom_policy" {
  description = "(Optional) A map of IAM policies for the step function service role to make calls to AWS services like S3, DynamoDB, etc."
  type        = any
  default     = {}
}

variable "type" {
  description = "(Optional) Determines whether a Standard or Express state machine is created. The default is STANDARD. You cannot update the type of a state machine once it has been created. Valid values: STANDARD, EXPRESS."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "Supported are: STANDARD, EXPRESS"
  }
}

variable "definition" {
  description = "(Required) The Amazon States Language definition of the Step Function"
  type        = any
}

variable "publish" {
  description = "(Optional) Determines whether to set a version of the state machine when it is created."
  type        = bool
  default     = false
}

variable "logging_configuration" {
  description = "(Optional) Defines what execution history events are logged and where they are logged"
  type        = map(string)
  default = {
    level = "OFF"
  }
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0], var.cloudwatch_log_group_retention_in_days)
    error_message = "Supported are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0"
  }
  default = 30
}

variable "enable_xray_tracing" {
  description = "(Optional) Selects whether AWS X-Ray tracing is enabled."
  type        = bool
  default     = false
}

variable "iam_role_permissions" {
  description = "(Optional) A map of parameters to manage the iam role permissions for the execution actions."
  type        = any
  default     = {}
}