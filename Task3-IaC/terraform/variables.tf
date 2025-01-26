variable "key_name" {
  description = "Name of the existing AWS key pair for SSH access"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}
