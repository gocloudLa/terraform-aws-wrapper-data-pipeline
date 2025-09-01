### Primero desplegar buckets
module "s3_storage_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket        = "${local.common_name}-landing-zone"
  force_destroy = true
}

module "s3_etl_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket        = "${local.common_name}-etl-code"
  force_destroy = true
}
##################################

module "wrapper_data_pipeline" {
  source = "../../"

  metadata = local.metadata

  data_pipeline_parameters = {
    "datapipeline-example" = {
      connectors = {
        "connector" = {
          connection_type = "NETWORK"
          physical_connection_requirements = {
            subnet_id              = data.aws_subnets.private-prd.ids[0]
            security_group_id_list = []
          }
        }
      }
      jobs = {
        "etl-01" = {
          description  = "Glue Job that runs Python script"
          max_retries  = 0
          max_capacity = 1
          timeout      = 120
          glue_version = "5.0"

          connections = ["${local.common_name}-datapipeline-example-connector"]

          role_custom_policy = local.default_role_policy

          non_overridable_arguments = local.default_non_overridable_arguments

          default_arguments = {
            "--landing-zone" = "${module.s3_storage_bucket.s3_bucket_id}"
            # "--parameter-store" = "/terraform/example/databae-connections"
            "--job-directory" = "s3://${module.s3_etl_bucket.s3_bucket_id}/etl/etl-01"
          }

          command = {
            # The name of the job command. Defaults to `glueetl`.
            # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
            name            = "pythonshell"
            script_location = "s3://${module.s3_etl_bucket.s3_bucket_id}/etl/etl-01/main.py"
            python_version  = "3.9"
          }
        },
        "etl-02" = {
          description  = "Glue Job that runs Python script"
          max_retries  = 0
          max_capacity = 1
          timeout      = 120
          glue_version = "5.0"

          connections = ["${local.common_name}-datapipeline-example-connector"]

          role_custom_policy = local.default_role_policy

          non_overridable_arguments = local.default_non_overridable_arguments

          create_parameter_store      = true
          custom_parameter_store_name = "/terraform/example/etl-02-parameter"

          default_arguments = {
            "--landing-zone" = "${module.s3_storage_bucket.s3_bucket_id}"
            # "--parameter-store" = "/terraform/example/databae-connections"
            "--job-directory" = "s3://${module.s3_etl_bucket.s3_bucket_id}/etl/etl-02"
          }

          command = {
            # The name of the job command. Defaults to `glueetl`.
            # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
            name            = "pythonshell"
            script_location = "s3://${module.s3_etl_bucket.s3_bucket_id}/etl/etl-02/main.py"
            python_version  = "3.9"
          }
        }
      }
      orchestration = {
        "workflow-01" = {
          service    = "step-function"
          definition = local.step_functions_workflow_01_definition
          scheduler = {
            "schedule" = {
              cron     = "cron(0 12 * * ? *)"
              timezone = "America/Argentina/Buenos_Aires"
              input    = "{\"Arguments\": {\"--scriptLocation\": \"s3://my-bucket/path/to/new_script.py\"}}"
            }
          }

          logging_configuration = {
            include_execution_data = true
            level                  = "ALL"
          }
          iam_role_permissions = {
            create_glue_jobs_integration = true
          }
        }
      }
    }
  }
}