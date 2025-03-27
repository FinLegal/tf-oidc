########################################
# Data Sources
########################################

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

data "terraform_remote_state" "core" {
  backend = "remote"

  config = {
    hostname     = "finlegal.scalr.io"
    organization = data.scalr_current_run.this.environment_id
    workspaces = {
      name = "Core"
    }
  }
}


########################################
# Computed Variables
########################################

locals {
  ## Metadata ##
  resource_tags        = merge(var.default_tags, var.tags)
  geo_check            = var.default_tags["Environment"] == "Sydney" || var.default_tags["Environment"] == "Ohio"
  name_suffix          = local.geo_check ? "-${var.default_tags["Environment"]}" : ""
  core_deploy_branches = ["repo:FinLegal/casefunnel:ref:refs/heads/dev", "repo:FinLegal/casefunnel-deployments:ref:refs/heads/master"]


  ## GitHub OIDC ##
  aws_github_audience = {
    "token" = {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }

  ## Service Config ## 
  service_config = {
    "case-site-definitions${local.name_suffix}" = {
      policies = {
        "s3-case-sites" = {
          policy = data.aws_iam_policy_document.this_casesite_definitions.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = ["repo:FinLegal/case-definitions:ref:refs/heads/main"]
        }
      })
    }
    "case-sites${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_casesites.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values = [
            "repo:FinLegal/case-sites:ref:refs/heads/main",
            "repo:FinLegal/case-sites:ref:refs/heads/release-generic"
          ]
        }
      })
    }
    "search-service${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_search.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = ["repo:FinLegal/svc-search:ref:refs/heads/main"]
        }
      })
    }
    "api${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_api.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = local.core_deploy_branches
        }
      })
    }
    "case-site-definition-service${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_csdef.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = ["repo:FinLegal/case-definition-service:ref:refs/heads/main"]
        }
      })
    }
    "admin-web${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_admin.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = local.core_deploy_branches
        }
      })
    }
    "dashboard-web${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_dashboard.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = local.core_deploy_branches
        }
      })
    }
    "user-jobs${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_userjobs.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = local.core_deploy_branches
        }
      })
    }
    "system-jobs${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_systemjobs.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = local.core_deploy_branches
        }
      })
    }
    "background-jobs${local.name_suffix}" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_backgroundjobs.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, {
        "repo" = {
          test     = "StringEquals",
          variable = "token.actions.githubusercontent.com:sub",
          values   = ["repo:FinLegal/svc-background-jobs:ref:refs/heads/master"]
        }
      })
    }
  }

  ## Casesite Objects ##
  casesite_bucket               = data.terraform_remote_state.casesites.outputs.case_site_s3_arn
  casesite_static_bucket        = data.terraform_remote_state.casesites.outputs.case_site_static_s3_arn
  casesite_execution_role       = lookup(data.terraform_remote_state.casesites.outputs.task_data, "case-sites", {}).iam_execution_role_arn
  casesite_task_role            = lookup(data.terraform_remote_state.casesites.outputs.task_data, "case-sites", {}).iam_task_role_arn
  csdef_execution_role          = lookup(data.terraform_remote_state.casesites.outputs.csdef_task_data, "cs-definitions", {}).iam_execution_role_arn
  csdef_task_role               = lookup(data.terraform_remote_state.casesites.outputs.csdef_task_data, "cs-definitions", {}).iam_task_role_arn
  search_execution_role         = lookup(data.terraform_remote_state.appsupport.outputs.search_task_data, "search", {}).iam_execution_role_arn
  search_task_role              = lookup(data.terraform_remote_state.appsupport.outputs.search_task_data, "search", {}).iam_task_role_arn
  indexing_execution_role       = lookup(data.terraform_remote_state.appsupport.outputs.indexing_task_data, "indexing", {}).iam_execution_role_arn
  indexing_task_role            = lookup(data.terraform_remote_state.appsupport.outputs.indexing_task_data, "indexing", {}).iam_task_role_arn
  internal_api_execution_role   = lookup(data.terraform_remote_state.core.outputs.api_task_data, "internal-api", {}).iam_execution_role_arn
  internal_api_task_role        = lookup(data.terraform_remote_state.core.outputs.api_task_data, "internal-api", {}).iam_task_role_arn
  public_api_execution_role     = lookup(data.terraform_remote_state.core.outputs.api_task_data, "public-api", {}).iam_execution_role_arn
  public_api_task-role          = lookup(data.terraform_remote_state.core.outputs.api_task_data, "public-api", {}).iam_task_role_arn
  admin_execution_role          = lookup(data.terraform_remote_state.core.outputs.web_task_data, "admin-web", {}).iam_execution_role_arn
  admin_task_role               = lookup(data.terraform_remote_state.core.outputs.web_task_data, "admin-web", {}).iam_task_role_arn
  dashboard_execution_role      = lookup(data.terraform_remote_state.core.outputs.web_task_data, "dashboard-web", {}).iam_execution_role_arn
  dashboard_task_role           = lookup(data.terraform_remote_state.core.outputs.web_task_data, "dashboard-web", {}).iam_task_role_arn
  userjobs_execution_role       = lookup(data.terraform_remote_state.core.outputs.hangfire_task_data, "user-jobs", {}).iam_execution_role_arn
  userjobs_task_role            = lookup(data.terraform_remote_state.core.outputs.hangfire_task_data, "user-jobs", {}).iam_task_role_arn
  systemjobs_execution_role     = lookup(data.terraform_remote_state.core.outputs.hangfire_task_data, "system-jobs", {}).iam_execution_role_arn
  systemjobs_task_role          = lookup(data.terraform_remote_state.core.outputs.hangfire_task_data, "system-jobs", {}).iam_task_role_arn
  backgroundjobs_execution_role = lookup(data.terraform_remote_state.appsupport.outputs.background_task_data, "background-jobs", {}).iam_execution_role_arn
  backgroundjobs_task_role      = lookup(data.terraform_remote_state.appsupport.outputs.background_task_data, "background-jobs", {}).iam_task_role_arn
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

data "aws_iam_policy_document" "this_api" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.internal_api_execution_role, local.internal_api_task_role, local.public_api_execution_role, local.public_api_task-role]
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

data "aws_iam_policy_document" "this_csdef" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.csdef_execution_role, local.csdef_task_role]
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

data "aws_iam_policy_document" "this_admin" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.admin_execution_role, local.admin_task_role]
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

data "aws_iam_policy_document" "this_dashboard" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.dashboard_execution_role, local.dashboard_task_role]
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

data "aws_iam_policy_document" "this_userjobs" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.userjobs_execution_role, local.userjobs_task_role]
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

data "aws_iam_policy_document" "this_systemjobs" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.systemjobs_execution_role, local.systemjobs_task_role]
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

data "aws_iam_policy_document" "this_backgroundjobs" {
  statement {
    sid       = "AllowCodeDeployPass"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.backgroundjobs_execution_role, local.backgroundjobs_task_role]
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