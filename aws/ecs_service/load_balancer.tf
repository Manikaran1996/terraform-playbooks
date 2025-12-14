module "n8n_load_balancer" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "10.3.1"
  name                       = "n8n-load-balancer"
  load_balancer_type         = "application"
  vpc_id                     = var.vpc_id
  subnets                    = var.subnets
  enable_deletion_protection = false
  create                     = true
  security_group_ingress_rules = {
    all_http_ingress = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all_egress = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  listeners = {
    http_listener = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "n8n_target_group"
      }

    }
  }
  target_groups = {
    n8n_target_group = {
      name              = "n8n-target-group"
      port              = 5678
      protocol          = "HTTP"
      target_type       = "ip"
      create_attachment = false
      health_check = {
        path                = "/healthz"
        port                = 5678
        protocol            = "HTTP"
        interval            = 30
        timeout             = 10
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
      deregistration_delay = "30"
    }
  }
}
