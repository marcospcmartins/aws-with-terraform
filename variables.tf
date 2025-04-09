variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Enviromment"
  type        = string
  default     = "dev"
}

variable "stage" {
  description = "Stage"
  type        = string
  default     = "development"
}

variable "arn_hash" {
  description = "Arn Hash"
  type        = number
  default     = 123456789012
}

variable "api_gateway_name" {
  description = "API Gateway Name"
  type        = string
  default     = "api-gateway"
}

variable "custom_dns" {
  description = "Custom DNS"
  type        = string
  default     = "api.example.com"
}
