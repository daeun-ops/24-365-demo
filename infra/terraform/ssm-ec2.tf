# 무SSH 운영 ssm Session Manager 사용
data "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-1234"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = data.aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
