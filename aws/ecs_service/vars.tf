variable "env" {
  default = "prod"
}

variable "profile" {
  default = "personal-prod"
}

variable "region" {
  default = "ap-south-1"
}

variable "ecs_cluster_id" {
  default     = "demo"
  description = "ECS cluster ID"
}

variable "vpc_id" {
  default     = "vpc-69e92e02"
  description = "VPC ID"
}

variable "subnets" {
  default     = ["subnet-e0ba568b", "subnet-19feac55"]
  description = "Subnets"
}

variable "generic_timezone" {
  default     = "Asia/Kolkata"
  description = "Generic timezone"
}

variable "tz" {
  default     = "Asia/Kolkata"
  description = "Timezone"
}

variable "n8n_enforce_settings_file_permissions" {
  default     = "true"
  description = "Enforce settings file permissions"
}

variable "n8n_runners_enabled" {
  default     = "true"
  description = "Runners enabled"
}

variable "n8n_secure_cookie" {
  default     = "false"
  description = "Secure cookie"
}

variable "n8n_encryption_key" {
  default     = "df1b1305d14be3b99bcc5977b4ed5c8f4bb5dc943ce2ba3425c84fe3d7e4b62b"
  description = "Encryption key"
}
