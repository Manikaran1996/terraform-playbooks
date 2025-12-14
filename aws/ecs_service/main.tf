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
      version = "6.22.0"
    }
  }
}

# resource "aws_service_discovery_service" "n8n" {
#   name = "n8n"
#   namespace_id = "" # var.namespace_id
#   dns_config {
#     dns_records = [
#       {
#         ttl = 10
#         type = "A"
#       }
#     ]
#   }
#   health_check_config {
#     failure_threshold = 3
#     resource_records = [
#       {
#         value = "n8n"
#       }
#     ]
# }

resource "aws_ecs_task_definition" "n8n" {
  family = "n8n"
  container_definitions = jsonencode([
    {
      name      = "n8n"
      image     = "n8nio/n8n:latest"
      port      = 5678
      essential = true
      environment = [
        {
          name  = "GENERIC_TIMEZONE"
          value = var.generic_timezone
        },
        {
          name  = "TZ"
          value = var.tz
        },
        {
          name  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
          value = var.n8n_enforce_settings_file_permissions
        },
        {
          name  = "N8N_RUNNERS_ENABLED"
          value = var.n8n_runners_enabled
        },
        {
          name  = "N8N_SECURE_COOKIE"
          value = var.n8n_secure_cookie
        },
        {
          name  = "N8N_LISTEN_ADDRESS"
          value = "0.0.0.0"
        },
        {
          name  = "EXECUTIONS_MODE"
          value = "queue"
        },
        {
          name  = "QUEUE_BULL_REDIS_HOST"
          value = aws_elasticache_serverless_cache.n8n_redis.endpoint[0].address
        },
        {
          "name"  = "N8N_PROTOCOL"
          "value" = "http"
        },
        {
          "name"  = "N8N_QUEUE_BULL_REDIS_SSL"
          "value" = "true"
        },
        {
          "name"  = "N8N_HOST"
          "value" = module.n8n_load_balancer.dns_name
        },
        {
          "name"  = "N8N_PROCESS"
          "value" = "main"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/n8n"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 5678
          hostPort      = 5678
          protocol      = "tcp"
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  tags = {
    Environment = "prod"
    Owner       = "manikaran"
  }

  execution_role_arn = aws_iam_role.n8n_ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.n8n_ecs_task_role.arn
}

resource "aws_ecs_service" "n8n" {
  name            = "n8n"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.n8n.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.n8n_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.n8n_load_balancer.target_groups["n8n_target_group"].arn
    container_name   = "n8n"
    container_port   = 5678
  }
  enable_execute_command = true
  tags = {
    Environment = "prod"
    Owner       = "manikaran"
  }
}



resource "aws_ecs_task_definition" "n8n-worker" {
  family = "n8n-worker"
  container_definitions = jsonencode([
    {
      name      = "n8n-worker"
      image     = "n8nio/n8n:latest"
      port      = 5678
      essential = true
      command   = ["n8n", "worker"]
      environment = [
        {
          name  = "GENERIC_TIMEZONE"
          value = var.generic_timezone
        },
        {
          name  = "TZ"
          value = var.tz
        },
        {
          name  = "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS"
          value = var.n8n_enforce_settings_file_permissions
        },
        {
          name  = "N8N_RUNNERS_ENABLED"
          value = var.n8n_runners_enabled
        },
        {
          name  = "N8N_SECURE_COOKIE"
          value = var.n8n_secure_cookie
        },
        {
          name  = "N8N_HOST"
          value = module.n8n_load_balancer.dns_name
        },
        {
          name  = "EXECUTIONS_MODE"
          value = "queue"
        },
        {
          name  = "QUEUE_BULL_REDIS_HOST"
          value = aws_elasticache_serverless_cache.n8n_redis.endpoint[0].address
        },
        {
          "name"  = "N8N_QUEUE_BULL_REDIS_SSL"
          "value" = "true"
        },
        {
          "name"  = "N8N_PROCESS"
          "value" = "worker"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/n8n"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  tags = {
    Environment = "prod"
    Owner       = "manikaran"
  }

  execution_role_arn = aws_iam_role.n8n_ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.n8n_ecs_task_role.arn
}

resource "aws_ecs_service" "n8n-worker" {
  name            = "n8n-worker"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.n8n-worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.n8n_security_group.id]
    assign_public_ip = true
  }

  enable_execute_command = true
  tags = {
    Environment = "prod"
    Owner       = "manikaran"
  }
}
