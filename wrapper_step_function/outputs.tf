output "state_machine_id" {
  description = "The aws_sfn_state_machine ID"
  value       = one(aws_sfn_state_machine.this[*].id)
}

output "state_machine_arn" {
  description = "The aws_sfn_state_machine ARN"
  value       = one(aws_sfn_state_machine.this[*].arn)
}

output "aws_iam_role_arn" {
  description = "The aws_iam_role ARN"
  value       = one(aws_iam_role.this[*].arn)
}

output "aws_iam_role_id" {
  description = "The aws_iam_role ID"
  value       = one(aws_iam_role.this[*].id)
}

output "cloudwatch_log_group_arn" {
  description = "The aws_cloudwatch_log_group ARN"
  value       = one(aws_cloudwatch_log_group.this[*].arn)
}

output "cloudwatch_log_group_name" {
  description = "The aws_cloudwatch_log_group Name"
  value       = one(aws_cloudwatch_log_group.this[*].name)
}