# AWS EC2

Code Structure:

image.png
you would run terraform init plan apply inside infra/prod where i have referenced a stack locally to make it easy to replicate across prod, test, dev env.

image.png
Network created:

3* public subnets for ALB - 1 for each AZ
3* private subnet for NGINX - 1 for each AZ
3* private subnet for APP server - 1 for each AZ
3* private subnet for DB server - 1 for server in each AZ
IGW for routes to Internet in Public Subnets
NAT GW for routes to Internet in Private Subnets

Now to points in the assignment:

1.  VPN Server: EC2 box with Public IPs secured with access only from office IPs(i have put it as 0.0.0.0/0) in the code but can be changed to any IP CIDR.
image.png
image.png
2.   Application Load Balancer(Internet Facing) for NGINX servers:
image.png
  
image.png
3.  NGINX server ○ Ubuntu server with installed nginx ○ Part of “Auto scaling group” (min: 2, max:2)
image.png
Install of Nginx was done using SSM and Ansible Playbook(playbook in attached ZIP)
image.png
image.png
4.  Classic Load Balancer for App Server(Internal Facing)
image.png
5.  APP server ○ Ubuntu server with installed node.js ○ Part of “Auto scaling group” (min: 2, max:3)
image.png
node.js and npm installed using EC2 user data but 
image.png
6.  3 DB servers ○ Servers are available in 3 different availability zones ○ MongoDB replica set ○ Each server has a static IP address ○ Only accessible from APP servers and via VPN
image.png
Each server has static IP e.g
image.png
Access from VPN and APP
  ingress {
    description = "SSH from VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_vpn_details.vpn.cidr]
  }
7. SSH access to all servers is only available with an SSH key (don't forget to add the ssh key to the repository)   
image.png
I did not find keeping the key in repo a good practice from security point of view. instead i have defined a TF output in the stack which can be accessed like this:
image.png
All EC2 instances and ASG Launch Config use this AWS KEY PAIR.
image.png
Req:
All infra deployed with TF-Done
TF 13:
image.png
Deployed in Frankfurt:
image.png
Maintained with Ansible. Yes
