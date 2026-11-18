module "vpc" {
  source = "../../modules/vpc"

  cidr_block         = "10.0.0.0/16"
  subnet_cidr_blocks = ["10.0.1.0/24"]
  availability_zones = ["us-east-1a"]
  name               = "dev-vpc"
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id             = "ami-0abcdef1234567890"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.subnet_ids[0]
  name               = "dev-ec2"
  security_group_ids = [module.security_group.security_group_id]
}

module "security_group" {
  source = "../../modules/security_group"

  vpc_id = module.vpc.vpc_id
  name   = "dev-sg"

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = [var.ssh_cidr]
      security_groups = []
    }
  ]

}