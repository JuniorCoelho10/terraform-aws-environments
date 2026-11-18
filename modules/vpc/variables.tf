variable "cidr_block" {
  description = "Faixa de endereços IP para a VPC"
  type        = string
}

variable "name" {
  description = "Nome da VPC"
  type        = string
}



variable "subnet_cidr_blocks" {
  description = "Faixa de endereços IP para a sub-rede"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zona de disponibilidade para a sub-rede"
  type        = list(string)

}