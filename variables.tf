variable "region_ohio" {
  default     = "us-east-2"
  type        = string
  description = "value of region Ohio"
}

variable "availability_zone_ohio"{
  type = string
  default = "us-east-2a"
  description = "value of availability zone"
}

variable "availability_zone_ohio_2"{
  type = string
  default = "us-east-2b"
  description = "value of availability zone"
}

variable "availability_zone_ohio_3"{
  type = string
  default = "us-east-2c"
  description = "value of availability zone"
}

variable "subnets" {
  default = "10.0.1.0/24"
}

variable "subnets2" {
  default = "10.0.4.0/24"
}

variable "subnets3" {
  default = "10.0.7.0/24"
}

variable "wp_vm_count" {
  type        = number
  default     = 2
  description = "Número de máquinas para o wordpress"

  validation {
    condition     = var.wp_vm_count > 1
    error_message = "Número de máquinas deve ser maior que 1."
  }
}