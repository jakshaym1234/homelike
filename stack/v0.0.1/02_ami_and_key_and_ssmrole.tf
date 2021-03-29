#GET AWS AMI for Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
#Generate KEY  
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#Store in AWS KEY Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "masterkey-homelike"
  public_key = tls_private_key.key.public_key_openssh
  tags       = var.tags
}
output "pvtkey" {
  value = tls_private_key.key.private_key_pem
}
#Instance Profile
resource "aws_iam_instance_profile" "resources_iam_profile" {
  name = "ec2_profile"
  role = aws_iam_role.resources_iam_role.name
}
#IAM Role
resource "aws_iam_role" "resources_iam_role" {
  name               = "ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
}
#POLICY Attachment
resource "aws_iam_role_policy_attachment" "resources_ssm_policy" {
  role       = aws_iam_role.resources_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "resources_s3read_policy" {
  role       = aws_iam_role.resources_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}