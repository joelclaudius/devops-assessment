variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group" {
  description = "Security group for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair for SSH access"
  type        = string
}
