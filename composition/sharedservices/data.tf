########################################
# Data Sources
########################################

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
data "scalr_current_run" "this" {}

#data "terraform_remote_state" "storybook" {
#  backend = "remote"

#  config = {
#    hostname     = "finlegal.scalr.io"
#    organization = data.scalr_current_run.this.environment_id
#    workspaces = {
#      name = "Storybook"
#    }
#  }
#}

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

  ## Objects (These will be moved to remote state as we migrate to Scalr) ##
  #storybook_bucket           = data.terraform_remote_state.storybook.outputs.s3_arn
  #internal_docs_bucket       = "arn:aws:s3:::finlegal-internal"
  #public_docs_bucket         = "arn:aws:s3:::finlegal-docs"
  #static_bucket              = "arn:aws:s3:::casefunnel-io-static"

  ## Casesites ##
  casesite_ecr               = split("/", data.terraform_remote_state.casesite_ecr.outputs.aws_ecr_repository)
  casesite_ecr_arn           = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/${local.casesite_ecr[1]}"
  casesite_release_branches  = ["main", "release-generic", "release-hf-trades", "release-kl-merc", "release-kl-vauxhall", "release-lsc-energy", "release-mb-floods", "lza-deploy"]
  casesite_deployment_bucket = data.terraform_remote_state.claimsautomation_sharedservices.outputs.deployment_s3_arn

  ### Casefunnel ##
  #casefunnel_admin_ecr_arn      = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/casefunnel-admin"
  #casefunnel_api_ecr_arn        = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/casefunnel-api"
  #casefunnel_dashboard_ecr_arn  = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/casefunnel-dashboard"
  #casefunnel_systemjobs_ecr_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/casefunnel-systemjobs"
  #casefunnel_userjobs_ecr_arn   = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/casefunnel-userjobs"
  #casefunnel_ecr_arn_list       = [local.casefunnel_admin_ecr_arn, local.casefunnel_api_ecr_arn, local.casefunnel_dashboard_ecr_arn, local.casefunnel_userjobs_ecr_arn, local.casefunnel_systemjobs_ecr_arn]

  ## Legacy Casesites ##
  ## ECR
  #hf_trades_ecr_arn       = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-hf-trades"
  #hf_trades_release_arn   = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-hf-trades-release"
  #kl_merc_ecr_arn         = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-kl-merc"
  #kl_merc_release_arn     = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-kl-merc-release"
  #kl_vauxhall_ecr_arn     = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-kl-vauxhall"
  #kl_vauxhall_release_arn = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-kl-vauxhall-release"
  #lsc_energy_ecr_arn      = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-lsc-energy"
  #lsc_energy_release_arn  = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-lsc-energy-release"
  #mb_floods_ecr_arn       = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-mb-floods"
  #mb_floods_release_arn   = "arn:aws:ecr:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:repository/case-site-mb-floods-release"
  #legacy_ecr_arn_list     = [local.hf_trades_ecr_arn, local.hf_trades_release_arn, local.kl_merc_ecr_arn, local.kl_merc_release_arn, local.kl_vauxhall_ecr_arn, local.kl_vauxhall_release_arn, local.lsc_energy_ecr_arn, local.lsc_energy_release_arn, local.mb_floods_ecr_arn, local.mb_floods_release_arn]
}

########################################
# Policies
########################################

#data "aws_iam_policy_document" "this_terraform" {
#  statement {
#    sid         = "DisallowAdminActions"
#    effect      = "Allow"
#    not_actions = ["organizations:*", "account:*"]
#    resources   = ["*"]
#  }
#  statement {
#    sid    = "AllowBasicActions"
#    effect = "Allow"
#    actions = [
#      "account:GetAccountInformation",
#      "account:GetPrimaryEmail",
#      "account:ListRegions",
#      "organizations:DescribeOrganization"
#    ]
#    resources = ["*"]
#  }
#}

#data "aws_iam_policy_document" "this_storybook" {
#  statement {
#    sid       = "AllowList"
#    effect    = "Allow"
#    actions   = ["s3:ListBucket"]
#    resources = [local.storybook_bucket]
#  }
#  statement {
#    sid       = "AllowPut"
#    effect    = "Allow"
#    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#    resources = ["${local.storybook_bucket}/*"]
#  }
#}

#data "aws_iam_policy_document" "this_docs_private" {
#  statement {
#    sid       = "AllowList"
#    effect    = "Allow"
#    actions   = ["s3:ListBucket"]
#    resources = [local.internal_docs_bucket]
#  }
#  statement {
#    sid       = "AllowPut"
#    effect    = "Allow"
#    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#    resources = ["${local.internal_docs_bucket}/*"]
#  }
#}

#data "aws_iam_policy_document" "this_docs_public" {
#  statement {
#    sid       = "AllowList"
#    effect    = "Allow"
#    actions   = ["s3:ListBucket"]
#    resources = [local.public_docs_bucket]
#  }
#  statement {
#    sid       = "AllowPut"
#    effect    = "Allow"
#    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#    resources = ["${local.public_docs_bucket}/*"]
#  }
#}

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

#data "aws_iam_policy_document" "this_static_deployment" {
#  statement {
#    sid       = "AllowList"
#    effect    = "Allow"
#    actions   = ["s3:ListBucket"]
#    resources = [local.static_bucket]
#  }
#  statement {
#    sid       = "AllowPut"
#    effect    = "Allow"
#    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:GetObjectAcl", "s3:PutObjectAcl"]
#    resources = ["${local.static_bucket}/*"]
#  }
#}

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

#data "aws_iam_policy_document" "this_casesite_ecr_legacy" {
#  statement {
#    sid       = "AllowAuthToken"
#    effect    = "Allow"
#    actions   = ["ecr:GetAuthorizationToken"]
#    resources = ["*"]
#  }
#  statement {
#    sid    = "AllowECR"
#   effect = "Allow"
#   actions = [
#     "ecr:BatchCheckLayerAvailability",
#      "ecr:CompleteLayerUpload",
#      "ecr:UploadLayerPart",
#      "ecr:InitiateLayerUpload",
#      "ecr:PutImage"
#    ]
#    resources = local.legacy_ecr_arn_list
#  }
#}

#data "aws_iam_policy_document" "this_casefunnel_ecr" {
#  statement {
#    sid       = "AllowAuthToken"
#    effect    = "Allow"
#    actions   = ["ecr:GetAuthorizationToken"]
#    resources = ["*"]
#  }
#  statement {
#    sid    = "AllowECR"
#    effect = "Allow"
#    actions = [
#      "ecr:BatchCheckLayerAvailability",
#      "ecr:CompleteLayerUpload",
#      "ecr:UploadLayerPart",
#      "ecr:InitiateLayerUpload",
#      "ecr:PutImage"
#    ]
#    resources = local.casefunnel_ecr_arn_list
#  }
#}