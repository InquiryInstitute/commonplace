terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Google Cloud Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# AWS Provider for Route 53
provider "aws" {
  region = var.aws_region
}

# Cloud SQL MySQL Instance
resource "google_sql_database_instance" "ghost_db" {
  name             = "ghost-db-instance"
  database_version = "MYSQL_8_0"
  region           = var.gcp_region

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_size         = 20
    disk_autoresize   = true

    backup_configuration {
      enabled            = true
      start_time         = "03:00"
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.ghost_vpc.id
    }
  }

  deletion_protection = false
}

# Cloud SQL Database
resource "google_sql_database" "ghost" {
  name     = "ghost"
  instance = google_sql_database_instance.ghost_db.name
}

# Cloud SQL User
resource "google_sql_user" "ghost" {
  name     = "ghost"
  instance = google_sql_database_instance.ghost_db.name
  password = var.db_password
}

# VPC Network
resource "google_compute_network" "ghost_vpc" {
  name                    = "ghost-vpc"
  auto_create_subnetworks = false
}

# VPC Subnet
resource "google_compute_subnetwork" "ghost_subnet" {
  name          = "ghost-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.ghost_vpc.id
}

# VPC Connector for Cloud Run
resource "google_vpc_access_connector" "ghost_connector" {
  name          = "ghost-connector"
  region        = var.gcp_region
  network       = google_compute_network.ghost_vpc.name
  ip_cidr_range = "10.8.0.0/28"
  machine_type  = "e2-micro"
  min_instances  = 2
  max_instances  = 3
}

# Cloud Storage Bucket for Ghost content
resource "google_storage_bucket" "ghost_content" {
  name          = "${var.gcp_project_id}-ghost-content"
  location      = var.gcp_region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Service Account for Ghost
resource "google_service_account" "ghost" {
  account_id   = "ghost-sa"
  display_name = "Ghost Service Account"
}

# Grant permissions to service account
resource "google_project_iam_member" "ghost_storage" {
  project = var.gcp_project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.ghost.email}"
}

# Cloud Run Service (will be deployed via Cloud Build)
# This is a placeholder - actual deployment happens via Cloud Build
resource "google_cloud_run_service" "ghost" {
  name     = "ghost"
  location  = var.gcp_region

  template {
    spec {
      service_account_name = google_service_account.ghost.email
      containers {
        image = "gcr.io/${var.gcp_project_id}/ghost:latest"
        
        ports {
          container_port = 2368
        }

        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.ghost_db.private_ip_address
        }

        env {
          name  = "DB_PORT"
          value = "3306"
        }

        env {
          name  = "DB_USER"
          value = google_sql_user.ghost.name
        }

        env {
          name  = "DB_NAME"
          value = google_sql_database.ghost.name
        }

        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = "db-password"
              key  = "latest"
            }
          }
        }

        env {
          name = "GCS_BUCKET"
          value = google_storage_bucket.ghost_content.name
        }

        env {
          name = "GCP_PROJECT_ID"
          value = var.gcp_project_id
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.ghost_db.connection_name
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.ghost_connector.name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM policy for Cloud Run
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.ghost.name
  location = google_cloud_run_service.ghost.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Secret Manager secrets
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "mail_user" {
  secret_id = "mail-user"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "mail_password" {
  secret_id = "mail-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "gcs_keyfile" {
  secret_id = "gcs-keyfile"
  replication {
    auto {}
  }
}

# AWS Route 53 Hosted Zone
resource "aws_route53_zone" "inquiry_institute" {
  name = "inquiry.institute"
}

# Route 53 Record for Ghost
# Note: This will be updated after Cloud Run deployment
# The Cloud Run URL format is: https://ghost-XXXXX-uc.a.run.app
# You may need to update this manually or use a data source after deployment
resource "aws_route53_record" "commonplace" {
  zone_id = aws_route53_zone.inquiry_institute.zone_id
  name    = "commonplace.inquiry.institute"
  type    = "CNAME"
  ttl     = 300
  # This will be set after Cloud Run service is deployed
  # Use: terraform apply -var="cloud_run_url=<your-cloud-run-url>"
  records = [var.cloud_run_url != "" ? var.cloud_run_url : "ghost-${substr(sha256("${var.gcp_project_id}"), 0, 8)}-${replace(var.gcp_region, "-", "")}.a.run.app"]
}

# Outputs are defined in outputs.tf
