variable "project_name" {
  description = "Short name used to prefix/tag all resources."
  type        = string
  default     = "petclinic"
}

variable "environment" {
  description = "Deployment environment name (e.g. prod, staging, dev)."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region to deploy the app stack into (VPC, ALB, ECS, RDS). CloudFront/ACM-for-CloudFront always use us-east-1 regardless of this value."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (ALB, NAT gateway). One per AZ."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (ECS tasks, RDS). One per AZ."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ---------------------------------------------------------------------------
# Domain / DNS / TLS (all optional)
# ---------------------------------------------------------------------------

variable "domain_name" {
  description = "Existing Route53 public hosted zone name (e.g. \"yourdomain.com\"). Leave empty (\"\") to skip Route53/ACM entirely and expose the app via the CloudFront default domain instead."
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain label for the app. Combined with domain_name to form <subdomain>.<domain_name>. Ignored when domain_name is empty."
  type        = string
  default     = "petclinic"
}

# ---------------------------------------------------------------------------
# ECS / container
# ---------------------------------------------------------------------------

variable "ecr_repository_name" {
  description = "Name of the ECR repository to create for the app image."
  type        = string
  default     = "petclinic"
}

variable "container_image_tag" {
  description = "Image tag to deploy. Typically overridden per-deploy by CI (e.g. the git SHA)."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the app listens on inside the container."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path the ALB target group uses for health checks."
  type        = string
  default     = "/actuator/health"
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 2
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 14
}

# ---------------------------------------------------------------------------
# CloudFront
# ---------------------------------------------------------------------------

variable "cloudfront_price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_100"
}

# ---------------------------------------------------------------------------
# Database (RDS Postgres)
# ---------------------------------------------------------------------------

variable "db_name" {
  description = "Postgres database name."
  type        = string
  default     = "petclinic"
}

variable "db_username" {
  description = "Master username for RDS Postgres."
  type        = string
  default     = "petclinic"
}

variable "db_engine_version" {
  description = "Postgres engine version on RDS."
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS, in GB."
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Whether to run RDS in Multi-AZ mode."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot on RDS destroy. Set to false for production."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# GitHub Actions OIDC (CI/CD deploy role)
# ---------------------------------------------------------------------------

variable "create_github_oidc_provider" {
  description = "Whether to create the GitHub Actions OIDC identity provider. Set to false if one already exists in this AWS account (only one provider per URL is allowed per account)."
  type        = bool
  default     = true
}

variable "github_org" {
  description = "GitHub organization or user that owns the repo (used to scope the OIDC trust policy). Required to create the deploy role."
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "GitHub repository name (used to scope the OIDC trust policy). Required to create the deploy role."
  type        = string
  default     = "pet-clinic"
}

variable "github_oidc_subjects" {
  description = "List of allowed OIDC \"sub\" claim patterns for the GitHub Actions trust policy. Defaults to any ref/branch/PR in github_org/github_repo. Narrow this (e.g. [\"repo:org/repo:ref:refs/heads/main\"]) to restrict which branches/workflows can assume the role."
  type        = list(string)
  default     = []
}

