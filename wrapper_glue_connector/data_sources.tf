data "aws_subnet" "this" {
  count = var.create ? 1 : 0
  id    = var.physical_connection_requirements.subnet_id
}

data "aws_vpc" "this" {
  count = var.create ? 1 : 0
  id    = data.aws_subnet.this[0].vpc_id
}