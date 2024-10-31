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
      name = "Casesites"
    }
  }
}

########################################
# Computed Variables
########################################

locals {
  ## Metadata ##
  product_shortcode     = lower(substr(var.default_tags.Product, 0, 3))
  region_split          = split("-", data.aws_region.this.name)
  geo                   = local.region_split[0]
  locality              = substr(local.region_split[1], 0, 1)
  locality_number       = local.region_split[2]
  region_shortcode      = "${local.geo}${local.locality}${local.locality_number}"
  environment_shortcode = lower(substr(var.default_tags.Environment, 0, 3))

  ## Naming ##
  name_prefix = "${local.product_shortcode}-${local.region_shortcode}-${local.environment_shortcode}"

  ## GitHub OIDC ##
  aws_github_audience = {
    "token" = {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }

  ecs_role_naming = var.default_tags["Environment"] == "Development" ? "Dev" : var.default_tags["Environment"] == "Staging" ? "Staging" : var.default_tags["Environment"] == "Production-UK" ? "Prod" : var.default_tags["Environment"] == "Production-AU" ? "Sydney" : "Ohio"

  ## Casesite Objects ##
  casesite_bucket        = data.terraform_remote_state.casesites.outputs.casesite_bucket
  casesite_static_bucket = data.terraform_remote_state.casesites.outputs.casesite_static_bucket
  casesite_service_role  = data.terraform_remote_state.casesites.outputs.service_iam_role
  casesite_task_role     = lookup(data.terraform_remote_state.casesites.outputs.task_iam_roles, "casesites", {}).arn

  ## Legacy Casesites ##
  kl_vauxhall_service_role    = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KLVauxhall-${local.ecs_role_naming}-ecs_service_execution_role"
  mb_lisbon_service_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBLisbon-${local.ecs_role_naming}-ecs_service_execution_role"
  mb_star_service_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBStar-${local.ecs_role_naming}-ecs_service_execution_role"
  mb_shareholder_service_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBShareholder-${local.ecs_role_naming}-ecs_service_execution_role"
  mb_floods_service_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MB-${local.ecs_role_naming}-ecs_service_execution_role"
  mb_roundup_service_role     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBRoundup-${local.ecs_role_naming}-ecs_service_execution_role"
  hf_trades_service_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/HFTrades-${local.ecs_role_naming}-ecs_service_execution_role"
  kl_merc_service_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KL-${local.ecs_role_naming}-ecs_service_execution_role"
  mb_piedmont_service_role    = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBPiedmont-${local.ecs_role_naming}-ecs_service_execution_role"
  lsc_energy_service_role     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/LSCEnergy-${local.ecs_role_naming}-ecs_service_execution_role"

  kl_vauxhall_task_role    = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KLVauxhall-${local.ecs_role_naming}-ecs_task_execution_role"
  mb_lisbon_task_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBLisbon-${local.ecs_role_naming}-ecs_task_execution_role"
  mb_star_task_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBStar-${local.ecs_role_naming}-ecs_task_execution_role"
  mb_shareholder_task_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBShareholder-${local.ecs_role_naming}-ecs_task_execution_role"
  mb_floods_task_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MB-${local.ecs_role_naming}-ecs_task_execution_role"
  mb_roundup_task_role     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBRoundup-${local.ecs_role_naming}-ecs_task_execution_role"
  hf_trades_task_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/HFTrades-${local.ecs_role_naming}-ecs_task_execution_role"
  kl_merc_task_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KL-${local.ecs_role_naming}-ecs_task_execution_role"
  mb_piedmont_task_role    = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MBPiedmont-${local.ecs_role_naming}-ecs_task_execution_role"
  lsc_energy_task_role     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/LSCEnergy-${local.ecs_role_naming}-ecs_task_execution_role"

  legacy_casesites_iam_roles = [local.kl_vauxhall_service_role, local.mb_lisbon_service_role, local.mb_star_service_role, local.mb_shareholder_service_role, local.mb_floods_service_role, local.mb_roundup_service_role, local.hf_trades_service_role, local.kl_merc_service_role, local.mb_piedmont_service_role, local.lsc_energy_service_role, local.kl_vauxhall_task_role, local.mb_lisbon_task_role, local.mb_star_task_role, local.mb_shareholder_task_role, local.mb_floods_task_role, local.mb_roundup_task_role, local.hf_trades_task_role, local.kl_merc_task_role, local.mb_piedmont_task_role, local.lsc_energy_task_role]

  ## CaseFunnel Objects - Will be moved to Scalr over time ##
  casefunnel_api_service_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/API-${local.ecs_role_naming}-ecs_service_execution_role"
  casefunnel_systemjobs_service_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/SystemJobs-${local.ecs_role_naming}-ecs_service_execution_role"
  casefunnel_admin_service_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Admin-${local.ecs_role_naming}-ecs_service_execution_role"
  casefunnel_dashboard_service_role  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Dashboard-${local.ecs_role_naming}-ecs_service_execution_role"
  casefunnel_userjobs_service_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/UserJobs-${local.ecs_role_naming}-ecs_service_execution_role"

  casefunnel_api_task_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/API-${local.ecs_role_naming}-ecs_task_execution_role"
  casefunnel_systemjobs_task_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/SystemJobs-${local.ecs_role_naming}-ecs_task_execution_role"
  casefunnel_admin_task_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Admin-${local.ecs_role_naming}-ecs_task_execution_role"
  casefunnel_dashboard_task_role  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Dashboard-${local.ecs_role_naming}-ecs_task_execution_role"
  casefunnel_userjobs_task_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/UserJobs-${local.ecs_role_naming}-ecs_task_execution_role"

  casefunnel_iam_roles   = [local.casefunnel_api_service_role, local.casefunnel_api_task_role, local.casefunnel_systemjobs_service_role, local.casefunnel_systemjobs_task_role, local.casefunnel_admin_service_role, local.casefunnel_admin_task_role, local.casefunnel_dashboard_service_role, local.casefunnel_dashboard_task_role, local.casefunnel_userjobs_service_role, local.casefunnel_userjobs_task_role]
  casefunnel_branch_list = var.default_tags["Environment"] == "Development" ? ["repo:FinLegal/casefunnel:ref:refs/heads/dev"] : ["repo:FinLegal/casefunnel-deployments:ref:refs/heads/master"]
}

########################################
# Policies
########################################

data "aws_iam_policy_document" "this_casesitedefinitions" {
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
    resources = [local.casesite_service_role, local.casesite_task_role]
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

data "aws_iam_policy_document" "this_casesites_legacy" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = local.legacy_casesites_iam_roles
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

data "aws_iam_policy_document" "this_casefunnel" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = local.casefunnel_iam_roles
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