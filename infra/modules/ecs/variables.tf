variable "name" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "container_image" { type = string }
variable "container_port" { type = number, default = 8080 }

variable "tags" { type = map(string), default = {} }
