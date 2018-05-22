variable "vpc_id" {}

variable "priv_subnet_ids" {
  type = "list"
}

variable "pub_subnet_id" {}

variable "env" {
  description = "Environments to Initialize"
  type        = "list"
  default     = ["Production", "Integration"]
}