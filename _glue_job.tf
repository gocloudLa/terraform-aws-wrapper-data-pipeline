
# Create a new KMS key only if the alias does not exist
resource "aws_kms_key" "glue_kms" {
  count = length(var.data_pipeline_parameters) > 0 ? 1 : 0

  description             = "KMS key for AWS Glue job encryption"
  enable_key_rotation     = false
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        "Sid": "Allow access through Glue for all principals in the account that are authorized to use SSM",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "kms:ViaService": "glue.${var.metadata.aws_region}.amazonaws.com",
            "kms:CallerAccount": "${data.aws_caller_identity.current.id}"
          }
        }
      },
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

locals {
  glue_job_parameters_tmp = [
    for data_pipeline_key, data_pipeline_config in var.data_pipeline_parameters :
    [
      for glue_job_key, glue_job_config in try(data_pipeline_config.jobs, {}) :
      {
        "${data_pipeline_key}-${glue_job_key}" = {
          create                    = try(glue_job_config.create, true)
          name                      = try(glue_job_config.name, "${local.common_name}-${data_pipeline_key}-${glue_job_key}")
          description               = try(glue_job_config.description, "${glue_job_key} glue job for ${data_pipeline_key} pipeline.")
          role_custom_policy        = try(glue_job_config.role_custom_policy, {})
          connections               = try(glue_job_config.connections, [])
          glue_version              = try(glue_job_config.glue_version, "4.0")
          default_arguments         = try(glue_job_config.default_arguments, {})
          non_overridable_arguments = try(glue_job_config.non_overridable_arguments, null)
          security_configuration    = try(glue_job_config.security_configuration, null)
          timeout                   = try(glue_job_config.timeout, 180)
          execution_class           = try(glue_job_config.execution_class, "STANDARD")
          max_capacity              = try(glue_job_config.max_capacity, null)
          max_retries               = try(glue_job_config.max_retries, null)
          worker_type               = try(glue_job_config.worker_type, null)
          number_of_workers         = try(glue_job_config.number_of_workers, null)
          command                   = try(glue_job_config.command, {})
          execution_property        = try(glue_job_config.execution_property, null)
          notification_property     = try(glue_job_config.notification_property, null)
          kms_arn                   = aws_kms_key.glue_kms[0].arn
          tags                      = merge(lookup(glue_job_config, "tags", local.common_tags), { Name = "${local.common_name}-${data_pipeline_key}-${glue_job_key}" })
        }
      } if((length(lookup(data_pipeline_config, "jobs", {})) > 0))
    ]
  ]
  glue_job_parameters = merge(flatten(local.glue_job_parameters_tmp)...)
}