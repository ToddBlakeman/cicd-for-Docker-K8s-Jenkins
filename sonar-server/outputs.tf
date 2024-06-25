output "printregion" {
  value = var.region
}

output "print-availability_zone" {
  value = data.aws_availability_zones.available.names[0]
}

output "printkey" {
  value = aws_key_pair.sonar-key.key_name
}