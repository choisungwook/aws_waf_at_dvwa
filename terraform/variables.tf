variable "vpc_cidr" {
  description = "vpc_cidr"
  type        = string
}

variable "public-subnets" {
  description = "public subnet"
  type = map(object({
    az   = string
    cidr = string
    tags = map(string)
  }))
}
