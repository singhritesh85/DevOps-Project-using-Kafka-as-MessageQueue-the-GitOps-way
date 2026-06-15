output "aws_ec2_eks_msk_iam_role_arn_details" {
  description = "Details for AWS EC2, EKS, VPC, MSK, IAM Role ARN"
  value       = module.aws_eks_msk 
  sensitive   = true
}
