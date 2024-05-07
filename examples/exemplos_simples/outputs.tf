output "stack_instance_ip" {
  value = module.wp_stack_module.instance_ip
}

# output "stack_instance_id_private" {
#   value       = aws_instance.devopspro-handson[*].private_ip
#   description = "value of private ip"
# }

output "stack_username" {
  value       = module.wp_stack_module.username
  description = "value of username"
}

output "stack_password" {
  value       = module.wp_stack_module.password
  description = "value of password"
  sensitive   = true
}

output "stack_lb_ip" {
  value       = module.wp_stack_module.lb_ip
  description = "value of lb_ip"
}