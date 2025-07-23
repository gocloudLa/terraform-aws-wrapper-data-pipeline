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

variable "connection_type" {
  description = "(Optional)The type of the connection. Supported are: JDBC, MONGODB, KAFKA, and NETWORK"
  type        = string
  default     = "JBDC"
}

variable "connection_properties" {
  description = "(Optional) A map of key-value pairs used as parameters for this connection."
  type        = map(any)
  default     = {}
}

variable "catalog_id" {
  description = "(Optional) The ID of the Data Catalog in which to create the connection. If none is supplied, the AWS account ID is used by default."
  type        = string
  default     = null
}

variable "match_criteria" {
  description = "(Optional) A list of criteria that can be used in selecting this connection."
  type        = list(any)
  default     = []
}

variable "physical_connection_requirements" {
  description = "(Optional) A map of physical connection requirements, such as VPC and SecurityGroup."
  type = object({
    subnet_id              = string
    security_group_id_list = list(string)
  })
  default = null
}