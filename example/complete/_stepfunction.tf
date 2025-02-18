locals {
  step_functions_ventas_minoristas = {
    "Comment" : "An example of using Athena to execute queries in sequence and parallel, with error handling and notifications.",
    "StartAt" : "Generate Example Data",
    "QueryLanguage" : "JSONata",
    "States" : {
      "Generate Example Data" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::lambda:invoke",
        "Next" : "Load Data to Database",
        "Arguments" : {
          "FunctionName" : "MyLambdaFunction"
        },
        "Output" : "{% $states.result.Payload %}"
      },
      "Load Data to Database" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::athena:startQueryExecution.sync",
        "Catch" : [
          {
            "ErrorEquals" : [
              "States.ALL"
            ],
            "Next" : "Send query results"
          }
        ],
        "Next" : "Map",
        "Arguments" : {
          "QueryString" : "<ATHENA_QUERY_STRING>",
          "WorkGroup" : "<ATHENA_WORKGROUP>"
        }
      },
      "Map" : {
        "Type" : "Parallel",
        "Branches" : [
          {
            "StartAt" : "Start Athena query 1",
            "States" : {
              "Start Athena query 1" : {
                "Type" : "Task",
                "Resource" : "arn:aws:states:::athena:startQueryExecution.sync",
                "Next" : "Get Athena query 1 results",
                "Arguments" : {
                  "QueryString" : "<ATHENA_QUERY_STRING>",
                  "WorkGroup" : "<ATHENA_WORKGROUP>"
                }
              },
              "Get Athena query 1 results" : {
                "Type" : "Task",
                "Resource" : "arn:aws:states:::athena:getQueryResults",
                "End" : true,
                "Arguments" : {
                  "QueryExecutionId" : "{% $states.input.QueryExecution.QueryExecutionId %}"
                }
              }
            }
          },
          {
            "StartAt" : "Start Athena query 2",
            "States" : {
              "Start Athena query 2" : {
                "Type" : "Task",
                "Resource" : "arn:aws:states:::athena:startQueryExecution.sync",
                "Next" : "Get Athena query 2 results",
                "Arguments" : {
                  "QueryString" : "<ATHENA_QUERY_STRING>",
                  "WorkGroup" : "<ATHENA_WORKGROUP>"
                }
              },
              "Get Athena query 2 results" : {
                "Type" : "Task",
                "Resource" : "arn:aws:states:::athena:getQueryResults",
                "End" : true,
                "Arguments" : {
                  "QueryExecutionId" : "{% $states.input.QueryExecution.QueryExecutionId %}"
                }
              }
            }
          }
        ],
        "Catch" : [
          {
            "ErrorEquals" : [
              "States.ALL"
            ],
            "Next" : "Send query results"
          }
        ],
        "Next" : "Send query results",
        "Output" : {
          "Query1Result" : "{% $states.result[0].ResultSet.Rows %}",
          "Query2Result" : "{% $states.result[1].ResultSet.Rows %}"
        }
      },
      "Send query results" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::sns:publish",
        "End" : true,
        "Arguments" : {
          "Message" : "{% $states.input %}",
          "TopicArn" : "arn:aws:sns:us-east-1:<ACCOUNT_ID>:MySnsTopic"
        }
      }
    }
  }
}