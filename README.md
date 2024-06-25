# cicd-for-Docker-K8s-Jenkins
This repo contains the terraform code to create 3 Linux based servers on AWS infrastructure.

The 3 servers are:
Jenkins-server: The terraform code to deploy Jenkins on AWS for CICD.
Kops-server: The terraform code to deploy k0ps, and therefore Kubernetes, on AWS for management of a containerization.
Sonar-server: The terraform code to deploy Sonarqube on AWS as part of the CICD pipeline, to analyze and quality check code.
