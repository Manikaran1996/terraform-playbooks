provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket               = "mk-terraform-states" # change to your bucket where you want to store the terraform state or remove it if you want it in your local
    key                  = "kinesis-streams"
    region               = "ap-south-1"
    profile              = "personal-prod"
    workspace_key_prefix = "practice/states"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

resource "aws_kinesis_stream" "stream" {
  name             = var.stream_name
  shard_count      = var.shard_count
  retention_period = var.retention_period
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = var.stream_mode
  }

  tags = {
    Environment = "prod"
  }
}
