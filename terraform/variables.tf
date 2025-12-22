variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "aws_region" {
  description = "AWS Region for Route 53"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "cloud_run_url" {
  description = "Cloud Run service URL (optional, will be auto-generated if not provided)"
  type        = string
  default     = ""
}

variable "gcp_access_token" {
  description = "GCP access token (optional, for authentication)"
  type        = string
  default     = ""
  sensitive   = true
}
