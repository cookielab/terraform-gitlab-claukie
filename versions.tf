terraform {
  required_version = ">= 1.4.0, < 2.0.0"
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 18.6.1"
    }
  }
}
