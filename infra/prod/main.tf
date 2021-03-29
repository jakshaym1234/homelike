module "network_stack" {
  source = "../../stack/v0.0.1/"
  tags   = var.tags
  #VPC Details
  vpc_cidr = var.vpc_cidr
  #Subnet Variables
  subnet_nginx_details = var.subnet_nginx_details
  subnet_app_details   = var.subnet_app_details
  subnet_db_details    = var.subnet_db_details
  subnet_alb_details   = var.subnet_alb_details
  subnet_vpn_details   = var.subnet_vpn_details
  office_ips           = var.office_ips
}
output "pvtkey" {
  value = module.network_stack.pvtkey
}

