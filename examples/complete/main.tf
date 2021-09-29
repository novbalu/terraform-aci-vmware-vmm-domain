module "aci_vmware_vmm_domain" {
  source  = "netascode/vmware-vmm-domain/aci"
  version = ">= 0.0.2"

  name                        = "VMW1"
  access_mode                 = "read-only"
  delimiter                   = "="
  tag_collection              = true
  vlan_pool                   = "VP1"
  vswitch_cdp_policy          = "CDP1"
  vswitch_lldp_policy         = "LLDP1"
  vswitch_port_channel_policy = "PC1"
  vcenters = [{
    name              = "VC1"
    hostname_ip       = "1.1.1.1"
    datacenter        = "DC"
    credential_policy = "CP1"
    dvs_version       = "6.5"
    statistics        = true
    mgmt_epg          = "oob"
  }]
  credential_policies = [{
    name     = "CP1"
    username = "USER1"
    password = "PASSWORD1"
  }]
}
