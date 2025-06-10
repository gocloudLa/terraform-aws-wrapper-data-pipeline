data "aws_subnet" "this" {
  count = var.create ? 1 : 0
  id = var.physical_connection_requirements.subnet_id
}