output "printregion" {
  value = var.region
}

output "print-availability_zone" {
  value = data.aws_availability_zones.available.names[0]
}

output "printkey" {
  value = aws_key_pair.kops-key.key_name
}