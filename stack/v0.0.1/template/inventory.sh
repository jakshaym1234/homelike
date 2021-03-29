#!/bin/bash
sudo apt-get update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
sudo sh -c "echo '[primary]' > /etc/ansible/hosts"
sudo sh -c "echo '10.0.48.5' >> /etc/ansible/hosts"
sudo sh -c "echo '[secondary]' >> /etc/ansible/hosts"
sudo sh -c "echo '10.0.56.5' >> /etc/ansible/hosts"
sudo sh -c "echo '[arbiter]' >> /etc/ansible/hosts"
sudo sh -c "echo '10.0.64.5' >> /etc/ansible/hosts"
sudo sh -c "echo '[primary:vars]' >> /etc/ansible/hosts"
sudo sh -c "echo 'db_user_admin_password=ADMINPASSWORD' >> /etc/ansible/hosts"
sudo sh -c "echo 'db_root_admin_password=ROOTPASSWORD' >> /etc/ansible/hosts"
sudo sh -c "echo 'db_name=DBNAME' >> /etc/ansible/hosts"
sudo sh -c "echo 'db_user_name=DBUSERNAME' >> /etc/ansible/hosts"
sudo sh -c "echo 'db_user_password=DBUSERPASS' >> /etc/ansible/hosts"