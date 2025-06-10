/*----------------------------------------------------------------------*/
/* Glue Job                                                             */
/*----------------------------------------------------------------------*/

# Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job
resource "aws_glue_connection" "this" {
  count = var.create ? 1 : 0

  name                  = var.name
  description           = var.description
  connection_type       = var.connection_type
  connection_properties = var.connection_properties
  catalog_id            = var.catalog_id
  match_criteria        = var.match_criteria

  dynamic "physical_connection_requirements" {
    for_each = var.physical_connection_requirements != null ? [var.physical_connection_requirements] : []
    content {
      availability_zone      = data.aws_subnet.this[0].availability_zone
      security_group_id_list = concat(try(var.physical_connection_requirements.security_group_id_list, []), [aws_security_group.this[0].id])
      subnet_id              = var.physical_connection_requirements.subnet_id
    }
  }

  tags = var.tags
}

resource "aws_security_group" "this" {
  count = var.create ? 1 : 0
  name        = "${var.name}-sg"
  description = "Allow all traffic from within the VPC, allow all outbound, for ${var.name} aws glue connection"
  vpc_id      = data.aws_subnet.this[0].vpc_id
}

# Allow all inbound traffic from within the VPC
resource "aws_security_group_rule" "ingress_from_vpc" {
  count = var.create ? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # all protocols
  cidr_blocks       = [data.aws_subnet.this[0].cidr_block]
  security_group_id = aws_security_group.this[0].id
}

# Allow all outbound traffic (egress to anywhere)
resource "aws_security_group_rule" "egress_all" {
  count = var.create ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this[0].id
}