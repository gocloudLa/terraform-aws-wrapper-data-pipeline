output "wrapper_glue_job" {
  description = "Glue Job resources"
  value       = module.wrapper_glue_job
}

output "wrapper_step_function" {
  description = "Step Function resources"
  value       = module.wrapper_step_function
}

output "wrapper_glue_crawler" {
  description = "Glue Crawler resources"
  value       = module.wrapper_glue_crawler
}

# output "glue_workflow" {
#   description = "Glue Workflow resources"
#   value       = module.wrapper_glue_workflow
# }