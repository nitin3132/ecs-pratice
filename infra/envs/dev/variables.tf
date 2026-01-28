variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "project" {
  type    = string
  default = "nitin-lab"
}

variable "env" {
  type    = string
  default = "dev"
}

# For public ALB restriction (your home IP /32)
variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR format, e.g. 99.99.99.99/32"
  default     = "0.0.0.0/0" # change to your IP later (recommended)
}

# Route53 zone name you already own
variable "zone_name" {
  type    = string
  default = "nitin3132.com"
}

# Record name for app (app.nitin3132.com)
variable "record_name" {
  type    = string
  default = "app"
}
