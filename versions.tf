terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = ">= 6.6.0"
    }
    null = {
      source = "hashicorp/null"
      version = ">= 3.2.4"
    }
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.97.0"
    }
  }
}
