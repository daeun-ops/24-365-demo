variable "region"           { type = string, default = "ap-northeast-2" }
variable "name"             { type = string, default = "exchange-prod" }
variable "eks_cluster_name" { type = string, default = "exchange-prod-eks" }
variable "vpc_id"           { type = string, default = "vpc-123456" }
variable "onprem_vpn_id"    { type = string, default = "vpn-1234abcd" }
