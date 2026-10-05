output "app_url" {
  description = "URL the app is reachable at."
  value       = local.use_custom_domain ? "https://${local.fqdn}" : "https://${aws_cloudfront_distribution.app.domain_name}"
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution default domain name (*.cloudfront.net)."
  value       = aws_cloudfront_distribution.app.domain_name
}

output "ecr_repository_name" {
  description = "ECR repository name -> GitHub secret ECR_REPOSITORY."
  value       = aws_ecr_repository.app.name
}

output "aws_region" {
  description = "AWS region the stack is deployed in -> GitHub secret AWS_REGION."
  value       = var.aws_region
}

output "ecs_cluster_name" {
  description = "ECS cluster name -> GitHub secret ECS_CLUSTER."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name -> GitHub secret ECS_SERVICE."
  value       = aws_ecs_service.app.name
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions to assume via OIDC -> GitHub secret AWS_ROLE_ARN. Null if github_org was left empty."
  value       = local.create_github_deploy_role ? aws_iam_role.github_actions_deploy[0].arn : null
}
