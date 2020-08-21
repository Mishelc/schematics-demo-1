/*
data "ibm_resource_group" "resource_group" {
  name = "${var.resource_group}"
}
*/

resource "ibm_is_ssh_key" "vpc-mishel" {
  name       = "vpc-mishel"
  public_key = "${var.ssh_public_key}"
}
# Create VPC
resource "ibm_is_vpc" "vpc1" {
  name = "${var.vpc_name}"
  # resource_group  = "${data.ibm_resource_group.resource_group.id}"
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
resource "ibm_is_subnet" "public1" {
  name            = "public1"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone1}"
  ipv4_cidr_block = "${var.zone1_subnet1}"
  public_gateway = "${ibm_is_public_gateway.gateway1.id}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap1"]
}

resource "ibm_is_subnet" "private1" {
  name            = "private1"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone1}"
  ipv4_cidr_block = "${var.zone1_subnet2}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap1"]
}

# Subnets Zone 2
resource "ibm_is_subnet" "public2" {
  name            = "public2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.zone2_subnet1}"
  public_gateway = "${ibm_is_public_gateway.gateway2.id}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap2"]
}

resource "ibm_is_subnet" "private2" {
  name            = "private2"
  vpc             = "${ibm_is_vpc.vpc1.id}"
  zone            = "${var.zone2}"
  ipv4_cidr_block = "${var.zone2_subnet2}"
  depends_on      = ["ibm_is_vpc_address_prefix.vpc-ap2"]
}

# Security Groups Config

resource "ibm_security_group" "sg-app" {
    name = "sg-app"
    vpc = "${ibm_is_vpc.vpc1.id}"
    description = "allow my app traffic"
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_22" {
  # depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  security_group_id = "${ibm_security_group.sg-app.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "22"
    port_max = "22"
  }
  depends_on = ["ibm_is_security_group.sg-app"]
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_80" {
  # depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  security_group_id = "${ibm_security_group.sg-app.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "80"
    port_max = "80"
  }
  depends_on = ["ibm_is_security_group.sg-app"]
}

resource "ibm_is_security_group_rule" "sg1_rule_icmp" {
  # depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  security_group_id = "${ibm_security_group.sg-app.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp = {
    type = "8"
  }
  depends_on = ["ibm_is_security_group.sg-app"]
}

resource "ibm_security_group" "sg-db" {
    name = "sg-db"
    vpc = "${ibm_is_vpc.vpc1.id}"
    #  description = "allow my app traffic"
}

resource "ibm_is_security_group_rule" "sg2_tcp_rule_22" {
  # depends_on = ["ibm_is_floating_ip.floatingip1", "ibm_is_floating_ip.floatingip2"]
  security_group_id = "${ibm_security_group.sg-db.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp = {
    port_min = "22"
    port_max = "22"
  }
  depends_on = ["ibm_is_security_group.sg-db"]
}



#App Instance Subnet 1 Zone 1
resource "ibm_is_instance" "appinstance1" {
  name    = "appinstance1"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.public1.id}"
    security_groups = ["${ibm_is_security_group.sg-app.id}"]
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone1}"
  keys = ["${ibm_is_ssh_key.vpc-mishel.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
  depends_on = ["ibm_is_security_group_rule.sg1_tcp_rule_22","ibm_is_security_group_rule.sg1_tcp_rule_80","ibm_is_security_group_rule.sg1_rule_icmp"]
}
# App Instance Subnet 1 Zone 2
resource "ibm_is_instance" "appinstance2" {
  name    = "appinstance2"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.public2.id}"
    security_groups = ["${ibm_is_security_group.sg-app.id}"]
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone2}"
  keys = ["${ibm_is_ssh_key.vpc-mishel.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-apptier.rendered}"
  depends_on = ["ibm_is_security_group_rule.sg1_tcp_rule_22","ibm_is_security_group_rule.sg1_tcp_rule_80","ibm_is_security_group_rule.sg1_rule_icmp"]
}
# Database Instance Subnet 2 Zone 1
resource "ibm_is_instance" "dbinstance1" {
  name    = "dbinstance1"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.private1.id}"
    security_groups = ["${ibm_is_security_group.sg-db.id}"]
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone1}"
  keys = ["${ibm_is_ssh_key.vpc-mishel.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-database.rendered}"
  depends_on = ["ibm_is_security_group_rule.sg2_tcp_rule_22"]
}

# Database Instance Subnet 2 Zone 2
resource "ibm_is_instance" "dbinstance2" {
  name    = "dbinstance2"
  image   = "${var.image}"
  profile = "${var.profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.private2.id}"
    security_groups = ["${ibm_is_security_group.sg-db.id}"]
  }
  vpc  = "${ibm_is_vpc.vpc1.id}"
  zone = "${var.zone2}"
  keys = ["${ibm_is_ssh_key.vpc-mishel.id}"]
  user_data = "${data.template_cloudinit_config.cloud-init-database.rendered}"
  depends_on = ["ibm_is_security_group_rule.sg2_tcp_rule_22"]
}

# Floating IP Application Instance Zone 1
resource "ibm_is_floating_ip" "floatingip1" {
  name = "fip1"
  target = "${ibm_is_instance.appinstance1.primary_network_interface.0.id}"
}
# Floating IP Application Instance Zone 2
resource "ibm_is_floating_ip" "floatingip2" {
  name = "fip2"
  target = "${ibm_is_instance.appinstance2.primary_network_interface.0.id}"
}


