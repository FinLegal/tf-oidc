########################################
# GitHub OIDC
########################################

module "git" {
  source  = "finlegal.scalr.io/acc-v0od9n5ghtfveu0dj/oidc/aws"
  version = "1.1.5"

  oidc_provider_configuration = {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
  }
  provider_role_configuration = {
    ## Case Site Deployments ##
    "cases" = {
      policies = {
        "s3" = {
          policy = data.aws_iam_policy_document.this_case_deployment.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-definitions:ref:refs/heads/main"] } })
    }
    ## Case Site ECR ##
    "case-site-ecr" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_casesite_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = [for b in local.casesite_release_branches : "repo:FinLegal/case-sites:ref:refs/heads/${b}"] } })
    }
    ## Search Service ECR ##
    "search-service-ecr" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_search_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/svc-search:ref:refs/heads/main"] } })
    }
    ## Bootstrap Service ECR ##
    "case-site-definition-service-ecr" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_csdef_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/case-definition-service:ref:refs/heads/main"] } })
    }
    ## API ECR ##
    "api" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_api_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/casefunnel:ref:refs/heads/dev", "repo:FinLegal/casefunnel:ref:refs/heads/master", "repo:FinLegal/casefunnel:ref:refs/heads/release"] } })
    }
  }
}
