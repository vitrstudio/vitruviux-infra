variable "certificate_arn" {
  description = "ACM Certificate ARN for CloudFront"
  type        = string
}

variable "domain_name" {
  description = "Domain name (e.g. domain.com)"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "s3_domain_name" {
    description = "S3 bucket domain name for CloudFront origin"
    type        = string
}

variable "oac_id" {
  description = "Origin Access Control ID for the S3 bucket"
  type        = string
}

variable "s3_bucket_id" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}
