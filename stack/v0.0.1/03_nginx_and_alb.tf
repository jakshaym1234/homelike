
#-------------------------------------------------------------------------
#AUTO SCALING NGINX Server
#-------------------------------------------------------------------------
resource "aws_launch_configuration" "nginx" {
  name_prefix          = "ec2-nginx"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources_iam_profile.name
  key_name             = aws_key_pair.generated_key.key_name
  security_groups      = [aws_security_group.nginx.id]
  user_data            = <<-EOF
           #!/bin/bash
           sudo apt-get update
           sudo apt install -y software-properties-common
           sudo apt-add-repository --yes --update ppa:ansible/ansible
           sudo apt install -y ansible
           EOF
}
#-------------------------------------------------------------------------
#NGINX ASG
#-------------------------------------------------------------------------
resource "aws_autoscaling_group" "nginx" {
  name_prefix          = "nginx"
  desired_capacity     = 2
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.nginx["subnet-nginx1"].id, aws_subnet.nginx["subnet-nginx2"].id, aws_subnet.nginx["subnet-nginx3"].id]
  launch_configuration = aws_launch_configuration.nginx.name
  target_group_arns    = [aws_lb_target_group.alb_target.arn]
  tags = [
    {
      key                 = "Name"
      value               = "nginx"
      propagate_at_launch = true
    }
  ]
}
#-------------------------------------------------------------------------
#NGINX ALB
#-------------------------------------------------------------------------
resource "aws_lb" "alb_nginx" {
  name               = "alb-for-nginx"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.alb["subnet-alb1"].id, aws_subnet.alb["subnet-alb2"].id, aws_subnet.alb["subnet-alb3"].id]
  security_groups    = [aws_security_group.alb_nginx.id]
}
resource "aws_lb_target_group" "alb_target" {
  name     = "alb-target-for-nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.homelikevpc.id
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb_nginx.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.alb_target.id
    type             = "forward"
  }
}
#-----------------------------------------------------
#Ansible Server
#-----------------------------------------------------
resource "aws_instance" "ansible" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = aws_subnet.alb["subnet-alb1"].id
  vpc_security_group_ids      = [aws_security_group.alb_nginx.id]
  tags                        = merge({ Name = "ec2-ansible-server" }, var.tags)
}
#-----------------------------------------------------
#NGINX AUTOMATION
#-----------------------------------------------------
locals {
  path_info = {
    path = "https://s3.amazonaws.com/homelikeautomation/nginx"
  }
}

resource "aws_ssm_association" "nginx_automation" {
  depends_on       = [aws_autoscaling_group.nginx, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
  name             = "AWS-ApplyAnsiblePlaybooks"
  association_name = "nginxsetup"
  max_concurrency  = "50"
  max_errors       = "0"
  parameters = {
    SourceType          = "S3"
    SourceInfo          = jsonencode(local.path_info)
    InstallDependencies = "False"
    PlaybookFile        = "playbook.yml"
    ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
  }
  targets {
    key    = "tag:Name"
    values = ["nginx"]
  }
}

