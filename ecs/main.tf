##########
### ECS
#########
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "tf-ecs-cluster"
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  #task_role_arn            = aws_iam_role.app_role.arn

container_definitions =jsonencode(
[
   {
      "cpu": 256,
      #var.fargate_cpu,
      "image": var.app_image,
      "memory": 512,
      #var.fargate_memory,
      "name":"app",
      "networkMode":"awsvpc",
      "portMappings":[
         {
            "containerPort": var.app_port,
            "hostPort": var.app_port
         }
      ]
   }
])
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "tf-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.security_group_ecs_task_id]
    subnets         = var.private_subnet_id
  }

  load_balancer {
    target_group_arn = var.alb_target_group_id
    container_name   = "app"
    container_port   = var.app_port
  }
  
  depends_on = [
    var.aws_alb_listener_appliation
  ]

  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}