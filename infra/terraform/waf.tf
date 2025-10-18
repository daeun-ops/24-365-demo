# AWS WAF v2 – 기본 OWASP 관리형 룰 + 레이트 리밋 (데모)
variable "waf_scope" { type = string  default = "REGIONAL" } # ALB용 REGIONAL
resource "aws_wafv2_web_acl" "exchange" {
  name  = "${var.name}-waf"
  scope = var.waf_scope
  default_action { allow {} }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf"
    sampled_requests_enabled   = true
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    statement { managed_rule_group_statement { name = "AWSManagedRulesCommonRuleSet" vendor_name = "AWS" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "common" sampled_requests_enabled = true }
    override_action { none {} }
  }
  rule {
    name     = "RateLimit"
    priority = 10
    statement { rate_based_statement { aggregate_key_type = "IP" limit = 2000 } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "ratelimit" sampled_requests_enabled = true }
    action { block {} }
  }
  tags = { Name = "${var.name}-waf" }
}
output "waf_acl_id" { value = aws_wafv2_web_acl.exchange.id }
