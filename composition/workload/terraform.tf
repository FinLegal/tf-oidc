terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    scalr = {
      source  = "Scalr/scalr"
      version = "~> 1.13"
    }
  }
  cloud {
    hostname     = "finlegal.scalr.io"
    organization = "env-v0ojirg3vo70j46ua"

    workspaces {
      name = "OIDC"
    }
  }
  required_version = "~> 1.8"
}