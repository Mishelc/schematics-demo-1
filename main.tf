data "ibm_resource_group" "resource_group" {
  name = "${var.resource_group}"
}

resource "ibm_is_ssh_key" "vpc-mishel" {
  name       = "vpc-mishel"
  public_key = "${var.ssh_public_key}"
}
# Create VPC
resource "ibm_is_vpc" "vpc1" {
  name = "${var.vpc_name}"
  resource_group  = "${data.ibm_resource_group.resource_group.id}"
}
# VPC Zones
resource "ibm_is_vpc_address_prefix" "vpc-ap1" {
  name = "vpc-ap1"
  zone = "${var.zone1}"
  vpc  = "${ibm_is_vpc.vpc1.id}"
  cidr = "${var.zone1_cidr}"
}

resource "ibm_is_vpc_address_prefix" "vpc-ap2" {
  name = "vpc-ap2"
  zone = "${var.zone2}"
  vpc  = "${ibm_is_vpc.vpc1.id}"
  cidr = "${var.zone2_cidr}"
}
# Public gateway zone 1
resource "ibm_is_public_gateway" "gateway1" {
    name = "gateway1"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone1}"
}

# Public gateway zone 2
resource "ibm_is_public_gateway" "gateway2" {
    name = "gateway2"
    vpc = "${ibm_is_vpc.vpc1.id}"
    zone = "${var.zone2}"
}

# Subnets Zone 1
resource "ibm_is_subnet" "app1" {
  name            = "app1"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone1}"
  ipv4_cidr_block = "${var.zone1_subnet1}"
  public_gateway = "${ibm_is_public_gateway.gateway1.id}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap1"]
}

resource "ibm_is_subnet" "bd1" {
  name            = "bd1"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone1}"
  ipv4_cidr_block = "${var.zone1_subnet2}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap1"]
}

# Subnets Zone 2
resource "ibm_is_subnet" "app2" {
  name            = "app2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.zone2_subnet1}"
  public_gateway = "${ibm_is_public_gateway.gateway2.id}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap2"]
}

resource "ibm_is_subnet" "bd2" {
  name            = "bd2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.zone2_subnet2}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap2"]
}
#App Instance Subnet 1 Zone 1
resource "ibm_is_instance" "appinstance1" {
  name    = "appinstance1"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.app1.id}"
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone1}"
  keys = ["${ibm_is_ssh_key.vpc-mishel.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
}
# App Instance Subnet 1 Zone 2
resource "ibm_is_instance" "appinstance2" {
  name    = "appinstance2"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.app2.id}"
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone2}"
  keys = ["${ibm_is_ssh_key.vpc-mishel.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
}

resource "ibm_is_floating_ip" "floatingip1" {
  name = "fip1"
  target = "${ibm_is_instance.appinstance1.primary_network_interface.0.id}"
}

resource "ibm_is_floating_ip" "floatingip2" {
  name = "fip2"
  target = "${ibm_is_instance.appinstance2.primary_network_interface.0.id}"
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_22" {
  depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  group     = "${ibm_is_vpc.vpc1.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "22"
    port_max = "22"
  }
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_80" {
  depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  group     = "${ibm_is_vpc.vpc1.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "80"
    port_max = "80"
  }
}