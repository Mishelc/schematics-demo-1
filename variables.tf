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

/*
variable "ssh_public_key" {
  default = "vpc-mishel"
  description = "SSH Public Key contents to be used"
}
*/

variable "image" {
  default = "r006-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
  description = "OS Image ID - ubuntu-18-04-amd64 -to be used for virtual instances"
}

variable "profile" {
  default = "cx2-2x4"
  description = "Instance profile to be used for virtual instances"
}