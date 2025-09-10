locals {
  default_role_policy = {
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = ["${module.s3_etl_bucket.s3_bucket_arn}/*"]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = ["${module.s3_storage_bucket.s3_bucket_arn}", "${module.s3_etl_bucket.s3_bucket_arn}"]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${module.s3_storage_bucket.s3_bucket_arn}/*", "${module.s3_storage_bucket.s3_bucket_arn}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeParameters"
        ],
        "Resource" : "*"
      }
      # {
      #   "Effect" = "Allow"
      #   "Action" = [
      #     "ssm:DescribeParameters",
      #     "ssm:GetParameter",
      #     "ssm:GetParameters",
      #   ]
      #   ## Se deben agregar los custom parameter que se creen
      #   "Resource" = [
      #     "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:parameter/terraform/*",
      #     "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:parameter/terraform/example/ETL-01",
      #     "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:parameter/terraform/example/database-connections"]
      # }
    ],
  }
  default_non_overridable_arguments = {
    "--enable-auto-scaling"       = "true" ## Can help with costs, right-sizing workers.
    "--enable-metrics"            = "true"
    "--enable-job-insights"       = "true"
    "--additional-python-modules" = "dotenv==0.9.9, psycopg2==2.9.10, pymssql==2.3.2, pymysql==1.1.1, pyodbc==5.2.0, python-dotenv==1.0.1, selenium==4.29.0, sqlalchemy==2.0.37, sshtunnel==0.4.0"
    "--extra-py-files"            = "s3://${module.s3_etl_bucket.s3_bucket_id}/libraries/etl_lib-1.0.0-py3-none-any.whl"
  }

  custom_non_overridable_arguments = {
    "--enable-auto-scaling" = "true" ## Can help with costs, right-sizing workers.
    "--enable-metrics"      = "true"
    "--enable-job-insights" = "true"
    "--extra-py-files"      = "s3://${module.s3_etl_bucket.s3_bucket_id}/libraries/etl_lib-1.0.0-py3-none-any.whl, s3://${module.s3_etl_bucket.s3_bucket_id}/libraries/lib.zip"
  }
}