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
  description = "(Required) Glue job name."
  type        = string
}

variable "description" {
  description = "(Optional) Glue job description."
  type        = string
  default     = null
}

variable "role_custom_policy" {
  description = "(Required) A map of IAM policies for the job service role to make calls to AWS services like S3, DynamoDB, etc."
  type        = any
}

variable "connections" {
  description = "(Optional) The list of connections used for this job."
  type        = list(string)
  default     = null
}

variable "glue_version" {
  description = "(Optional) The version of Glue to use."
  type        = string
  default     = "4.0"
}

variable "create_parameter_store" {
  description = "(Optional) Enables the creation of a custom parameter store that will be used for the ETL."
  type        = bool
  default     = false
}

variable "custom_parameter_store_name" {
  description = "(Optional) Custom name for the parameter createed."
  type        = string
  default     = null
}

variable "default_arguments" {
  description = "(Optional) The map of default arguments for the job. You can specify arguments here that your own job-execution script consumes, as well as arguments that AWS Glue itself consumes."
  type        = map(string)
  default     = null
}

variable "non_overridable_arguments" {
  description = "(Optional) Non-overridable arguments for this job, specified as name-value pairs."
  type        = map(string)
  default     = null
}

variable "security_configuration" {
  description = "(Optional) The name of the Security Configuration to be associated with the job."
  type        = string
  default     = null
}

variable "timeout" {
  description = "(Optional) The job timeout in minutes. The default is 2880 minutes (48 hours) for `glueetl` and `pythonshell` jobs, and `null` (unlimited) for `gluestreaming` jobs."
  type        = number
  default     = 180
}

variable "execution_class" {
  description = "(Optional) Indicates whether the job is run with a standard or flexible execution class. The standard execution class is ideal for time-sensitive workloads that require fast job startup and dedicated resources. Valid value: FLEX, STANDARD."
  type        = string
  default     = "STANDARD"
}

variable "max_capacity" {
  description = "(Optional) The maximum number of AWS Glue data processing units (DPUs) that can be allocated when the job runs. Required when `pythonshell` is set, accept either 0.0625 or 1.0. Use `number_of_workers` and `worker_type` arguments instead with `glue_version` 2.0 and above."
  type        = number
  default     = null
}

variable "max_retries" {
  description = "(Optional) The maximum number of times to retry the job if it fails."
  type        = number
  default     = null
}

variable "worker_type" {
  description = "(Optional) The type of predefined worker that is allocated when a job runs. Accepts a value of `Standard`, `G.1X`, or `G.2X`."
  type        = string
  default     = null
}

variable "number_of_workers" {
  description = "(Optional) The number of workers of a defined `worker_type` that are allocated when a job runs."
  type        = number
  default     = null
}

variable "command" {
  description = "(Required) The command of the job."
  #  type = object({
  #    # The name of the job command. Defaults to `glueetl`.
  #    # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
  #    name = string
  #    # Specifies the S3 path to a script that executes the job
  #    script_location = string
  #    # The Python version being used to execute a Python shell job. Allowed values are 2 or 3
  #    python_version = number
  #  })

  # Using `type = map(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type = map(any)
}

variable "execution_property" {
  description = "(Optional) Execution property of the job."
  type = object({
    # The maximum number of concurrent runs allowed for the job. The default is 1.
    max_concurrent_runs = number
  })
  default = null
}

variable "notification_property" {
  description = "(Optional) Notification property of the job."
  type = object({
    # After a job run starts, the number of minutes to wait before sending a job run delay notification
    notify_delay_after = number
  })
  default = null
}

variable "kms_arn" {
  description = "The arn of the KMS Key used to encrypt and decrypt objects stored in S3 buckets."
  type        = string
  default     = null
}