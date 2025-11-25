provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket  = "mk-terraform-states"
    key     = "s3-buckets"
    region  = "ap-south-1"
    profile = "personal-prod"
    workspace_key_prefix = "practice/states"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

resource "aws_s3_bucket" "code_build_logs" {
  bucket = "code-build-${var.region}-${var.env}-logs"
  tags = {
    environment = "prod"
    owner       = "manikaran"
    stage       = "practice"
  }
}
