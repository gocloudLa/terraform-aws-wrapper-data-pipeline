# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform AWS Data Pipeline Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-data-pipeline/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-data-pipeline.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-data-pipeline.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/data-pipeline/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for AWS Data Pipeline simplifies the orchestration and deployment of data transformation and processing services in AWS. This wrapper functions as a standardized template that abstracts technical complexity and allows building reusable data pipelines that integrate AWS Glue Jobs, Glue Connectors, Parameter Store, Step Functions, and EventBridge.

### ✨ Features

- 🔧 **Glue Jobs Management** - Manages AWS Glue Jobs for serverless ETL processing

- 🔗 **Glue Connectors** - Integrates data sources and destinations through Glue Connectors

- 📊 **Parameter Store Integration** - Manages secure and reusable configurations

- 🔄 **Step Functions Orchestration** - Orchestrates complex workflow processes

- 📅 **EventBridge Scheduling** - Programs and triggers pipeline events

- 🔐 **Security Configuration** - Manages security policies and permissions

- ⚙️ **Custom Policies** - Supports custom IAM policies and configurations

- 🔌 **Connections Integration** - Manages connections to external data sources

- 📝 **Arguments Definition** - Configures job arguments and parameters

- ⏱️ **Timeouts and Retry Configuration** - Manages execution timeouts and retry policies



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-eventbridge" target="_blank">terraform-aws-modules/eventbridge/aws</a> | 4.1.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-step-functions" target="_blank">terraform-aws-modules/step-functions/aws</a> | 4.2.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-iam" target="_blank">terraform-aws-modules/iam/aws</a> | 5.44.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter" target="_blank">terraform-aws-modules/ssm-parameter/aws</a> | 1.1.2 |



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


## 🔧 Component Configuration

### Glue Jobs
Configure AWS Glue Jobs for ETL processing with custom arguments, connections, and execution parameters.

### Glue Connectors
Set up connections to external data sources and destinations for your data pipeline.

### Step Functions
Orchestrate complex workflows with AWS Step Functions, including scheduling and error handling.

### Parameter Store
Manage secure configuration parameters for your data pipeline components.

### EventBridge
Schedule and trigger pipeline events using EventBridge rules and targets.




## 📝 Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| data_pipeline_parameters | Data pipeline parameters to configure data pipeline module | `any` | `{}` | no |
| data_pipeline_defaults | Data pipeline defaults parameters to configure data pipeline module | `any` | `{}` | no |
| metadata | Common project information (naming, tags, etc.) | `any` | n/a | yes |








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