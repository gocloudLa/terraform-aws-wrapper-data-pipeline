/*----------------------------------------------------------------------*/
/* Step functions                                                       */
/*----------------------------------------------------------------------*/

resource "aws_sfn_state_machine" "this" {
  count = var.create ? 1 : 0

  name = var.name
  tags = var.tags

  role_arn   = aws_iam_role.this[0].arn
  definition = jsonencode(var.definition)
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

  inline_policy {
    name   = var.name
    policy = one(data.aws_iam_policy_document.access[*].json)
  }

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