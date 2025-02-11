########################################
# Data Sources
########################################

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
data "scalr_current_run" "this" {}

data "terraform_remote_state" "casesites" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "Case-sites"
    }
  }
}

data "terraform_remote_state" "appsupport" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "AppSupport"
    }
  }
}

########################################
# Computed Variables
########################################

locals {
  ## Metadata ##
  resource_tags = merge(var.default_tags, var.tags)

  ## GitHub OIDC ##
  aws_github_audience = {
    "token" = {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }

  ## Casesite Objects ##
  casesite_bucket         = data.terraform_remote_state.casesites.outputs.case_site_s3_arn
  casesite_static_bucket  = data.terraform_remote_state.casesites.outputs.case_site_static_s3_arn
  casesite_execution_role = lookup(data.terraform_remote_state.casesites.outputs.task_data, "case-sites", {}).iam_execution_role_arn
  casesite_task_role      = lookup(data.terraform_remote_state.casesites.outputs.task_data, "case-sites", {}).iam_task_role_arn
  search_execution_role   = lookup(data.terraform_remote_state.appsupport.outputs.search_task_data, "search", {}).iam_execution_role_arn
  search_task_role      = lookup(data.terraform_remote_state.appsupport.outputs.search_task_data, "search", {}).iam_task_role_arn
  indexing_execution_role   = lookup(data.terraform_remote_state.appsupport.outputs.indexing_task_data, "indexing", {}).iam_execution_role_arn
  indexing_task_role      = lookup(data.terraform_remote_state.appsupport.outputs.indexing_task_data, "indexing", {}).iam_task_role_arn

}

########################################
# Policies
########################################

data "aws_iam_policy_document" "this_casesite_definitions" {
  statement {
    sid       = "AllowList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.casesite_bucket, local.casesite_static_bucket]
  }
  statement {
    sid       = "AllowPut"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.casesite_bucket}/*", "${local.casesite_static_bucket}/*"]
  }
}

data "aws_iam_policy_document" "this_ecr_token" {
  statement {
    sid       = "AllowAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "this_casesites" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.casesite_execution_role, local.casesite_task_role]
  }
  statement {
    sid    = "GetDeployments"
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:CreateDeployment",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "this_ecs" {
  statement {
    sid       = "AllowECS"
    effect    = "Allow"
    actions   = ["ecs:RegisterTaskDefinition", "ecs:DescribeTaskDefinition", "ecs:DescribeServices"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "this_search" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.search_execution_role, local.search_task_role, local.indexing_execution_role, local.indexing_task_role]
  }
  statement {
    sid    = "GetDeployments"
    effect = "Allow"
    actions = [
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:CreateDeployment",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = ["*"]
  }
}