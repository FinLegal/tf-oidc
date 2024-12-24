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
  #casesite_bucket        = data.terraform_remote_state.casesites.outputs.casesite_bucket
  #casesite_static_bucket = data.terraform_remote_state.casesites.outputs.casesite_static_bucket
  casesite_execution_role = lookup(data.terraform_remote_state.casesites.outputs.task_data, "case-sites", {}).iam_execution_role_arn
  casesite_task_role      = lookup(data.terraform_remote_state.casesites.outputs.task_data, "case-sites", {}).iam_task_role_arn

  ## Legacy Casesites ##
  #kl_vauxhall_service_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KLVauxhall-${local.ecs_role_naming}-ecs_service_execution_role"
  #mb_floods_service_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MB-${local.ecs_role_naming}-ecs_service_execution_role"
  #hf_trades_service_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/HFTrades-${local.ecs_role_naming}-ecs_service_execution_role"
  #kl_merc_service_role     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KL-${local.ecs_role_naming}-ecs_service_execution_role"
  #lsc_energy_service_role  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/LSCEnergy-${local.ecs_role_naming}-ecs_service_execution_role"

  #kl_vauxhall_task_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KLVauxhall-${local.ecs_role_naming}-ecs_task_execution_role"
  #mb_floods_task_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/MB-${local.ecs_role_naming}-ecs_task_execution_role"
  #hf_trades_task_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/HFTrades-${local.ecs_role_naming}-ecs_task_execution_role"
  #kl_merc_task_role     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/KL-${local.ecs_role_naming}-ecs_task_execution_role"
  #lsc_energy_task_role  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/LSCEnergy-${local.ecs_role_naming}-ecs_task_execution_role"

  #legacy_casesites_iam_roles = [local.kl_vauxhall_service_role, local.mb_floods_service_role, local.hf_trades_service_role, local.kl_merc_service_role, local.lsc_energy_service_role, local.kl_vauxhall_task_role, local.mb_floods_task_role, local.hf_trades_task_role, local.kl_merc_task_role, local.lsc_energy_task_role]

  ## CaseFunnel Objects - Will be moved to Scalr over time ##
  #casefunnel_api_service_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/API-${local.ecs_role_naming}-ecs_service_execution_role"
  #casefunnel_systemjobs_service_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/SystemJobs-${local.ecs_role_naming}-ecs_service_execution_role"
  #casefunnel_admin_service_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Admin-${local.ecs_role_naming}-ecs_service_execution_role"
  #casefunnel_dashboard_service_role  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Dashboard-${local.ecs_role_naming}-ecs_service_execution_role"
  #casefunnel_userjobs_service_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/UserJobs-${local.ecs_role_naming}-ecs_service_execution_role"

  #casefunnel_api_task_role        = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/API-${local.ecs_role_naming}-ecs_task_execution_role"
  #casefunnel_systemjobs_task_role = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/SystemJobs-${local.ecs_role_naming}-ecs_task_execution_role"
  #casefunnel_admin_task_role      = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Admin-${local.ecs_role_naming}-ecs_task_execution_role"
  #casefunnel_dashboard_task_role  = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/Dashboard-${local.ecs_role_naming}-ecs_task_execution_role"
  #casefunnel_userjobs_task_role   = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/UserJobs-${local.ecs_role_naming}-ecs_task_execution_role"

  #casefunnel_iam_roles   = [local.casefunnel_api_service_role, local.casefunnel_api_task_role, local.casefunnel_systemjobs_service_role, local.casefunnel_systemjobs_task_role, local.casefunnel_admin_service_role, local.casefunnel_admin_task_role, local.casefunnel_dashboard_service_role, local.casefunnel_dashboard_task_role, local.casefunnel_userjobs_service_role, local.casefunnel_userjobs_task_role]
  #casefunnel_branch_list = var.default_tags["Environment"] == "Development" ? ["repo:FinLegal/casefunnel:ref:refs/heads/dev"] : ["repo:FinLegal/casefunnel-deployments:ref:refs/heads/master"]
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

#data "aws_iam_policy_document" "this_casesitedefinitions" {
#  statement {
#    sid       = "AllowList"
#    effect    = "Allow"
#    actions   = ["s3:ListBucket"]
#    resources = [local.casesite_bucket, local.casesite_static_bucket]
#  }
#  statement {
#    sid       = "AllowPut"
#    effect    = "Allow"
#    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#    resources = ["${local.casesite_bucket}/*", "${local.casesite_static_bucket}/*"]
#  }
#}

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

#data "aws_iam_policy_document" "this_casesites_legacy" {
#  statement {
#    sid       = "AllowCodeDeployPass"
#    effect    = "Allow"
#    actions   = ["iam:PassRole"]
#    resources = local.legacy_casesites_iam_roles
#  }
#  statement {
#    sid    = "GetDeployments"
#    effect = "Allow"
#    actions = [
#      "codedeploy:GetDeploymentConfig",
#      "codedeploy:GetDeployment",
#      "codedeploy:GetDeploymentConfig",
#      "codedeploy:GetDeploymentGroup",
#      "codedeploy:CreateDeployment",
#      "codedeploy:RegisterApplicationRevision",
#    ]
#    resources = ["*"]
#  }
#}

data "aws_iam_policy_document" "this_ecs" {
  statement {
    sid       = "AllowECS"
    effect    = "Allow"
    actions   = ["ecs:RegisterTaskDefinition", "ecs:DescribeTaskDefinition", "ecs:DescribeServices"]
    resources = ["*"]
  }
}

#data "aws_iam_policy_document" "this_casefunnel" {
#  statement {
#    sid       = "AllowCodeDeployPass"
#    effect    = "Allow"
#    actions   = ["iam:PassRole"]
#    resources = local.casefunnel_iam_roles
#  }
#  statement {
#    sid    = "GetDeployments"
#    effect = "Allow"
#    actions = [
#      "codedeploy:GetDeploymentConfig",
#      "codedeploy:GetDeployment",
#      "codedeploy:GetDeploymentConfig",
#      "codedeploy:GetDeploymentGroup",
#      "codedeploy:CreateDeployment",
#      "codedeploy:RegisterApplicationRevision",
#    ]
#    resources = ["*"]
#  }
#}