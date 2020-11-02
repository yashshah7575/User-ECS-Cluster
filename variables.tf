variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ca-central-1"
}

variable "az_count" {
  default     = "1"
  description = "Number of AZs to cover in a given AWS region"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  #default     = "719042170775.dkr.ecr.ca-central-1.amazonaws.com/helloworldyash:latest"
  default     = "adongy/hostname-docker:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "name" {
    default = "ManageUser"
}

variable "environment" {
    default = "Dev"
}

variable "ecs_task_role" {
  default = "ecs_task_role"
}

variable "ecs_task_execution_role" {
  default = "ecs_task_execution_role"
}

variable "cidr" {
  default = "172.17.0.0/16"
}