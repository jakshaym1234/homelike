#-------------------------------------------------------------------------
#Launch Config for APP SERVERS
#-------------------------------------------------------------------------
resource "aws_launch_configuration" "app" {
  name_prefix          = "ec2-app"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources_iam_profile.name
  key_name             = aws_key_pair.generated_key.key_name
  security_groups      = [aws_security_group.app.id]
  user_data            = <<-EOF
            #!/bin/bash
            sudo apt update
            sudo apt install -y nodejs
            sudo apt install -y npm
            sudo apt install -y software-properties-common
            sudo apt-add-repository --yes --update ppa:ansible/ansible
            sudo apt install -y ansible
            EOF
}
#-------------------------------------------------------------------------
#APP SERVERS ASG
#-------------------------------------------------------------------------
resource "aws_autoscaling_group" "app" {
  name_prefix          = "app"
  desired_capacity     = 2
  max_size             = 3
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.app["subnet-app1"].id, aws_subnet.app["subnet-app2"].id, aws_subnet.app["subnet-app3"].id]
  launch_configuration = aws_launch_configuration.app.name
  load_balancers       = [aws_elb.app_elb.name]
  tags = [
    {
      key                 = "Name"
      value               = "app"
      propagate_at_launch = true
    }
  ]
}
#-------------------------------------------------------------------------
#APP SERVER ELB
#-------------------------------------------------------------------------
resource "aws_elb" "app_elb" {
  name            = "app-elb-classic"
  security_groups = [aws_security_group.app.id]
  internal        = true
  subnets         = [aws_subnet.app["subnet-app1"].id, aws_subnet.app["subnet-app2"].id, aws_subnet.app["subnet-app3"].id]
  listener {
    lb_port           = 3000
    lb_protocol       = "tcp"
    instance_port     = "3000"
    instance_protocol = "tcp"
  }
}