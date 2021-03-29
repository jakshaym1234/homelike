#-------------------------------------------------------------------------
#DB1#
#-------------------------------------------------------------------------
resource "aws_network_interface" "db1nwinterface" {
  subnet_id       = aws_subnet.db["subnet-db1"].id
  private_ips     = ["10.0.48.5"]
  tags            = var.tags
  security_groups = [aws_security_group.db.id]
}

resource "aws_instance" "db1" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources_iam_profile.name
  key_name             = aws_key_pair.generated_key.key_name
  network_interface {
    network_interface_id = aws_network_interface.db1nwinterface.id
    device_index         = 0
  }
  user_data = file("../../stack/v0.0.1/template/inventory.sh")
  tags      = merge({ Name = "ec2-db1-leader", Type = "DB" }, var.tags)
}
#MONGO AUTOMATION
locals {
  mongopath_info = {
    path = "https://s3.amazonaws.com/homelikeautomation/mongodb/"
  }
}
# resource "aws_ssm_association" "init" {
#   depends_on       = [aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "01_init"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/01_init.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Type"
#     values = ["DB"]
#   }
# }
# resource "aws_ssm_association" "install_mongod_wt" {
#   depends_on       = [aws_ssm_association.init, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "02_install_mongod_wt"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/02_install_mongod_wt.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#     Verbose = "-v"
#   }
#   targets {
#     key    = "tag:Type"
#     values = ["DB"]
#   }
# }
# resource "aws_ssm_association" "create_admin_users" {
#   depends_on       = [aws_ssm_association.install_mongod_wt, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "03_create_admin_users"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/03_create_admin_users.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Name"
#     values = ["ec2-db1-leader"]
#   }
# }
# resource "aws_ssm_association" "set_key_files" {
#   depends_on       = [aws_ssm_association.create_admin_users, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "04_set_key_files"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/04_set_key_files.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Type"
#     values = ["DB"]
#   }
# }
# resource "aws_ssm_association" "restart_mongod_primary" {
#   depends_on       = [aws_ssm_association.set_key_files, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "05_restart_mongod_primary"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/05_restart_mongod_primary.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Name"
#     values = ["ec2-db1-leader"]
#   }
# }
# resource "aws_ssm_association" "restart_mongod_secondary" {
#   depends_on       = [aws_ssm_association.restart_mongod_primary, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "06_restart_mongod_secondary"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/06_restart_mongod_secondary.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Name"
#     values = ["ec2-db2-secondary"]
#   }
# }
# resource "aws_ssm_association" "restart_mongod_arb" {
#   depends_on       = [aws_ssm_association.restart_mongod_secondary, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "07_restart_mongod_arb"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/07_restart_mongod_arb.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Name"
#     values = ["ec2-db3-arbiter"]
#   }
# }
# resource "aws_ssm_association" "finalstep" {
#   depends_on       = [aws_ssm_association.restart_mongod_arb, aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "08_finalstep"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo/08_finalstep.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Name"
#     values = ["ec2-db1-leader"]
#   }
# }
# resource "aws_ssm_association" "onestep" {
#   depends_on       = [aws_instance.db1, aws_instance.db2, aws_instance.db3, aws_iam_role_policy_attachment.resources_s3read_policy, aws_iam_role_policy_attachment.resources_ssm_policy]
#   name             = "AWS-ApplyAnsiblePlaybooks"
#   association_name = "onestep"
#   max_concurrency  = "50"
#   max_errors       = "0"
#   parameters = {
#     SourceType          = "S3"
#     SourceInfo          = jsonencode(local.mongopath_info)
#     InstallDependencies = "False"
#     PlaybookFile        = "mongo.yml"
#     ExtraVariables      = "ansible_python_interpreter=/usr/bin/python"
#   }
#   targets {
#     key    = "tag:Name"
#     values = ["ec2-db1-leader"]
#   }
# }
#-------------------------------------------------------------------------
#DB2
#-------------------------------------------------------------------------
resource "aws_network_interface" "db2nwinterface" {
  subnet_id       = aws_subnet.db["subnet-db2"].id
  private_ips     = ["10.0.56.5"]
  tags            = var.tags
  security_groups = [aws_security_group.db.id]
}
resource "aws_instance" "db2" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources_iam_profile.name
  key_name             = aws_key_pair.generated_key.key_name
  network_interface {
    network_interface_id = aws_network_interface.db2nwinterface.id
    device_index         = 0
  }
  user_data = file("../../stack/v0.0.1/template/inventory.sh")
  tags      = merge({ Name = "ec2-db2-secondary", Type = "DB" }, var.tags)
}
#-------------------------------------------------------------------------
#DB3
#-------------------------------------------------------------------------
resource "aws_network_interface" "db3nwinterface" {
  subnet_id       = aws_subnet.db["subnet-db3"].id
  private_ips     = ["10.0.64.5"]
  tags            = var.tags
  security_groups = [aws_security_group.db.id]
}
resource "aws_instance" "db3" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.resources_iam_profile.name
  key_name             = aws_key_pair.generated_key.key_name
  network_interface {
    network_interface_id = aws_network_interface.db3nwinterface.id
    device_index         = 0
  }
  user_data = file("../../stack/v0.0.1/template/inventory.sh")
  tags      = merge({ Name = "ec2-db3-arbiter", Type = "DB" }, var.tags)
}


#template

data "template_file" "init" {
  template = file("../../stack/v0.0.1/template/inventory.sh")
}