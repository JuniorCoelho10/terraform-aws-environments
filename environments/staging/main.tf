module "vpc" {
  source = "../../modules/vpc"

  cidr_block = "10.1.0.0/16"
  subnet_cidr_blocks = [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]
  name = "staging-vpc"
}

module "ec2" {
  count  = 2
  source = "../../modules/ec2"

  ami_id             = "ami-0abcdef1234567890"
  instance_type      = "t3.small"
  subnet_id          = module.vpc.subnet_ids[count.index]
  name               = "staging-ec2-${count.index + 1}"
  security_group_ids = [module.ec2_security_group.security_group_id]

}

module "alb_security_group" {
  source = "../../modules/security_group"

  vpc_id = module.vpc.vpc_id
  name   = "staging-alb-sg"

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}


module "ec2_security_group" {
  source = "../../modules/security_group"

  vpc_id = module.vpc.vpc_id
  name   = "staging-ec2-sg"

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.alb_security_group.security_group_id]
    },

    {
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.alb_security_group.security_group_id]
    }
  ]
}


module "alb" {
  source = "../../modules/alb"

  name               = "staging-alb"
  subnet_ids         = module.vpc.subnet_ids
  security_group_ids = [module.alb_security_group.security_group_id]
  instance_ids       = module.ec2[*].instance_id
  vpc_id             = module.vpc.vpc_id
}