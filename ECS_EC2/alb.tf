#in this template we are creating aws application laadbalancer and target group and alb http listener

resource "aws_alb" "alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  internal           = false
  security_groups    = [aws_security_group.alb-sg.id]
}

resource "aws_alb_target_group" "alb-tg" {
  name        = var.alb_tg_name
  port        = 80 # Docker container port exposed, e.g 8080,5000,etc
  protocol    = "HTTP"
  target_type = "instance" # For Fargate it must be ip, for EC2 it can be instance
  vpc_id      = aws_vpc.my-vpc.id

  health_check { # Advance properties
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
    interval            = 30
  }
}

#redirecting all incomming traffic from ALB to the target group
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.app_port
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #enable above 2 if you are using HTTPS listner and change protocal from HTTPS to HTTPS
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-tg.arn
  }
}
