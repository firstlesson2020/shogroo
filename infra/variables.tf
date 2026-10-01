variable "route53_zone_id" {
  description = "Optional existing Route53 hosted zone ID for DNS validation. If empty, ACM will use EMAIL validation."
  type        = string
  default     = ""
}

# Local only: export AWS_PROFILE=firstlesson
# CI uses OIDC env credentials from GitHub Actions.

