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
  required_version = "~> 1.8"
}