terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region_ohio
}

module "wp_stack_module" {
  source  = "lauromazzoni/wp_do/aws"
  version = "1.0.0"
  availability_zone_ohio   = var.availability_zone_ohio
  availability_zone_ohio_2 = var.availability_zone_ohio_2
  availability_zone_ohio_3 = var.availability_zone_ohio_3
  wp_vm_count              = var.wp_vm_count
  subnets                  = var.subnets
  subnets2                 = var.subnets2
  subnets3                 = var.subnets3

  #sshkey_path = var.sshkey_path
  # vm_count = wp_vm_count
  # vm_ssh = aws_key_pair.lauro_user_ssh_key.public_key
}

# resource "aws_key_pair" "lauro_user_ssh_key" {
#   key_name   = "sshkey-test-lauro-user"
#   public_key = file("${var.sshkey_path}")
#   tags = {
#     Name = "sshkey-test-lauro-user"
#   }
# }