output "id" {
  description = "Glue job ID"
  value       = one(aws_glue_job.this[*].id)
}

output "name" {
  description = "Glue job name"
  value       = one(aws_glue_job.this[*].name)
}

output "arn" {
  description = "Glue job ARN"
  value       = one(aws_glue_job.this[*].arn)
}
