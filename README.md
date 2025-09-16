# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform AWS Data Pipeline Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-data-pipeline/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-data-pipeline.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-data-pipeline.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/data-pipeline/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for AWS Data Pipeline simplifies the orchestration and deployment of data transformation and processing services in AWS. This wrapper functions as a standardized template that abstracts technical complexity and allows building reusable data pipelines that integrate AWS Glue Jobs, Glue Connectors, Parameter Store, Step Functions, and EventBridge.

### ✨ Features

- 🔧 [Glue Jobs Management](#glue-jobs-management) - Manages AWS Glue Jobs for serverless ETL processing

- 🔗 [Glue Connectors](#glue-connectors) - Integrates data sources and destinations through Glue Connectors

- 📊 [Parameter Store Integration](#parameter-store-integration) - Manages secure and reusable configurations

- 🔄 [Step Functions Orchestration](#step-functions-orchestration) - Orchestrates complex workflow processes

- 📅 [EventBridge Scheduling](#eventbridge-scheduling) - Programs and triggers pipeline events

- 🔐 [Security Configuration](#security-configuration) - Manages security policies and permissions

- ⚙️ [Custom Policies](#custom-policies) - Supports custom IAM policies and configurations

- 🔌 [Connections Integration](#connections-integration) - Manages connections to external data sources

- 📝 [Arguments Definition](#arguments-definition) - Configures job arguments and parameters

- ⏱️ [Timeouts and Retry Configuration](#timeouts-and-retry-configuration) - Manages execution timeouts and retry policies



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-eventbridge" target="_blank">terraform-aws-modules/eventbridge/aws</a> | 3.14.3 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-s3-bucket" target="_blank">terraform-aws-modules/s3-bucket/aws</a> | 4.1.2 |



## 🚀 Quick Start
```hcl
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
            "--landing-zone"    = "${module.s3_storage_bucket.s3_bucket_id}"
            "--job-directory"   = "s3://${module.s3_etl_bucket.s3_bucket_id}/ETL/ETL-01"
          }

          command = {
            name            = "pythonshell"
            script_location = "s3://${module.s3_etl_bucket.s3_bucket_id}/ETL/ETL-01/main.py"
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
```


## 🔧 Additional Features Usage

### Glue Jobs Management
Deploy and manage AWS Glue Jobs that execute serverless ETL processes. Configure job parameters, connections, arguments, timeouts, and retry policies.



### Glue Connectors
Configure Glue Connectors to integrate various data sources and destinations with your data pipeline.



### Parameter Store Integration
Store and manage pipeline configurations securely using AWS Parameter Store for reusable and centralized configuration management.



### Step Functions Orchestration
Use AWS Step Functions to orchestrate complex data pipeline workflows with scheduling, error handling, and state management.



### EventBridge Scheduling
Configure EventBridge for scheduling and triggering events that initiate or coordinate data pipeline processes.



### Security Configuration
Automatically handles security aspects including IAM roles, policies, and permissions for all pipeline components.



### Custom Policies
Define and apply custom IAM policies and configurations tailored to specific pipeline requirements.



### Connections Integration
Configure and manage connections to external data sources and services within your data pipeline.



### Arguments Definition
Define default and non-overridable arguments for Glue jobs to ensure consistent execution parameters.



### Timeouts and Retry Configuration
Configure execution timeouts and maximum retry attempts to ensure reliable pipeline execution.





## 📑 Inputs
| Name                     | Description                                                         | Type   | Default   | Required   |
| ------------------------ | ------------------------------------------------------------------- | ------ | --------- | ---------- |
| Name                     | Description                                                         | Type   | Default   | Required   |
| ------                   | -------------                                                       | ------ | --------- | :--------: |
| data_pipeline_parameters | Data pipeline parameters to configure data pipeline module          | `any`  | `{}`      | no         |
| data_pipeline_defaults   | Data pipeline defaults parameters to configure data pipeline module | `any`  | `{}`      | no         |
| metadata                 | Common project information (naming, tags, etc.)                     | `any`  | n/a       | yes        |





## 📚 Examples
{'glue_job': '```hcl\ndata_pipeline_parameters = {\n  "my-pipeline" = {\n    jobs = {\n      "etl-job" = {\n        description               = "ETL job for data processing"\n        glue_version             = "5.0"\n        max_retries              = 2\n        max_capacity             = 2\n        timeout                  = 180\n        execution_class          = "STANDARD"\n        worker_type              = "G.1X"\n        number_of_workers        = 2\n        create_parameter_store   = true\n        custom_parameter_store_name = "/my-pipeline/etl-job/config"\n        \n        connections = ["my-database-connection"]\n        \n        role_custom_policy = {\n          Version = "2012-10-17"\n          Statement = [\n            {\n              Effect = "Allow"\n              Action = ["s3:GetObject", "s3:PutObject"]\n              Resource = ["arn:aws:s3:::my-bucket/*"]\n            }\n          ]\n        }\n        \n        default_arguments = {\n          "--source-bucket" = "my-source-bucket"\n          "--target-bucket" = "my-target-bucket"\n        }\n        \n        non_overridable_arguments = {\n          "--enable-metrics" = "true"\n          "--enable-auto-scaling" = "true"\n        }\n        \n        command = {\n          name            = "glueetl"\n          script_location = "s3://my-scripts-bucket/etl-script.py"\n          python_version  = "3"\n        }\n        \n        execution_property = {\n          max_concurrent_runs = 1\n        }\n        \n        notification_property = {\n          notify_delay_after = 60\n        }\n      }\n    }\n  }\n}\n```\n## Glue Job Variables\n| Name | Description | Type | Default | Required |\n|------|-------------|------|---------|:--------:|\n| create | If it is true, the resources will be created | `bool` | `true` | no |\n| name | Glue job name | `string` | n/a | yes |\n| description | Glue job description | `string` | `null` | no |\n| role_custom_policy | A map of IAM policies for the job service role | `any` | n/a | yes |\n| connections | The list of connections used for this job | `list(string)` | `null` | no |\n| glue_version | The version of Glue to use | `string` | `"4.0"` | no |\n| create_parameter_store | Enables the creation of a custom parameter store | `bool` | `false` | no |\n| custom_parameter_store_name | Custom name for the parameter created | `string` | `null` | no |\n| default_arguments | The map of default arguments for the job | `map(string)` | `null` | no |\n| non_overridable_arguments | Non-overridable arguments for this job | `map(string)` | `null` | no |\n| security_configuration | The name of the Security Configuration | `string` | `null` | no |\n| timeout | The job timeout in minutes | `number` | `180` | no |\n| execution_class | Execution class (FLEX, STANDARD) | `string` | `"STANDARD"` | no |\n| max_capacity | Maximum number of DPUs | `number` | `null` | no |\n| max_retries | Maximum number of times to retry the job | `number` | `null` | no |\n| worker_type | Type of predefined worker (Standard, G.1X, G.2X) | `string` | `null` | no |\n| number_of_workers | Number of workers of a defined worker_type | `number` | `null` | no |\n| command | The command of the job | `map(any)` | n/a | yes |\n| execution_property | Execution property of the job | `object` | `null` | no |\n| notification_property | Notification property of the job | `object` | `null` | no |\n| tags | A mapping of tags to assign to resources | `map(string)` | n/a | yes |\n', 'glue_connector': '```hcl\ndata_pipeline_parameters = {\n  "my-pipeline" = {\n    connectors = {\n      "database-connector" = {\n        description     = "Connection to PostgreSQL database"\n        connection_type = "JDBC"\n        \n        connection_properties = {\n          JDBC_CONNECTION_URL = "jdbc:postgresql://db.example.com:5432/mydb"\n          USERNAME           = "dbuser"\n          PASSWORD           = "dbpassword"\n        }\n        \n        physical_connection_requirements = {\n          subnet_id              = "subnet-12345678"\n          security_group_id_list = ["sg-12345678"]\n        }\n        \n        match_criteria = ["connection-criteria"]\n      },\n      "network-connector" = {\n        description     = "Network connection for VPC resources"\n        connection_type = "NETWORK"\n        \n        physical_connection_requirements = {\n          subnet_id              = "subnet-87654321"\n          security_group_id_list = ["sg-87654321"]\n        }\n      }\n    }\n  }\n}\n```\n## Glue Connector Variables\n| Name | Description | Type | Default | Required |\n|------|-------------|------|---------|:--------:|\n| create | If it is true, the resources will be created | `bool` | `true` | no |\n| name | Glue connector name | `string` | n/a | yes |\n| description | Glue connector description | `string` | `null` | no |\n| connection_type | The type of the connection (JDBC, MONGODB, KAFKA, NETWORK) | `string` | `"JBDC"` | no |\n| connection_properties | A map of key-value pairs used as parameters | `map(any)` | `{}` | no |\n| catalog_id | The ID of the Data Catalog | `string` | `null` | no |\n| match_criteria | A list of criteria for selecting this connection | `list(any)` | `[]` | no |\n| physical_connection_requirements | Physical connection requirements (VPC, SecurityGroup) | `object` | `null` | no |\n| tags | A mapping of tags to assign to resources | `map(string)` | n/a | yes |\n', 'glue_crawler': '```hcl\ndata_pipeline_parameters = {\n  "my-pipeline" = {\n    crawlers = {\n      "s3-crawler" = {\n        description   = "Crawler for S3 data lake"\n        database_name = "my_data_catalog"\n        schedule      = "cron(0 12 * * ? *)"\n        table_prefix  = "raw_"\n        \n        s3_target = [\n          {\n            path        = "s3://my-data-lake/raw-data/"\n            exclusions  = ["*.tmp", "*.log"]\n            sample_size = 100\n          }\n        ]\n        \n        schema_change_policy = {\n          delete_behavior = "LOG"\n          update_behavior = "UPDATE_IN_DATABASE"\n        }\n        \n        lineage_configuration = {\n          crawler_lineage_settings = "ENABLE"\n        }\n        \n        recrawl_policy = {\n          recrawl_behavior = "CRAWL_EVERYTHING"\n        }\n      },\n      "jdbc-crawler" = {\n        description   = "Crawler for JDBC database"\n        database_name = "my_jdbc_catalog"\n        \n        jdbc_target = [\n          {\n            connection_name = "my-database-connection"\n            path           = "mydb/public/%"\n            exclusions     = ["temp_%"]\n          }\n        ]\n      }\n    }\n  }\n}\n```\n## Glue Crawler Variables\n| Name | Description | Type | Default | Required |\n|------|-------------|------|---------|:--------:|\n| create | If it is true, the resources will be created | `bool` | `true` | no |\n| name | Glue crawler name | `string` | n/a | yes |\n| description | Glue crawler description | `string` | `null` | no |\n| database_name | Glue catalog database | `string` | n/a | yes |\n| schedule | A cron expression for the schedule | `string` | `null` | no |\n| classifiers | List of custom classifiers | `list(string)` | `null` | no |\n| configuration | JSON string of configuration information | `string` | `null` | no |\n| jdbc_target | List of nested JDBC target arguments | `list(any)` | `null` | no |\n| dynamodb_target | List of nested DynamoDB target arguments | `list(any)` | `null` | no |\n| s3_target | List of nested Amazon S3 target arguments | `list(any)` | `null` | no |\n| mongodb_target | List of nested MongoDB target arguments | `list(any)` | `null` | no |\n| catalog_target | List of nested Glue catalog target arguments | `list(object)` | `null` | no |\n| delta_target | List of nested Delta target arguments | `list(object)` | `null` | no |\n| table_prefix | The table prefix used for catalog tables | `string` | `null` | no |\n| security_configuration | The name of Security Configuration | `string` | `null` | no |\n| schema_change_policy | Policy for the crawler\'s update and deletion behavior | `map(string)` | `null` | no |\n| lineage_configuration | Data lineage configuration settings | `object` | `null` | no |\n| recrawl_policy | Policy for crawling behavior | `object` | `null` | no |\n| tags | A mapping of tags to assign to resources | `map(string)` | n/a | yes |\n', 'step_function': '```hcl\ndata_pipeline_parameters = {\n  "my-pipeline" = {\n    orchestration = {\n      "workflow" = {\n        service     = "step-function"\n        description = "Data pipeline orchestration workflow"\n        type        = "STANDARD"\n        \n        definition = jsonencode({\n          Comment = "Data Pipeline Workflow"\n          StartAt = "StartJob"\n          States = {\n            StartJob = {\n              Type     = "Task"\n              Resource = "arn:aws:states:::glue:startJobRun.sync"\n              Parameters = {\n                JobName = "my-etl-job"\n              }\n              End = true\n            }\n          }\n        })\n        \n        logging_configuration = {\n          include_execution_data = true\n          level                 = "ALL"\n        }\n        \n        cloudwatch_log_group_retention_in_days = 30\n        enable_xray_tracing                   = true\n        \n        iam_role_permissions = {\n          create_glue_jobs_integration = true\n          create_sns_integration      = true\n        }\n        \n        scheduler = {\n          "daily-schedule" = {\n            cron     = "cron(0 9 * * ? *)"\n            timezone = "America/New_York"\n            input    = jsonencode({\n              Arguments = {\n                "--env" = "production"\n              }\n            })\n          }\n        }\n        \n        encryption_configuration = {\n          kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"\n          type       = "CUSTOMER_MANAGED_KMS_KEY"\n        }\n      }\n    }\n  }\n}\n```\n## Step Function Variables\n| Name | Description | Type | Default | Required |\n|------|-------------|------|---------|:--------:|\n| create | If it is true, the resources will be created | `bool` | `true` | no |\n| name | Name of the resources to be created | `string` | n/a | yes |\n| description | Resources description | `string` | `null` | no |\n| definition | The Amazon States Language definition | `any` | n/a | yes |\n| type | State machine type (STANDARD, EXPRESS) | `string` | `"STANDARD"` | no |\n| publish | Set to true to publish a version | `bool` | `false` | no |\n| logging_configuration | Execution history events logging configuration | `map(string)` | `{level = "ON"}` | no |\n| cloudwatch_log_group_retention_in_days | Log retention in days | `number` | `30` | no |\n| encryption_configuration | Encryption configuration | `map(any)` | n/a | yes |\n| enable_xray_tracing | Enable AWS X-Ray tracing | `bool` | `false` | no |\n| iam_role_permissions | List of resources managed from the state machine | `map(any)` | `{}` | no |\n| scheduler | Map of EventBridge schedulers | `map(any)` | `{}` | no |\n| tags | A mapping of tags to assign to resources | `map(string)` | n/a | yes |\n'}



## ⚠️ Important Notes
- **🚨 Job Configuration:** Changes to Glue job configurations may require redeployment. Test thoroughly in development environments.
- **⚠️ IAM Permissions:** Ensure proper IAM permissions are configured for cross-service integrations.
- **ℹ️ Resource Limits:** Monitor Glue job capacity and Step Function execution limits to avoid throttling.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 