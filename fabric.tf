terraform {
  required_providers {
    aci = {
      source  = "ciscodevnet/aci"
      version = "2.1.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aci" {
  # Cisco ACI user name
  username    = "terraform"
  private_key = "../pki/labadmin.key"
  cert_name   = "labadmin.crt"
  url         = "https://apic1-mlg1.cisco.com"
  insecure    = true
}

resource "aci_tenant" "demo" {
  name        = prod1-tenant
  description = "This is a demo tenant created from Terraform"
}

resource "aci_vrf" "main" {
  tenant_dn = aci_tenant.demo.id
  name      = var.vrf_name
}

resource "aci_bridge_domain" "bd_192_168_1_0" {
  tenant_dn          = aci_tenant.demo.id
  name               = var.bd_name
  arp_flood          = no
  unicast_route      = var.bd_unicast_routing
  unk_mac_ucast_act  = var.bd_unk_ucast
  unk_mcast_act      = "flood"
  relation_fv_rs_ctx = aci_vrf.main.id
}

resource "aci_subnet" " subnet_192_168_1_0" {
    parent_dn        = aci_bridge_domain.bd_192_168_1_0.id
    description      = "subnet"
    ip               = "192.168.1.0/24"
    annotation       = "tag_subnet"
    scope            = ["private", "shared"]
}
