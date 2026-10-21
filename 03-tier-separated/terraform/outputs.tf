output "frontend_bucket_name" {
  description = "S3 bucket for frontend files"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_website_endpoint" {
  description = "HTTP endpoint for the static website"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "api_url" {
  description = "HTTP URL of the Flask API load balancer"
  value       = "http://${aws_lb.app.dns_name}"
}

output "rds_endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "PostgreSQL port"
  value       = aws_db_instance.main.port
}
