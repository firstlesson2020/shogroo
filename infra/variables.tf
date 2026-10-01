variable "route53_zone_id" {
  description = "Optional existing Route53 hosted zone ID for DNS validation. If empty, ACM will use EMAIL validation."
  type        = string
  default     = ""
}

variable "aws_profile" {
  description = "AWS CLI profile to use for provider authentication"
  type        = string
  default     = "firstlesson"
}

