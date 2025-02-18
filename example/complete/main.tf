### Primero desplegar buckets y loggroup
resource "aws_cloudwatch_log_group" "example" {
  name              = "pipelie-Example"
  retention_in_days = 7

  tags = local.common_tags
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket        = "${local.common_name}-bronze"
  force_destroy = true
}

module "s3_bucket_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket        = "${local.common_name}-glue-logs"
  force_destroy = true
}

module "s3_bucket_temp" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket        = "${local.common_name}-glue-temporary"
  force_destroy = true
}
##################################

module "wrapper_data_pipeline" {
  source = "../../"

  metadata = local.metadata

  data_pipeline_parameters = {
    "ventas_minoristas" = {
      jobs = {
        # rdv-prd-core-ventas_minoristas-bronze
        "bronze" = {
          create = true
          default_arguments = {
            # ... potentially other arguments ...
            "--continuous-log-logGroup"          = aws_cloudwatch_log_group.example.name
            "--enable-continuous-cloudwatch-log" = "true"
            "--enable-continuous-log-filter"     = "true"
            "--enable-metrics"                   = ""
          }
          # var.default_arguments #required
          role_custom_policy = {
            Version = "2012-10-17",
            Statement = [
              {
                Effect = "Allow",
                Action = [
                  "appflow:DescribeFlows",
                  "appflow:DescribeFlow",
                  "appflow:DescribeFlowExecution",
                  "appflow:DescribeFlowExecutionRecords",
                  "appflow:StartFlow"
                ],
                Resource = "*"
              },
              {
                Effect = "Allow",
                Action = [
                  "s3:PutObject",
                  "s3:PutObjectAcl",
                ],
                Resource = "${module.s3_bucket.s3_bucket_arn}/*"
              },
              {
                Effect = "Allow",
                Action = [
                  "s3:ListBucket"
                ],
                Resource = "${module.s3_bucket.s3_bucket_arn}"
              },
              # {
              #   Effect = "Allow",
              #   Action = [
              #     "s3:GetObject"
              #   ],
              #   Resource = [
              #     "${var.metadata.glue.scripts.bucket_arn}/${local.job_custody_records_master_extractor_directory}/${local.job_custody_records_master_extractor_name}/*",
              #     "${var.metadata.glue.libraries.bucket_arn}/*"
              #   ]
              # },
              {
                Effect = "Allow",
                Action = [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:DeleteObject"
                ],
                Resource = [
                  "${module.s3_bucket_logs.s3_bucket_arn}/*",
                  "${module.s3_bucket_temp.s3_bucket_arn}/*"
                ]
              }

            ],
          }
          command = {
            # The name of the job command. Defaults to `glueetl`.
            # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
            name            = "pythonshell"
            script_location = "s3://${module.s3_bucket_temp.s3_bucket_id}/job.py"
            #format("s3://%s/%s/%s/%s.py", var.metadata.glue.scripts.bucket_id, local.job_custody_records_master_extractor_directory, local.job_custody_records_master_extractor_name, local.job_custody_records_master_extractor_filename)
            python_version = "3.9"
          }
        }
        # rdv-prd-core-ventas_minoristas-silver
        "silver" = {
          # name                      = "rdv-prd-core-ventas_minoristas-silver" (default)
          # description               = "Glue job {name}" (default)
          # timeout                   = 180 (default)
          # glue_version              = "4.0" (default)
          # connections               = [] (connection to VPC resources if needed)
          # non_overridable_arguments = null
          # security_configuration    = null
          # execution_class           = "STANDARD"/"FLEX" ("STANDARD" es el default)
          # notification_property = null

          default_arguments = {
            # ... potentially other arguments ...
            "--continuous-log-logGroup"          = aws_cloudwatch_log_group.example.name
            "--enable-continuous-cloudwatch-log" = "true"
            "--enable-continuous-log-filter"     = "true"
            "--enable-metrics"                   = ""
          }
          #number_of_workers = 6 ## Also acts as Max allowed workers when auto-scaling is enabled.
          #max_retries               = 1
          ## max_capacity              = 1
          #worker_type               = "Standard"

          role_custom_policy = {
            Version = "2012-10-17",
            Statement = [
              {
                Effect = "Allow",
                Action = [
                  "appflow:DescribeFlows",
                  "appflow:DescribeFlow",
                  "appflow:DescribeFlowExecution",
                  "appflow:DescribeFlowExecutionRecords",
                  "appflow:StartFlow"
                ],
                Resource = "*"
              },
              {
                Effect = "Allow",
                Action = [
                  "s3:PutObject",
                  "s3:PutObjectAcl",
                ],
                Resource = "${module.s3_bucket.s3_bucket_arn}/*"
              },
              {
                Effect = "Allow",
                Action = [
                  "s3:ListBucket"
                ],
                Resource = "${module.s3_bucket.s3_bucket_arn}"
              },
              {
                Effect = "Allow",
                Action = [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:DeleteObject"
                ],
                Resource = [
                  "${module.s3_bucket_temp.s3_bucket_arn}/*",
                  "${module.s3_bucket_logs.s3_bucket_arn}/*"
                ]
              }

            ],
          }

          command = {
            # The name of the job command. Defaults to `glueetl`.
            # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
            name            = "pythonshell"
            script_location = "s3://${module.s3_bucket_temp.s3_bucket_id}/silver-job.py"
            python_version  = "3.9"
          }

          execution_property = {
            max_concurrent_runs = 10
          }
        }
        # # rdv-prd-core-ventas_minoristas-gold-reporte_diario
        # # rdv-prd-core-ventas_minoristas-gold-reporte_mensual
        # # rdv-prd-core-ventas_minoristas-gold-reporte_anual
        # "gold-reporte_diario" = {}
        # "gold-reporte_mensual" = {}
        # "gold-reporte_anual" = {}
      }
      crawlers = {
        # "bronze" = {
        #   create = true
        #   description   = "Crawler for data science topics_calls models"
        #   database_name = "bronze_s3_datascience_topics_calls" ## this must exist
        #   ## Ref: cron(Minutes Hours Day-of-month Month Day-of-week Year) UTC
        #   #schedule = "cron(0 9 * * ? *)" ## UTC (3am MX)

        #   s3_target = [
        #     {
        #       path = "s3://${module.s3_bucket_temp.s3_bucket_id}/crawler.py"
        #       #format("s3://%s/%s/models/topics_calls/datasets/", var.metadata.lake.bronze.id, "t03-data-science")
        #       sample_size = 100
        #     }
        #   ]

        #   schema_change_policy = {
        #     delete_behavior = "DEPRECATE_IN_DATABASE"
        #     update_behavior = "UPDATE_IN_DATABASE"
        #   }

        #   #recrawl_policy = {
        #   #  recrawl_behavior = "CRAWL_EVERYTHING"
        #   #}

        #   configuration = jsonencode(
        #     {
        #       Grouping = {
        #         TableGroupingPolicy = "CombineCompatibleSchemas",
        #         TableLevelConfiguration = 6
        #       }
        #       CrawlerOutput = {
        #         Partitions = {
        #           AddOrUpdateBehavior = "InheritFromTable"
        #         }
        #       }
        #       Version = 1
        #     }
        #   )
        # },
        # "bronze-01" = {

        #   description   = "Crawler for sync aurora spectrum bundle"
        #   database_name = "bronze_s3_aurora_bundle" ## this must exist
        #   ## Ref: cron(Minutes Hours Day-of-month Month Day-of-week Year) UTC
        #   # schedule = "cron(0 9 * * ? *)" ## UTC (3am MX)

        #   s3_target = [
        #     {
        #       path = "s3://${module.s3_bucket_temp.s3_bucket_id}/crawler.py"
        #       #format("s3://%s/%s/%s/%s/", join("-", ["t02", "usw2", "lake-bronze", var.metadata.labels.env]), "s07-ecosystem", "spectrum", "bundle")
        #       sample_size = 100

        #       connection_options = {
        #         "classification" = "iceberg"
        #       }
        #     }
        #   ]

        #   schema_change_policy = {
        #     delete_behavior = "DEPRECATE_IN_DATABASE"
        #     update_behavior = "UPDATE_IN_DATABASE"
        #   }

        #   #recrawl_policy = {
        #   #  recrawl_behavior = "CRAWL_EVERYTHING"
        #   #}

        #   configuration = jsonencode(
        #     {
        #       Grouping = {
        #         TableGroupingPolicy = "CombineCompatibleSchemas",
        #         TableLevelConfiguration = 5
        #       }
        #       CrawlerOutput = {
        #         Partitions = {
        #           AddOrUpdateBehavior = "InheritFromTable"
        #         }
        #       }
        #       Version = 1
        #     }
        #   )
        # }
        #"silver" = {}
      }
      orchestration = {
        # rdv-prd-core-ventas_minoristas
        "" = {
          service    = "step-function"
          definition = local.step_functions_ventas_minoristas
          scheduler  = { cron = "" }

          #############################################
          # name = random_pet.this.id se crea solo
          # type = "express"/"standard" defaul "standard"
          # publish    = true

          logging_configuration = {
            include_execution_data = true
            level                  = "ALL"
          }

          service_integrations = {

            batch_Sync = {
              events = true
            }

            # dynamodb = {
            #   dynamodb = ["arn:aws:dynamodb:eu-west-1:052212379155:table/Test"]
            # }

            # athena_StartQueryExecution_Sync = {
            #   athena        = ["arn:aws:athena:eu-west-1:123456789012:something1:test1"]
            #   glue          = ["arn:aws:glue:eu-west-1:123456789012:something2:test1"]
            #   s3            = true # options: true (use default value from `aws_service_policies`) or provide a list of ARNs
            #   lakeformation = ["arn:aws:lakeformation:eu-west-1:123456789012:something3:test1"]
            # }

            # lambda = {
            #   lambda = [
            #   module.lambda_function.lambda_function_arn, "arn:aws:lambda:eu-west-1:123456789012:function:test2"]
            # }

            xray = {
              xray = true
            }

            # stepfunction_Sync = {
            #   stepfunction          = ["arn:aws:states:eu-west-1:123456789012:stateMachine:test1"]
            #   stepfunction_Wildcard = ["arn:aws:states:eu-west-1:123456789012:stateMachine:test1"]

            #   # Set to true to use the default events (otherwise, set this to a list of ARNs; see the docs linked in locals.tf
            #   # for more information). Without events permissions, you will get an error similar to this:
            #   #   Error: AccessDeniedException: 'arn:aws:iam::xxxx:role/step-functions-role' is not authorized to
            #   #   create managed-rule
            #   events = true
            # }

            #    # NB: This will "Deny" everything (including logging)!
            #    no_tasks = {
            #      deny_all = true
            #    }
          }

        }
      }
      #   # rdv-prd-core-ventas_minoristas-mensual
      #   "mensual" = {
      #     type = "stepfunction"
      #     definition = ""
      #     scheduler = { cron = "", event = "JSON"}

      #   ###################################################
      #     # name = random_pet.this.id se crea solo
      #     # type = "express"/"standard"
      #     # publish    = true

      #     encryption_configuration = {
      #       type                              = "CUSTOMER_MANAGED_KMS_KEY"
      #       kms_key_id                        = module.kms.key_arn
      #       kms_data_key_reuse_period_seconds = 600
      #     }

      #     logging_configuration = {
      #       include_execution_data = true
      #       level                  = "ALL"
      #     }

      #     service_integrations = {

      #       batch_Sync = {
      #         events = true
      #       }

      #       dynamodb = {
      #         dynamodb = ["arn:aws:dynamodb:eu-west-1:052212379155:table/Test"]
      #       }

      #       athena_StartQueryExecution_Sync = {
      #         athena        = ["arn:aws:athena:eu-west-1:123456789012:something1:test1"]
      #         glue          = ["arn:aws:glue:eu-west-1:123456789012:something2:test1"]
      #         s3            = true # options: true (use default value from `aws_service_policies`) or provide a list of ARNs
      #         lakeformation = ["arn:aws:lakeformation:eu-west-1:123456789012:something3:test1"]
      #       }

      #       lambda = {
      #         lambda = [
      #         module.lambda_function.lambda_function_arn, "arn:aws:lambda:eu-west-1:123456789012:function:test2"]
      #       }

      #       xray = {
      #         xray = true
      #       }

      #       stepfunction_Sync = {
      #         stepfunction          = ["arn:aws:states:eu-west-1:123456789012:stateMachine:test1"]
      #         stepfunction_Wildcard = ["arn:aws:states:eu-west-1:123456789012:stateMachine:test1"]

      #         # Set to true to use the default events (otherwise, set this to a list of ARNs; see the docs linked in locals.tf
      #         # for more information). Without events permissions, you will get an error similar to this:
      #         #   Error: AccessDeniedException: 'arn:aws:iam::xxxx:role/step-functions-role' is not authorized to
      #         #   create managed-rule
      #         events = true
      #       }

      #       #    # NB: This will "Deny" everything (including logging)!
      #       #    no_tasks = {
      #       #      deny_all = true
      #       #    }
      #     }

      #     ######################
      #     # Additional policies
      #     # Probably you are not going to need them (use `service_integrations` instead)!
      #     ######################

      #     attach_policy_json = true
      #     policy_json        = <<EOF
      #       {
      #           "Version": "2012-10-17",
      #           "Statement": [
      #               {
      #                   "Effect": "Allow",
      #                   "Action": [
      #                       "xray:GetSamplingStatisticSummaries"
      #                   ],
      #                   "Resource": ["*"]
      #               }
      #           ]
      #       }
      #       EOF

      #     attach_policy_jsons = true
      #     policy_jsons = [<<EOF
      #       {
      #           "Version": "2012-10-17",
      #           "Statement": [
      #               {
      #                   "Effect": "Allow",
      #                   "Action": [
      #                       "xray:*"
      #                   ],
      #                   "Resource": ["*"]
      #               }
      #           ]
      #       }
      #       EOF
      #     ]
      #     number_of_policy_jsons = 1

      #     attach_policy = true
      #     policy        = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"

      #     attach_policies    = true
      #     policies           = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]
      #     number_of_policies = 1

      #     attach_policy_statements = true
      #     policy_statements = {
      #       dynamodb = {
      #         effect    = "Allow",
      #         actions   = ["dynamodb:BatchWriteItem"],
      #         resources = ["arn:aws:dynamodb:eu-west-1:052212379155:table/Test"]
      #       },
      #       s3_read = {
      #         effect    = "Deny",
      #         actions   = ["s3:HeadObject", "s3:GetObject"],
      #         resources = ["arn:aws:s3:::my-bucket/*"]
      #       }
      #       kms = {
      #         effect    = "Allow"
      #         actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
      #         resources = [module.kms.key_arn]
      #         condition = [{
      #           test     = "StringEquals"
      #           variable = "kms:EncryptionContext:aws:states:stateMachineArn"
      #           values   = ["arn:aws:states:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:stateMachine:${random_pet.this.id}"]
      #         }]
      #       }
      #     }
      #   }
      # }
    }
    # "user_interactions" = {
    #   jobs = {
    #     "allinone" = {
    #       kind = "glue"
    #     }
    #   }
    #   orchestration = {
    #     kind = "glue-workflows"
    #     ##################################
    #     # name
    #     # description
    #     # default_run_properties = var.default_run_properties # igualar a variables de stepfunctions
    #     # max_concurrent_runs    = var.max_concurrent_runs    # igualar a variables de stepfunctions
    #     triggers = { ## se deberia cambiar por "definition" asi no tenemos que controlar 2 nombres distintos, igualmente la logica cambiaria debido al KIND
    #       "01" = {
    #         enabled = true
    #         type    = "SCHEDULED"
    #         ## Ref: cron(Minutes Hours Day-of-month Month Day-of-week Year) UTC
    #         schedule = "cron(0 00 * * ? *)" #every day at 00:00am

    #         actions = [
    #           {
    #             job_name = local.naming.job_custody_records_master_extractor
    #             ## Arguments passed for this job execution. You can specify custom arguments that your job script consumes and official ones.
    #             ## If the arguments names are already present on the Glue job configuration, this ones will override and take precedence.
    #             arguments = {}
    #           },
    #         ]
    #       },
    #       "02" = {
    #         enabled = true
    #         type    = "CONDITIONAL"
    #         predicate = {
    #           logical    = "AND"
    #           conditions = [
    #             {
    #               job_name         = local.naming.job_custody_records_master_extractor
    #               logical_operator = "EQUALS"
    #               state            = "SUCCEEDED"
    #             },
    #           ]
    #         }
    #         actions = [
    #           {
    #             job_name = local.naming.job_custody_records_master_executor
    #             arguments = {}
    #           }
    #         ]
    #       },
    #     }
    #   }
    # }
  }
}