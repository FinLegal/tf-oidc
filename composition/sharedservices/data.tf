########################################
# Data Sources
########################################

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
data "scalr_current_run" "this" {}

data "terraform_remote_state" "casesite_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-Case-sites"
    }
  }
}

data "terraform_remote_state" "search_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-Search-service"
    }
  }
}

data "terraform_remote_state" "claimsautomation_sharedservices" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ClaimsAutomation-Shared-Services"
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

  ## Casesites ##
  casesite_ecr               = split("/", data.terraform_remote_state.casesite_ecr.outputs.aws_ecr_repository)
  casesite_ecr_arn           = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.casesite_ecr[1]}"
  casesite_release_branches  = ["main", "release-generic", "lza-deploy"]
  casesite_deployment_bucket = data.terraform_remote_state.claimsautomation_sharedservices.outputs.deployment_s3_arn

  ## Search ##
  search_ecr     = split("/", data.terraform_remote_state.search_ecr.outputs.aws_ecr_repository)
  search_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.search_ecr[1]}"
}

########################################
# Policies
########################################

data "aws_iam_policy_document" "this_case_deployment" {
  statement {
    sid       = "AllowList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [local.casesite_deployment_bucket]
  }
  statement {
    sid       = "AllowPut"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.casesite_deployment_bucket}/*"]
  }
}

data "aws_iam_policy_document" "this_casesite_ecr" {
  statement {
    sid       = "AllowAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowECR"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage"
    ]
    resources = [local.casesite_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_search_ecr" {
  statement {
    sid       = "AllowAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowECR"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage"
    ]
    resources = [local.search_ecr_arn]
  }
}