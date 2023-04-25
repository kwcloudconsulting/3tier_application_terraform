# Create a target group
resource "aws_lb_target_group" "alb_target_group" {
  name_prefix = "tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    interval          = 30
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

# Create an ALB
resource "aws_lb" "application_load_balancer" {
  name                = "my-alb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [var.alb_security_group_id]
  subnets             = [var.public_subnet_az1_id, var.public_subnet_az2_id]
}

# Create a listener on port 80 with a redirect action
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# Create a listener on port 443 with a forward action
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
  }
}



