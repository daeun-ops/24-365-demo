resource "aws_security_group" "resolver" {
  name   = "${var.name}-resolver-sg"
  vpc_id = module.vpc.vpc_id
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 53 to_port = 53 protocol = "udp" cidr_blocks = [module.vpc.vpc_cidr_block] }
  ingress { from_port = 53 to_port = 53 protocol = "tcp" cidr_blocks = [module.vpc.vpc_cidr_block] }
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name               = "${var.name}-inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.resolver.id]
  ip_address { subnet_id = module.vpc.private_subnets[0] }
  ip_address { subnet_id = module.vpc.private_subnets[1] }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name               = "${var.name}-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.resolver.id]
  ip_address { subnet_id = module.vpc.private_subnets[0] }
  ip_address { subnet_id = module.vpc.private_subnets[1] }
}

resource "aws_route53_resolver_rule" "onprem_forward" {
  domain_name          = "onprem.local."
  name                 = "${var.name}-onprem-fwd"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id
  target_ip { ip = "10.50.0.53" }
}

resource "aws_route53_resolver_rule_association" "onprem_assoc" {
  resolver_rule_id = aws_route53_resolver_rule.onprem_forward.id
  vpc_id           = module.vpc.vpc_id
}
