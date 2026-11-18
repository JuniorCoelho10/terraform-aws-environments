variable "vpc_id" {
  type        = string
  description = "ID da VPC onde o grupo de segurança será criado"
}



variable "name" {
  type        = string
  description = "Nome do grupo de segurança"
}

variable "ingress_rules" {
  description = "Lista de regras de entrada do Security Group"

  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
}