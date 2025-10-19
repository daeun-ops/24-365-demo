data "aws_vpc" "this" { id = module.vpc.vpc_id }

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
  tags = { Name = "${var.name}-vpce-s3" }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
  tags = { Name = "${var.name}-vpce-dynamodb" }
}

resource "aws_security_group" "vpce_sg" {
  name        = "${var.name}-vpce-sg"
  vpc_id      = module.vpc.vpc_id
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 443 to_port = 443 protocol = "tcp" cidr_blocks = [module.vpc.vpc_cidr_block] }
}

locals {
  interface_services = [
    "com.amazonaws.${var.region}.ecr.api",
    "com.amazonaws.${var.region}.ecr.dkr",
    "com.amazonaws.${var.region}.sts",
    "com.amazonaws.${var.region}.kms",
    "com.amazonaws.${var.region}.logs"
  ]
}

resource "aws_vpc_endpoint" "interfaces" {
  for_each            = toset(local.interface_services)
  vpc_id              = module.vpc.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true
  tags = { Name = "${var.name}-vpce-${replace(each.value, "com.amazonaws.${var.region}.", "")}" }
}
