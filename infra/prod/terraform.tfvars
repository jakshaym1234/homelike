vpc_cidr = "10.0.0.0/16"
subnet_nginx_details = {
  subnet-nginx1 = {
    cidr = "10.0.0.0/21"
    az   = "eu-central-1a"
  },
  subnet-nginx2 = {
    cidr = "10.0.8.0/21"
    az   = "eu-central-1b"
  },
  subnet-nginx3 = {
    cidr = "10.0.16.0/21"
    az   = "eu-central-1c"
  }
}
subnet_app_details = {
  subnet-app1 = {
    cidr = "10.0.24.0/21"
    az   = "eu-central-1a"
  },
  subnet-app2 = {
    cidr = "10.0.32.0/21"
    az   = "eu-central-1b"
  },
  subnet-app3 = {
    cidr = "10.0.40.0/21"
    az   = "eu-central-1c"
  }
}
subnet_db_details = {
  subnet-db1 = {
    cidr = "10.0.48.0/21"
    az   = "eu-central-1a"
  },
  subnet-db2 = {
    cidr = "10.0.56.0/21"
    az   = "eu-central-1b"
  },
  subnet-db3 = {
    cidr = "10.0.64.0/21"
    az   = "eu-central-1c"
  }
}
subnet_alb_details = {
  subnet-alb1 = {
    cidr = "10.0.72.0/21"
    az   = "eu-central-1a"
  },
  subnet-alb2 = {
    cidr = "10.0.80.0/21"
    az   = "eu-central-1b"
  },
  subnet-alb3 = {
    cidr = "10.0.88.0/21"
    az   = "eu-central-1c"
  }
}

subnet_vpn_details = {
  vpn = {
    cidr = "10.0.96.0/21"
    az   = "eu-central-1a"
  }
}

office_ips = "0.0.0.0/0"