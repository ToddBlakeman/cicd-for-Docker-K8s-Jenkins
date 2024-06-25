output "printregion" {
  value = var.region
}

output "print-availability_zone" {
  value = data.aws_availability_zones.available.names[0]
}

output "printkey" {
  value = aws_key_pair.jenkins-key.key_name
}

output "jenkins_url" {
  value = join("", ["http://", aws_instance.jenkins-server.public_dns, ":", "8080"])
}