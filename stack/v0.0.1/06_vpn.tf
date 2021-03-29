resource "aws_instance" "openvpnserver" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  #user_data = file("../../stack/v0.0.1/template/openssh.sh")
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.vpn.id]
  subnet_id       = aws_subnet.vpn["vpn"].id
  tags            = merge({ Name = "openvpn-server" }, var.tags)
}
resource "random_password" "password" {
  length           = 8
  special          = true
  override_special = "_%@"
}
