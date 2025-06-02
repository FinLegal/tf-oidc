## State removals ready for retirement
removed {
  from = module.git.aws_iam_role.this["search-service-ecr"]
}

removed {
  from = module.git.aws_iam_openid_connect_provider.this
}

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
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.core_ecr_branches } })
    }
    ## UserJobs ECR ##
    "user-jobs" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_userjobs_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.core_ecr_branches } })
    }
    ## SystemJobs ECR ##
    "system-jobs" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_systemjobs_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.core_ecr_branches } })
    }
    ## Dashboard ECR ##
    "dashboard" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_dashboard_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.core_ecr_branches } })
    }
    ## Admin ECR ##
    "admin" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_admin_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = local.core_ecr_branches } })
    }
    ## Background Jobs ECR ##
    "background-jobs" = {
      policies = {
        ecr = {
          policy = data.aws_iam_policy_document.this_background_jobs_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/svc-background-jobs:ref:refs/heads/master"] } })
    }
    ## AWS Native ##
    "aws-native" = {
      policies = {
        claimstatus_ecr = {
          policy = data.aws_iam_policy_document.this_claimstatus_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/aws-native:ref:refs/heads/main"] } })
    }
    ## Intelligent Automation ##
    "intelligent-automation" = {
      policies = {
        emailclassifier_ecr = {
          policy = data.aws_iam_policy_document.this_emailclassifier_ecr.json
        }
      }
      conditions = merge(local.aws_github_audience, { "repo" = { test = "StringEquals", variable = "token.actions.githubusercontent.com:sub", values = ["repo:FinLegal/agent-email-classifier:ref:refs/heads/main"] } })
    }
  }
}
