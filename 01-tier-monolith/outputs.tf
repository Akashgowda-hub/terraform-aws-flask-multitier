output "app_url" {
  description = "Flask app health check URL"
  value       = "http://${aws_instance.web.public_ip}:5000/"
}

output "tasks_url" {
  description = "API endpoint for DB queries"
  value       = "http://${aws_instance.web.public_ip}:5000/tasks"
}