###################################
### Create Application Load Balancer
##################################

resource "aws_alb" "main_alb" {
  name            = "ecs-alb"
  subnets = var.public_subnet_id
  load_balancer_type = "application"
  security_groups = [var.security_group_ecs_task_id]
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

resource "aws_alb_target_group" "alb_tg" {
  name        = "tf-ecs-chat"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "https_forward" {
  load_balancer_arn = aws_alb.main_alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg.id
    type             = "forward"
  }
}


output "alb_target_group_id" {
  value = aws_alb_target_group.alb_tg.id
}

output "aws_alb_listener_appliation" {
  value = aws_alb_listener.https_forward
}