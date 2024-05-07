output "instance_ip" {
  value = aws_instance.devopspro-handson[*].public_ip
}

output "instance_id_private" {
  value       = aws_instance.devopspro-handson[*].private_ip
  description = "value of private ip"
}

output "username" {
  value       = aws_db_instance.db_instance_handson[*].username
  description = "value of username"
}

output "password" {
  value       = aws_db_instance.db_instance_handson[*].password
  description = "value of password"
  sensitive   = true
}

output "lb_ip" {
  value       = aws_lb.example[*].dns_name
  description = "value of lb_ip"
}