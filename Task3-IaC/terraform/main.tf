# Create VPC and networking
module "vpc" {
  source = "./modules/vpc"
}

# Create Security Group
module "security_group" {
  source       = "./modules/security_group"
  vpc_id       = module.vpc.vpc_id
}

# Deploy EC2 Instance
module "ec2" {
  source         = "./modules/ec2"
  subnet_id      = module.vpc.public_subnet_id
  security_group = module.security_group.security_group_id
  key_name       = var.key_name
}
