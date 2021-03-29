#Common Vars
variable "tags" {
  type = map(any)
  default = {
    "Env"   = "Prod",
    "Owner" = "HomeLike"
  }
  description = "Tags to be applied to resources"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR of VPC"
}

#Subnet VARS
variable "subnet_nginx_details" {
  type        = map(any)
  default     = {}
  description = "Details of all Subnets in the VPC Name, CIDR, AZ"
}
variable "subnet_app_details" {
  type        = map(any)
  default     = {}
  description = "Details of all Subnets in the VPC Name, CIDR, AZ"
}
variable "subnet_db_details" {
  type        = map(any)
  default     = {}
  description = "Details of all Subnets in the VPC Name, CIDR, AZ"
}
variable "subnet_alb_details" {
  type        = map(any)
  default     = {}
  description = "Details of all Subnets in the VPC Name, CIDR, AZ"
}
variable "subnet_vpn_details" {
  type        = map(any)
  default     = {}
  description = "Details of all Subnets in the VPC Name, CIDR, AZ"
}

variable "office_ips" {
  description = "Details of OFFICE IPS"
}