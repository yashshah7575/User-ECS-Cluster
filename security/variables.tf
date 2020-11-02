variable "name" {
    description = "ManageUser"
}

variable "environment" {
    description = "Dev"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
}

variable "vpc_id" {
  description = "Number of AZs to cover in a given AWS region"
}