output "efs_private_ip_route53_hosted_zone_details_dns_name_of_jenkins_alb" {
  description = "EFS_Private_IP, Route53 Hosted Zone ID, Nameserver, ACM Certificate ARN and DNS Name of Jenkins ALB"
  value       = "${module.jenkins_self_healing}"
}
