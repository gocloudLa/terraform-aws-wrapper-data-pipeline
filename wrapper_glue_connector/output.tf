output "id" {
  description = "Catalog ID and name of the connection"
  value       = one(aws_glue_connection.this[*].id)
}

output "arn" {
  description = "The ARN of the Glue Connection."
  value       = one(aws_glue_connection.this[*].arn)
}

output "tags" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags"
  value       = one(aws_glue_connection.this[*].tags_all)
}
