variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
}

variable "ami_id" {
  description = "ID da AMI para a instância EC2"
  type        = string
}

variable "subnet_id" {
  description = "ID da sub-rede onde a instância EC2 será lançada"
  type        = string
}

variable "name" {
  description = "Nome da instância EC2"
  type        = string
}

variable "security_group_ids" {
  description = "IDs dos grupos de segurança associados à instância EC2"
  type        = list(string)
}