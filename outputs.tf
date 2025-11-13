output "alb_dns_name" {
  description = "DNS of the load balancer"
  value       = aws_lb.app_alb.dns_name
}

output "private_key_path" {
  description = "Path to the saved PEM file"
  value       = local_file.private_key_pem.filename
}