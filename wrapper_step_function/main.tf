/*----------------------------------------------------------------------*/
/* Step functions                                                       */
/*----------------------------------------------------------------------*/
resource "aws_sfn_state_machine" "this" {
  count = var.create ? 1 : 0

  name = var.name
  tags = var.tags

  role_arn   = aws_iam_role.this[0].arn
  definition = var.definition
  publish    = var.publish
  type       = var.type


  dynamic "logging_configuration" {
    for_each = local.enable_logging ? [true] : []

    content {
      log_destination        = "${aws_cloudwatch_log_group.this[0].arn}:*"
      include_execution_data = lookup(var.logging_configuration, "include_execution_data", null)
      level                  = lookup(var.logging_configuration, "level", null)
    }
  }

  dynamic "tracing_configuration" {
    for_each = var.enable_xray_tracing ? [true] : []
    content {
      enabled = true
    }
  }

}

/*----------------------------------------------------------------------*/
/* IAM role                                                             */
/*----------------------------------------------------------------------*/

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name        = "${var.name}-role"
  description = var.description
  tags        = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "StepFunctionAssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "this" {
  count = var.create ? 1 : 0

  name        = "${var.name}-step-function-pol"
  path        = "/"
  description = "IAM custom policy for ${var.name} step function role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = data.aws_iam_policy_document.access[0].json
}

resource "aws_iam_role_policy_attachment" "step_function_policy" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

/*----------------------------------------------------------------------*/
/* Cloudwatch LogGroup                                                  */
/*----------------------------------------------------------------------*/
resource "aws_cloudwatch_log_group" "this" {
  count = local.enable_logging ? 1 : 0

  name              = "/aws/stepfunctions/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  tags              = var.tags
}

/*----------------------------------------------------------------------*/
/* SNS Topic Notification                                               */
/*----------------------------------------------------------------------*/
resource "aws_sns_topic" "failure_alerts" {
  name = "${var.name}-failure-alerts"
}

/*----------------------------------------------------------------------*/
/* AWS Eventbridge                                                      */
/*----------------------------------------------------------------------*/
module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.3"

  for_each = local.schedule_parameters

  create = each.value.create

  create_bus        = false
  attach_sfn_policy = true
  role_name         = "${var.name}-${each.key}"
  sfn_target_arns   = [aws_sfn_state_machine.this[0].arn]

  schedules = {
    "${each.key}" = {
      description         = "Trigger for a Step Function ${each.key}"
      schedule_expression = each.value.schedule_expression
      timezone            = each.value.timezone #"America/Buenos_Aires"
      arn                 = aws_sfn_state_machine.this[0].arn
      input               = each.value.input
    }
  }
}
