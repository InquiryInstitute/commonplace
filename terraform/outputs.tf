output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.ghost_db.connection_name
}

output "cloud_run_url" {
  description = "Cloud Run service URL (available after deployment)"
  value       = try(google_cloud_run_service.ghost.status[0].url, "Deploy service first")
}

output "vpc_connector_name" {
  description = "VPC connector name (full path for Cloud Run)"
  value       = "projects/${var.gcp_project_id}/locations/${var.gcp_region}/connectors/${google_vpc_access_connector.ghost_connector.name}"
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.inquiry_institute.zone_id
}

output "route53_name_servers" {
  description = "Route 53 name servers"
  value       = aws_route53_zone.inquiry_institute.name_servers
}

output "gcs_bucket_name" {
  description = "GCS bucket name for Ghost content"
  value       = google_storage_bucket.ghost_content.name
}
