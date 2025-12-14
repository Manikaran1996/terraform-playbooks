resource "aws_security_group" "n8n_security_group" {
  name        = "n8n-security-group"
  description = "Security group for n8n"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_load_balancer" {
  security_group_id            = aws_security_group.n8n_security_group.id
  ip_protocol                  = "tcp"
  from_port                    = 5678
  to_port                      = 5678
  referenced_security_group_id = module.n8n_load_balancer.security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_all" {
  security_group_id = aws_security_group.n8n_security_group.id
  ip_protocol       = "tcp"
  from_port         = 5678
  to_port           = 5678
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_to_all" {
  security_group_id = aws_security_group.n8n_security_group.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
