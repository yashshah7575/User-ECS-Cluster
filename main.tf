provider "aws" {
  region     = var.aws_region
}

module "vpc" {
  source             = "./vpc"
  name = var.name
  environment = var.environment
  app_port = var.app_port
  az_count = var.az_count
  cidr = var.cidr
}


module "security" {
  source         = "./security"
  name = var.name
  environment = var.environment
  app_port = var.app_port
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source     = "./alb"
  name = var.name
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  security_group_ecs_task_id = module.security.security_group_ecs_task_id
}

module "ecs" {
  source    = "./ecs"
  name = var.name
  environment = var.environment
  fargate_memory = var.fargate_memory
  fargate_cpu = var.fargate_cpu
  app_port = var.app_port
  app_image = var.app_image
  app_count = var.app_count
  private_subnet_id = module.vpc.private_subnet_id
  alb_target_group_id = module.alb.alb_target_group_id
  security_group_ecs_task_id = module.security.security_group_ecs_task_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  aws_alb_listener_appliation = module.alb.aws_alb_listener_appliation
}