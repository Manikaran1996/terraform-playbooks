resource "aws_security_group" "n8n-redis-security-group" {
  name        = "n8n-redis-security-group"
  description = "Security group for n8n-redis"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_n8n" {
  security_group_id            = aws_security_group.n8n-redis-security-group.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_security_group.n8n_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "redis_allow_to_all" {
  security_group_id = aws_security_group.n8n-redis-security-group.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_elasticache_serverless_cache" "n8n_redis" {
  engine = "redis"
  name   = "n8n-redis"
  cache_usage_limits {
    data_storage {
      maximum = 1
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 1000
    }
  }
  daily_snapshot_time      = "09:00"
  description              = "Redis for n8n"
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = [aws_security_group.n8n-redis-security-group.id]
  subnet_ids               = var.subnets
}
