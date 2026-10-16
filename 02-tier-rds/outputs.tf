
output "app_url" {
  description = "Todo application URL"
  value       = "http://${aws_instance.app.public_ip}:5000"
}

output "ssh_command" {
  description = "SSH command for the application instance"
  value       = "ssh -i <path-to-your-private-key> ubuntu@${aws_instance.app.public_ip}"
}

output "rds_endpoint" {
  description = "Private RDS endpoint (hostname and port)"
  value       = "${aws_db_instance.todo.address}:${aws_db_instance.todo.port}"
}

output "database_name" {
  description = "Application database name"
  value       = aws_db_instance.todo.db_name
}

output "database_pass" {
  description = "Application database password"
  value       = random_password.db_password.result
}