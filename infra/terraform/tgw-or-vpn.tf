# Site-to-Site VPN (학습용ㅇ 스켈레톤) — 실제 운영은 Direct Connect + TGW 권장
variable "onprem_cgw_ip" { type = string  default = "203.0.113.10" } # 온프레 게이트웨이 공인 IP 예시
variable "onprem_bgp_asn" { type = number  default = 65010 }
variable "aws_bgp_asn"    { type = number  default = 64512 }

resource "aws_customer_gateway" "onprem" {
  bgp_asn    = var.onprem_bgp_asn
  ip_address = var.onprem_cgw_ip
  type       = "ipsec.1"
  tags = { Name = "${var.name}-cgw" }
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = module.vpc.vpc_id
  amazon_side_asn = var.aws_bgp_asn
  tags = { Name = "${var.name}-vgw" }
}

resource "aws_vpn_gateway_attachment" "att" {
  vpc_id         = module.vpc.vpc_id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

resource "aws_vpn_connection" "s2s" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.onprem.id
  type                = "ipsec.1"
  static_routes_only  = false
  tags = { Name = "${var.name}-vpn" }
}

resource "aws_vpn_connection_route" "to_onprem_10_50" {
  vpn_connection_id = aws_vpn_connection.s2s.id
  destination_cidr_block = "10.50.0.0/16" # 온프레 CIDR
}
