########################################
# GitHub OIDC
########################################

module "git" {
  source  = "finlegal.scalr.io/acc-v0od9n5ghtfveu0dj/oidc/aws"
  version = "1.0.22-beta.21"

  oidc_provider_configuration = {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
  }
  provider_role_configuration = {
    ## legacy github terraform (infra repo) ##
    #"terraform" = {
    #  policies = {
    #    "terraform" = {
    #      policy = data.aws_iam_policy_document.this_terraform.json
    #    }
    #  }
    #  conditions = merge(local.aws_github_audience, { "repo" = { test = "StringLike", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/infrastructure:*"] } })
    #}
    ## case-definitions ##
    #"casesitedefinitions" = {
    #  policies = {
    #    "s3-casesites" = {
    #      policy = data.aws_iam_policy_document.this_casesitedefinitions.json
    #    }
    #  }
    #  conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-definitions:ref:refs/heads/main"] } })
    #}
    ## case-sites ##
    "case-sites" = {
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
        #"codedeploy-legacy" = {
        #  policy = data.aws_iam_policy_document.this_casesites_legacy.json
        #}
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-sites:ref:refs/heads/main", "repo:FinLegal/case-sites:ref:refs/heads/release-generic", "repo:FinLegal/case-sites:ref:refs/heads/lza"] } })
    }
    ## casefunnel ##
    #"casefunnel" = {
    #  policies = {
    #    "ecr" = {
    #      policy = data.aws_iam_policy_document.this_ecr_token.json
    #    }
    #    "codedeploy" = {
    #      policy = data.aws_iam_policy_document.this_casefunnel.json
    #    }
    #    "ecs" = {
    #      policy = data.aws_iam_policy_document.this_ecs.json
    #    }
    #  }
    #  conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.casefunnel_branch_list } })
    #}
  }
}
