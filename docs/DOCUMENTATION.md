# DOCUMENTATION

## Introducción

El Wrapper de Terraform para AWS Data Pipeline simplifica la orquestación y despliegue de servicios de transformación y procesamiento de datos en AWS.
Este wrapper funciona como una plantilla estandarizada que abstrae la complejidad técnica y permite construir pipelines de datos reutilizables que integran:
* AWS Glue Jobs para ejecutar procesos ETL serverless.
* Glue Connectors para integrar orígenes y destinos de datos.
* Parameter Store para gestión de configuraciones seguras y reutilizables.
* Step Functions para la orquestación de flujos de trabajo complejos.
* EventBridge para la programación y disparo de eventos que inician o coordinan procesos.

De esta forma, los equipos pueden enfocarse en la lógica de negocio y transformación de datos, mientras que los aspectos de seguridad, permisos y orquestación son gestionados automáticamente por el módulo.

Features:
* Administración de Glue Jobs
* Glue Connectors
* Parámetros en Parameter Store
* Orquestación con Step Functions
* Eventos con EventBridge
* Configuración de Seguridad
* Custom Policies
* Integración con Connections
* Definición de Arguments
* Timeouts y Máximos Intentos

Diagrama <br/>

A continuación se puede ver una imagen conceptual de los recursos que se despliegan con el wrapper:
<center>![alt text](diagrams/aws_data_pipeline.png)</center>

## Modo de Uso
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

          role_custom_policy = local.default_role_policy #Block of policies

          non_overridable_arguments = local.default_non_overridable_arguments #Block of arguments

          default_arguments = {
            "--landing-zone"    = "${module.s3_storage_bucket.s3_bucket_id}"
            # "--parameter-store" = "/terraform/example/databae-connections"
            "--job-directory"   = "s3://${module.s3_etl_bucket.s3_bucket_id}/ETL/ETL-01"
          }

          command = {
            # The name of the job command. Defaults to `glueetl`.
            # Use `pythonshell` for Python Shell Job Type, or `gluestreaming` for Streaming Job Type.
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
```

Tabla de Variables
<details> <summary>Ver tabla completa Glue Job</summary>
| Variable | Descripción de variable | Tipo | Default | Requerido | 
| metadata | Información común del proyecto (naming, tags, etc.) | any | n/a | ✅ | 
| create | - | `bool` | `true` | ❌ | 
| tags | - | `map{string}` | n/a | ✅ | 
| name | - | `string` | n/a | ✅ | 
| description | - | `string` | `null` | ❌ | 
| role_custom_policy | - | any | n/a | ✅ | 
| connections | - | `list(string)`] | `null` | ❌ | 
| glue_version | - | `string` | `4.0` | ❌ | 
| create_parameter_store | - | `bool` | false | ❌ | 
| custom_parameter_store_name | - | `string` | `null` | ❌ | 
| default_arguments | - | `map(string)` | `null` | ❌ | 
| non_overridable_arguments | - | `map(string)` | `null` | ❌ | 
| security_configuration | - | `string` | `null` | ❌ | 
| timeout | - | `number` | `180` | ❌ | 
| execution_class | - | `string` | `STANDARD` | ❌ | 
| max_capacity | - | `number` | `null` | ❌ | 
| max_retries | - | `string` | `null` | ❌ | 
| worker_type | - | `string` | `null` | ❌ | 
| number_of_workers | - | `number` | `null` | ❌ | 
| command | - | `map(any)` | n/a | - | ✅ | 
| execution_property | - | `object` | `null` | ❌ | 
| notification_property | - | `object` | `null`  | ❌ | 
| kms_arn | - | `string` | `null` | ❌ | 
</details>
<details> <summary>Ver tabla completa Glue Connector</summary>
| Variable | Descripción de variable | Tipo | Default | Requerido | 
| metadata | Información común del proyecto (naming, tags, etc.) | any | n/a | ✅ | 
| create | - | `bool` | `true` | ❌ | 
| tags | - | `map{string}` | n/a | ✅ | 
| name | - | `string` | n/a | ✅ | 
| description | - | `string` | `null` | ❌ | 
| connection_type | - | `string` | `JBDC` | ❌ |
| connection_properties | - | map(any) | `null` | ❌ |
| catalog_id | - | `string` | `null` | ❌ |
| match_criteria | - | `list(any)` | `[]` | ❌ |
| physical_connection_requirements | - | `object` | `null` | ❌ | 
</details>
<details> <summary>Ver tabla completa Step Functions</summary>
| Variable | Descripción de variable | Tipo | Default | Requerido | 
| metadata | Información común del proyecto (naming, tags, etc.) | any | n/a | ✅ | 
| create | - | `bool` | `true` | ❌ | 
| tags | - | `map{string}` | n/a | ✅ | 
| name | - | `string` | n/a | ✅ | 
| description | - | `string` | `null` | ❌ | 
| definition | - | `any` | n/a | ✅ | 
| encryption_configuration | - | `map(any)` | n/a | ❌ |
| logging_configuration | - | `map(string)` | `{ level = "ON" }` | ❌ |
| publish | - | `bool` | `false` | ❌ |
| enable_xray_tracing | - | `bool` | `false` | ❌ |
| type | - | `string` | `STANDARD` | ❌ |
| cloudwatch_log_group_retention_in_days | - | `number` | `30` | ❌ |
| iam_role_permissions | - | `map(any)` | `{}` | ✅ |
| scheduler | - | `map(any)` | `{}` | ❌ |
</details>
