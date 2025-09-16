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


variable "description" {
  description = "(Optional) resources description."
  type        = string
  default     = null
}

variable "name" {
  description = "(Required) Name of the resources to be created."
  type        = string
}

variable "definition" {
  description = "(Required) The Amazon States Language definition of the state machine."
  type        = any
}
variable "encryption_configuration" {
  description = "(Optional) Defines what encryption configuration is used to encrypt data in the State Machine. For more information see [TBD] in the AWS Step Functions User Guide."
  type        = map(any)
}
variable "logging_configuration" {
  description = "(Optional) Defines what execution history events are logged and where they are logged. The logging_configuration parameter is valid when type is set to STANDARD or EXPRESS. Defaults to OFF. For more information see Logging Express Workflows, Log Levels and Logging Configuration in the AWS Step Functions User Guide."
  type        = map(string)
  default = {
    level = "ON"
  }
}

variable "publish" {
  description = "(Optional) Set to true to publish a version of the state machine during creation. Default: false."
  type        = bool
  default     = false
}

variable "enable_xray_tracing" {
  description = "(Optional) Selects whether AWS X-Ray tracing is enabled."
  type        = bool
  default     = false
}
variable "type" {
  description = "(Optional) Determines whether a Standard or Express state machine is created. The default is STANDARD. You cannot update the type of a state machine once it has been created. Valid values: STANDARD, EXPRESS."
  type        = string
  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "Supported are: STANDARD, EXPRESS"
  }
  default = "STANDARD"
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
variable "iam_role_permissions" {
  description = "(Required) A List of the resources managed from the state machine."
  type        = map(any)
  default     = {}
}

variable "scheduler" {
  description = "(Optional) Map of Eventbridge schedulers that will trigger Step Functions ."
  type        = map(any)
  default     = {}
}


variable "tags" {
  description = "(Required) A mapping of tags to assign to resources."
  type        = map(string)
}
