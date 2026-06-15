resource "aws_iam_role" "irsa_role" {
  name = "${var.prefix}-irsa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal     = {
          Federated   = aws_iam_openid_connect_provider.eksopidc.arn
        }
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Condition  = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eksopidc.url, "https://", "")}:sub" = ["system:serviceaccount:producer-consumer:msk-sa", "system:serviceaccount:keda:keda-operator", "system:serviceaccount:monitoring:kafka-exporter-prometheus-kafka-exporter"],
            "${replace(aws_iam_openid_connect_provider.eksopidc.url, "https://", "")}:aud" = ["sts.amazonaws.com"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "msk_access" {
  name = "msk-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:AlterCluster"
        ]
        Resource = aws_msk_cluster.msk_cluster.arn
      },
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:ReadData",
          "kafka-cluster:WriteData"
        ]
        Resource = "arn:aws:kafka:${data.aws_region.reg.region}:${data.aws_caller_identity.G_Duty.account_id}:topic/${aws_msk_cluster.msk_cluster.cluster_name}/${element(split("/", aws_msk_cluster.msk_cluster.arn), 2)}/*"
      },

      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = "arn:aws:kafka:${data.aws_region.reg.region}:${data.aws_caller_identity.G_Duty.account_id}:group/${aws_msk_cluster.msk_cluster.cluster_name}/${aws_msk_cluster.msk_cluster.cluster_uuid}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk_access_role_attachment" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.msk_access.arn
}
