# GuardDuty + Security Hub + CloudTrail(관리 이벤트) — 요약 스켈레톤
resource "aws_guardduty_detector" "this" { enable = true }

resource "aws_securityhub_account" "this" { enable_default_standards = true }

resource "aws_cloudwatch_log_group" "trail_lg" {
  name              = "/aws/cloudtrail/${var.name}"
  retention_in_days = 180
}

resource "aws_s3_bucket" "trail" {
  bucket = "${var.name}-cloudtrail-1234"
  force_destroy = true
}

resource "aws_cloudtrail" "org" {
  name                          = "${var.name}-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail_lg.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.trail_to_cw.arn
}

resource "aws_iam_role" "trail_to_cw" {
  name = "${var.name}-trail-to-cw"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="cloudtrail.amazonaws.com" }, Action="sts:AssumeRole"}]
  })
}

resource "aws_iam_role_policy" "trail_to_cw" {
  name = "${var.name}-trail-to-cw"
  role = aws_iam_role.trail_to_cw.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow",
      Action=["logs:PutLogEvents","logs:CreateLogStream"],
      Resource="${aws_cloudwatch_log_group.trail_lg.arn}:*"
    }]
  })
}
