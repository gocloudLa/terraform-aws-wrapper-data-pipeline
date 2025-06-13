data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  count = var.create ? 1 : 0

  filter {
    name   = "tag:Name"
    values = ["${local.common_name}*"]
  }
}

data "aws_subnets" "this" {
  count = var.create ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [one(data.aws_vpc.this[*].id)]
  }

  tags = {
    "subnet-group" = "data"
  }
}

data "aws_iam_policy_document" "access" {
  count = var.create ? 1 : 0

  # https://docs.aws.amazon.com/step-functions/latest/dg/cw-logs.html
  dynamic "statement" {
    for_each = local.enable_logging == true ? [1] : []
    content {
      sid = "LogGroup"
      actions = [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ]
      resources = ["*"]
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/xray-iam.html
  dynamic "statement" {
    for_each = var.enable_xray_tracing == true ? [1] : []
    content {
      sid = "XRay"
      actions = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets"
      ]
      resources = ["*"]
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/lambda-iam.html
  dynamic "statement" {
    for_each = local.create_role_policy_lambda > 0 ? [1] : []

    content {
      sid = "LambdaAccess"
      actions = [
        "lambda:InvokeFunction"
      ]
      resources = ["*"]
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/glue-iam.html
  dynamic "statement" {
    for_each = local.create_role_policy_glue_jobs > 0 ? [1] : []

    content {
      sid = "GlueJobAccess"
      actions = [
        "glue:StartJobRun",
        "glue:GetJobRun",
        "glue:GetJobRuns",
        "glue:BatchStopJobRun"
      ]
      resources = ["*"]
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/stepfunctions-iam.html
  dynamic "statement" {
    for_each = local.create_role_policy_step_functions > 0 ? [1] : []

    content {
      sid = "StepFunctionsAccess1"
      actions = [
        "states:StartSyncExecution",
        "states:StartExecution",
        "states:DescribeExecution",
        "states:StopExecution"
      ]
      resources = ["*"]
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/stepfunctions-iam.html
  dynamic "statement" {
    for_each = local.create_role_policy_step_functions > 0 ? [1] : []

    content {
      sid = "StepFunctionsAccess2"
      actions = [
        "events:PutTargets",
        "events:PutRule",
        "events:DescribeRule"
      ]
      resources = ["*"]
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/eventbridge-iam.html
  dynamic "statement" {
    for_each = local.create_role_policy_event_bridge_events > 0 ? [1] : []
    content {
      sid = "EventBridgeEventsAccess"
      actions = [
        "events:PutEvents"
      ]
      resources = ["*"]
    }
  }

  # override_policy_documents = [jsonencode(var.role_custom_policy)]
}