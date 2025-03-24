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

data "terraform_remote_state" "indexer_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-Search-indexer"
    }
  }
}

data "terraform_remote_state" "csdef_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-Definition-service"
    }
  }
}

data "terraform_remote_state" "api_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-API"
    }
  }
}

data "terraform_remote_state" "userjobs_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-User-jobs"
    }
  }
}

data "terraform_remote_state" "systemjobs_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-System-jobs"
    }
  }
}

data "terraform_remote_state" "dashboard_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-Dashboard"
    }
  }
}

data "terraform_remote_state" "admin_ecr" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "ECR-Admin"
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
  resource_tags     = merge(var.default_tags, var.tags)
  core_ecr_branches = ["repo:FinLegal/casefunnel:ref:refs/heads/dev", "repo:FinLegal/casefunnel:ref:refs/heads/master", "repo:FinLegal/casefunnel:ref:refs/heads/staging-release-lza"]

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
  casesite_release_branches  = ["main", "release-generic"]
  casesite_deployment_bucket = data.terraform_remote_state.claimsautomation_sharedservices.outputs.deployment_s3_arn

  ## Search ##
  search_ecr      = split("/", data.terraform_remote_state.search_ecr.outputs.aws_ecr_repository)
  search_ecr_arn  = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.search_ecr[1]}"
  indexer_ecr     = split("/", data.terraform_remote_state.indexer_ecr.outputs.aws_ecr_repository)
  indexer_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.indexer_ecr[1]}"

  ## Definition Service ##
  csdef_ecr     = split("/", data.terraform_remote_state.csdef_ecr.outputs.aws_ecr_repository)
  csdef_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.csdef_ecr[1]}"

  ## API ##
  api_ecr     = split("/", data.terraform_remote_state.api_ecr.outputs.aws_ecr_repository)
  api_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.api_ecr[1]}"

  ## System Jobs ##
  systemjobs_ecr     = split("/", data.terraform_remote_state.systemjobs_ecr.outputs.aws_ecr_repository)
  systemjobs_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.systemjobs_ecr[1]}"

  ## User Jobs ##
  userjobs_ecr     = split("/", data.terraform_remote_state.userjobs_ecr.outputs.aws_ecr_repository)
  userjobs_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.userjobs_ecr[1]}"

  ## Dashboard ##
  dashboard_ecr     = split("/", data.terraform_remote_state.dashboard_ecr.outputs.aws_ecr_repository)
  dashboard_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.dashboard_ecr[1]}"

  ## Admin ##
  admin_ecr     = split("/", data.terraform_remote_state.admin_ecr.outputs.aws_ecr_repository)
  admin_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.admin_ecr[1]}"

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
    resources = [local.search_ecr_arn, local.indexer_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_csdef_ecr" {
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
    resources = [local.csdef_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_api_ecr" {
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
    resources = [local.api_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_systemjobs_ecr" {
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
    resources = [local.systemjobs_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_userjobs_ecr" {
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
    resources = [local.userjobs_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_dashboard_ecr" {
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
    resources = [local.dashboard_ecr_arn]
  }
}

data "aws_iam_policy_document" "this_admin_ecr" {
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
    resources = [local.admin_ecr_arn]
  }
}