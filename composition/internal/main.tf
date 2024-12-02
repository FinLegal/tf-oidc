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
    ## legacy github terraform (infra repo) ##
    "terraform" = {
      policies = {
        "terraform" = {
          policy = data.aws_iam_policy_document.this_terraform.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringLike", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/infrastructure:*"] } })
    }
    ## Storybook ##
    "storybook" = {
      policies = {
        "s3" = {
          policy = data.aws_iam_policy_document.this_storybook.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/casefunnel:ref:refs/heads/dev"] } })
    }
    ## Docs - Private ##
    "docs-private" = {
      policies = {
        "s3" = {
          policy = data.aws_iam_policy_document.this_docs_private.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/docs:ref:refs/heads/main"] } })
    }
    ## Docs - Private ##
    "docs-public" = {
      policies = {
        "s3" = {
          policy = data.aws_iam_policy_document.this_docs_public.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/docs:ref:refs/heads/main"] } })
    }
    ## Case Site Deployments ##
    "cases" = {
      policies = {
        "s3" = {
          policy = data.aws_iam_policy_document.this_case_deployment.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-definitions:ref:refs/heads/main"] } })
    }
    ## Static Content ##
    "static" = {
      policies = {
        s3 = {
          policy = data.aws_iam_policy_document.this_static_deployment.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/casefunnel-static:ref:refs/heads/master"] } })
    }
    ## Case Site ECR ##
    "casesite-ecr" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_casesite_ecr.json
        }
        legacy = {
          policy = data.aws_iam_policy_document.this_casesite_ecr_legacy.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = [for b in local.casesite_release_branches : "repo:FinLegal/case-sites:ref:refs/heads/${b}"] } })
    }
    ## CaseFunnel ECR ##
    "casefunnel-ecr" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_casefunnel_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/casefunnel:ref:refs/heads/dev", "repo:FinLegal/casefunnel:ref:refs/heads/master", "repo:FinLegal/casefunnel:ref:refs/heads/release"] } })
    }
  }
}
