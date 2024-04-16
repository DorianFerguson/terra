variable "my_region" {
  description = "The best region for me"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Free tier eligible linux ami_id"
  type        = string
  default     = "ami-051f8a213df8bc089"
}
variable "instance" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}
variable "bucketname" {
  description = "s3 bucket name"
  type        = string
  default     = "jenkins-artifacts-39872"
}
variable "http_port" {
  description = "http access port"
  type        = number
  default     = 8080
}

variable "ssh_port" {
  description = "SSH access port"
  type        = number
  default     = 22
}

variable "my_Ip" {
  description = "IP address for SSH Access"
  type        = string
  default     = "45.85.145.89/32"
}

variable "key_name" {
  description = "Key Pair to use for SSH"
  type        = string
  default     = "Medium-Key"
}
