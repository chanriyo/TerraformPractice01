output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

# パブリックサブネット*2に対するアプリケーションロードバランサー（セキュリティグループつける）
resource "aws_lb" "example" {
  name                       = "example"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false
  security_groups            = [module.http_sg.security_group_id]

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id,
  ]
}

# ALBのセキュリティグループはHTTPを全部許可
module "http_sg" {
  source      = "./modules/security_group"
  name        = "http-sg"
  vpc_id      = aws_vpc.example.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# ALBにはリスナーを作成
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これは『HTTP』です"
      status_code  = "200"
    }
  }
}

# ALBにはECS用のターゲットグループを作成
resource "aws_lb_target_group" "example" {
  name                 = "example"
  vpc_id               = aws_vpc.example.id
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.example]
}

# リスナーとターゲットグループの紐づけ
resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  condition {
    path_pattern {
      values = ["/app/*"]
    }
  }
}