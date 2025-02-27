resource "aws_lb" "adobe_flask_alb" {
  name               = "adobe-flask-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.subnet_id_b, var.subnet_id_c]
}

resource "aws_lb_target_group" "adobe_flask_tg" {
  name        = "adobe-flask-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "adobe_flask_alb_listener" {
  load_balancer_arn = aws_lb.adobe_flask_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adobe_flask_tg.arn
  }
}