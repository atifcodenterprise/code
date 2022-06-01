# outputs you can kist required endpoints, ip or instanceid's

output "alb_hostname-output" {
  value = aws_alb.alb.dns_name
}


## OUTPUT THE stage invoke URL
output "api_gateway_invoke_url" {
  description = "API gateway invoke url"
  value       = aws_api_gateway_stage.api_stage.invoke_url
}
## OUTPUT THE stage invoke URL

# output the EFS disk ID. Can be attached to ECS for persistence
# output "efs-disk-id-output" {
#   value = "${aws_efs_file_system.efs.id}"
# }

# output "testing" {
#   value = "${aws_subnet.public}"
# }

# output "testing" {
#   value = "${data.aws_availability_zones.available.names}"
# }
