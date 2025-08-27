locals {
  step_functions_workflow_01_definition = <<EOF
{
  "Comment": "Example Glue Job Execution with SNS failure notification",
  "StartAt": "gcl-l01-test-datapipeline-example-etl-01",
  "States": {
    "gcl-l01-test-datapipeline-example-etl-01": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "gcl-l01-test-datapipeline-example-etl-01"
      },
      "Retry": [
        {
          "ErrorEquals": ["States.ALL"],
          "IntervalSeconds": 30,
          "MaxAttempts": 2,
          "BackoffRate": 1.5
        }
      ],
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "NotifyFailure"
        }
      ],
      "Next": "gcl-l01-test-datapipeline-example-etl-02"
    },
    "gcl-l01-test-datapipeline-example-etl-02": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "gcl-l01-test-datapipeline-example-etl-02"
      },
      "Retry": [
        {
          "ErrorEquals": ["States.ALL"],
          "IntervalSeconds": 30,
          "MaxAttempts": 2,
          "BackoffRate": 1.5
        }
      ],
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "NotifyFailure"
        }
      ],
      "End": true
    },
    "NotifyFailure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.id}:workflow-01-failure-alerts",
        "Message.$": "States.Format('Glue job step \"{}\" failed. Error details: {}', $$.State.Name, $.error.Cause)",
        "Subject": "Glue Job Execution Failed"
      },
      "End": true
    }
  }
}
EOF
}