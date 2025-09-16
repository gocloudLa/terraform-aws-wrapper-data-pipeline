/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* VPC | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "data_pipeline_parameters" {
  type        = any
  description = "Data pipeline parameteres to configure data pipeline module"
  default     = {}
}

variable "data_pipeline_defaults" {
  type        = any
  description = "Data pipeline defaults parameteres to configure data pipeline module"
  default     = {}
}
