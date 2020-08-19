variable "resource_group" {
  default = "VPC"
  description = "Name of resource group to provision resources"
}

variable "ibmcloud_region" {
  description = "Preferred IBM Cloud region to use for your infrastructure"
  default = "us-south"
}

variable "vpc_name" {
  default = "vpc-demo-1"
  description = "Name of your VPC"
}

variable "zone1" {
  default = "us-south-1"
  description = "Define the 1st zone of the region"
}

variable "zone2" {
  default = "us-south-2"
  description = "Define the 2nd zone of the region"
}

variable "zone1_cidr" {
  default = "172.16.1.0/24"
  description = "CIDR block to be used for zone 1"
}

variable "zone2_cidr" {
  default = "172.16.2.0/24"
  description = "CIDR block to be used for zone 2"
}

variable "zone1_subnet1" {
    default = "172.16.1.0/26"
    description = "CIDR block to be used for subnet 1 in zone 1"
}

variable "zone1_subnet2" {
    default = "172.16.1.64/26"
    description = "CIDR block to be used for subnet 2 in zone 1"
}

variable "zone2_subnet1" {
    default = "172.16.2.0/26"
    description = "CIDR block to be used for subnet 1 in zone 2"
}

variable "zone2_subnet2" {
    default = "172.16.2.64/26"
    description = "CIDR block to be used for subnet 1 in zone 2"
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJxQaH+pkwq3fs3vZW0basBRZd0/0h9hJvJ45nY0YL8HPl6yX/uJLYaPFIAYEmU45oCBuEi21ijJiLCwFq7A4jZJ1A92ncUulsNdJMh3RF8YcTPjqxQS9rGLJDhwmFY/k3ihKzlBFkcIMf02/oik3/OrNVZAnfI3ACIlz3kcoToMXUTpDXvWZrcHiMJWwkMmrYOIQV/t4pcSmN91AnHJkLtnT1KH1eQh0wKcY4xi3vFBYKTTRcabkwyKKienClhefB5J0xjOXjA4UUMJ8UfO86yJtoo9DqmJHypuwfvD/WdPZZKoqDOCjtOr8gZ81fIrBivlCVkcvk+ZACDRxAJrdbruM2YuZtCkUrQf7KzUa9ZUOZGjZKNF+WkyiUOblShpDAZk2u2FbShf+v6+vxtYrHxoEGdV1NCw/BRceK2Fhphmt/HD/xlssAOLMH8w6fHfQy/IBtd7xdMUT5UqVUROf9DYuHyVj7AfdAtSLejGFIw61IEaCkKmgXVK/lYtom778= mishel.carrion@ibm.com"
  description = "SSH Public Key contents to be used"
}


variable "image" {
  default = "r006-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  description = "OS Image ID - ubuntu-18-04-amd64 -to be used for virtual instances"
}

variable "profile" {
  default = "cx2-2x4"
  description = "Instance profile to be used for virtual instances"
}