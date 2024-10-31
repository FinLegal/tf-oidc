########################################
# GitHub OIDC
########################################

module "git" {
  source  = "finlegal.scalr.io/acc-v0od9n5ghtfveu0dj/oidc/aws"
  version = "0.1.23"

  name_prefix = local.name_prefix
  oidc_provider_configuration = {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
  }
  provider_role_configuration = {
    ## case-definitions ##
    "casesitedefinitions" = {
      policies = {
        "s3-casesites" = {
          policy = data.aws_iam_policy_document.this_casesitedefinitions.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-definitions:ref:refs/heads/main"] } })
    }
    ## case-sites ##
    "casesites" = {
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
        "codedeploy-legacy" = {
          policy = data.aws_iam_policy_document.this_casesites_legacy.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-sites:ref:refs/heads/main", "repo:FinLegal/case-sites:ref:refs/heads/release-generic"] } })
    }
    ## casefunnel ##
    "casefunnel" = {
      policies = {
        "ecr" = {
          policy = data.aws_iam_policy_document.this_ecr_token.json
        }
        "codedeploy" = {
          policy = data.aws_iam_policy_document.this_casefunnel.json
        }
        "ecs" = {
          policy = data.aws_iam_policy_document.this_ecs.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.casefunnel_branch_list } })
    }
  }
}
