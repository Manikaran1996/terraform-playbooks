variable "env" {
  default = "prod"
}

variable "profile" {
  default = "personal-prod"
}

variable "region" {
  default = "ap-south-1"
}

variable "stream_name" {
  default = "metadata"
}

variable "shard_count" {
  default = 1
}

variable "stream_mode" {
  default = "PROVISIONED"
}

variable "retention_period" {
  default = 24
}

