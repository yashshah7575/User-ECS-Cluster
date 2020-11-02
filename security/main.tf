
#########################
### Create Security Groups
#########################

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "sg_ecs_lb" {
  name        = "ecs-alb-sg"
  description = "controls access to the Application Load Balancer (ALB)"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "sg_ecs_tasks" {
  name        = "ecs-tasks-lb"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.sg_ecs_lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}


############
#####IAM
###########
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


output security_group_ecs_task_id {
    value = aws_security_group.sg_ecs_tasks.id
}

output ecs_task_execution_role_arn {
    value = aws_iam_role.ecs_task_execution_role.arn
}