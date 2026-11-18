variable "name" {
  description = "Nome do Application Load Balancer"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das sub-redes onde o ALB será criado"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs dos grupos de segurança associados ao ALB"
  type        = list(string)
}

variable "internal" {
  description = "Indica se o ALB é interno (true) ou externo (false)"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID da VPC para o target group do ALB"
  type        = string
}

variable "instance_ids" {
  description = "IDs das instâncias EC2 para o target group do ALB"
  type        = list(string)
}

