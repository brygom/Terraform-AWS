# Terraform-AWS
Multi-tier architecture postgreSQL deployment on AWS using ansible, packer and terraform.

Base OS AMI : Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-835b4efa
File information:
	1: ansible.yml: Ansible script to 
        •	install postgresql-9.5
        •	Change listening port to 9988
        •	Create database: pex_db
        •	Create 3 users “test” “24223” “parabola”
  2: template.json: Packer template to
        •	Install python2.7
        •	Install ansible2.0
        •	Build an AWS AMI and run the ansible playbook to install and configure postgresql server
        •	Repack the configuration onto new AWS AMI
  3: main.tf : Terraform configuration file to
        •	Manage credentials required for building AWS resources
        •	Module to build VPC
        •	Module to build Bastion host for public access
        •	Security groups to configure for bastion host
        •	Security groups to configure for private instances
        •	Resource to build postgresql private instances
        
Required installations:
  1. Packer
        •	Wget https://releases.hashicorp.com/packer/1.0.3/packer_1.0.3_freebsd_amd64.zip
        •	Unzip and mv /usr/local
        •	Set linux environment path
        •	Packer validate template.json # To validate the template
            o	https://jsonlint.com/ to validate the json format.
        •	Packer build template.json (Executes ansible and builds an AMI stored in AWS account-AMI’s owned by me)
  2. Terraform
        •	Wget https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip
        •	Mv /opt/terraform and unzip
        •	Set linux environment path
        •	Terraform import aws_key_pair.<key_name> <key_name> # for existing key pair to avoid key conflict
        •	Terraform get # To get all the module dependencies
        •	Terraform plan # to view the infrastructure to be built
        •	Terraform apply # to apply the template and build the infrastructure
        •	Terraform destroy # to tear down the infrastructure.
  3. SSH forwarding to access private instances.
        •	Ssh-add –K yourpemfile.pem
        •	Ssh –A Ubuntu@Bastion IP
        •	Ssh Ubuntu@instance_private IP

