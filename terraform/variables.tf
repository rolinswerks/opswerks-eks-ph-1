
variable "public_subnet_ips" {
  type = list(string)
}

variable "private_subnet_ips" {
  type = list(string)
}

variable "database_subnet_ips" {
  type = list(string)
}

variable "db_subnet_group_name" {
  type = string
  default = null
}

variable "subnet_ids" {
  type = string
  default = null
}


variable "azs" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "profile" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "eks_instance_type" {
  type = string
}

variable "db_publicly_accessible" {
  type = bool
}

variable "worker_group_size" {
  type = number
}

variable "db_subnet_public" {
  type = bool
}

variable "eks_name" {
  type = string
}

