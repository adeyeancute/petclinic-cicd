# GitHub's OIDC token endpoint. Its TLS chain's thumbprint is what AWS uses
# to trust tokens issued by token.actions.githubusercontent.com.
data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_github_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

data "aws_iam_openid_connect_provider" "github_actions" {
  count = local.create_github_deploy_role && !var.create_github_oidc_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

locals {
  github_oidc_provider_arn = var.create_github_oidc_provider ? (
    length(aws_iam_openid_connect_provider.github_actions) > 0 ? aws_iam_openid_connect_provider.github_actions[0].arn : null
    ) : (
    local.create_github_deploy_role ? data.aws_iam_openid_connect_provider.github_actions[0].arn : null
  )
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  count = local.create_github_deploy_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  count              = local.create_github_deploy_role ? 1 : 0
  name               = "${var.project_name}-${var.environment}-github-actions-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
}

# --- Push images to the app's ECR repository.

data "aws_iam_policy_document" "github_actions_ecr" {
  count = local.create_github_deploy_role ? 1 : 0

  statement {
    sid       = "EcrAuth"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPushPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

# --- Deploy new task definitions / update the ECS service.

data "aws_iam_policy_document" "github_actions_ecs" {
  count = local.create_github_deploy_role ? 1 : 0

  statement {
    sid = "EcsDeploy"
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:DescribeTaskDefinition",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "EcsDeregisterTaskDefinition"
    actions   = ["ecs:DeregisterTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid       = "PassEcsRoles"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ecs_execution.arn, aws_iam_role.ecs_task.arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_ecr" {
  count  = local.create_github_deploy_role ? 1 : 0
  name   = "ecr-push"
  role   = aws_iam_role.github_actions_deploy[0].id
  policy = data.aws_iam_policy_document.github_actions_ecr[0].json
}

resource "aws_iam_role_policy" "github_actions_ecs" {
  count  = local.create_github_deploy_role ? 1 : 0
  name   = "ecs-deploy"
  role   = aws_iam_role.github_actions_deploy[0].id
  policy = data.aws_iam_policy_document.github_actions_ecs[0].json
}
