resource "aci_rest" "vmmDomP" {
  dn         = "uni/vmmp-VMware/dom-${var.name}"
  class_name = "vmmDomP"
  content = {
    name       = var.name
    accessMode = var.access_mode
    delimiter  = var.delimiter
    enableTag  = var.tag_collection == true ? "yes" : "no"
    mode       = "default"
  }
}

resource "aci_rest" "infraRsVlanNs" {
  dn         = "${aci_rest.vmmDomP.id}/rsvlanNs"
  class_name = "infraRsVlanNs"
  content = {
    tDn = "uni/infra/vlanns-[${var.vlan_pool}]-dynamic"
  }
}

resource "aci_rest" "vmmVSwitchPolicyCont" {
  dn         = "${aci_rest.vmmDomP.id}/vswitchpolcont"
  class_name = "vmmVSwitchPolicyCont"
}

resource "aci_rest" "vmmRsVswitchOverrideLldpIfPol" {
  count      = var.vswitch_lldp_policy != "" ? 1 : 0
  dn         = "${aci_rest.vmmVSwitchPolicyCont.id}/rsvswitchOverrideLldpIfPol"
  class_name = "vmmRsVswitchOverrideLldpIfPol"
  content = {
    tDn = "uni/infra/lldpIfP-${var.vswitch_lldp_policy}"
  }
}

resource "aci_rest" "vmmRsVswitchOverrideCdpIfPol" {
  count      = var.vswitch_cdp_policy != "" ? 1 : 0
  dn         = "${aci_rest.vmmVSwitchPolicyCont.id}/rsvswitchOverrideCdpIfPol"
  class_name = "vmmRsVswitchOverrideCdpIfPol"
  content = {
    tDn = "uni/infra/cdpIfP-${var.vswitch_cdp_policy}"
  }
}

resource "aci_rest" "vmmRsVswitchOverrideLacpPol" {
  count      = var.vswitch_port_channel_policy != "" ? 1 : 0
  dn         = "${aci_rest.vmmVSwitchPolicyCont.id}/rsvswitchOverrideLacpPol"
  class_name = "vmmRsVswitchOverrideLacpPol"
  content = {
    tDn = "uni/infra/lacplagp-${var.vswitch_port_channel_policy}"
  }
}

resource "aci_rest" "vmmCtrlrP" {
  for_each   = { for vc in var.vcenters : vc.name => vc }
  dn         = "${aci_rest.vmmDomP.id}/ctrlr-${each.value.name}"
  class_name = "vmmCtrlrP"
  content = {
    dvsVersion      = each.value.dvs_version != null ? each.value.dvs_version : "unmanaged"
    hostOrIp        = each.value.hostname_ip
    inventoryTrigSt = "untriggered"
    mode            = "default"
    name            = each.value.name
    port            = "0"
    rootContName    = each.value.datacenter != null ? each.value.datacenter : ""
    scope           = "vm"
    statsMode       = each.value.statistics == true ? "enabled" : "disabled"
  }
}

resource "aci_rest" "vmmUsrAccP" {
  for_each   = { for cred in var.credential_policies : cred.name => cred }
  dn         = "${aci_rest.vmmDomP.id}/usracc-${each.value.name}"
  class_name = "vmmUsrAccP"
  content = {
    name = each.value.name
    usr  = each.value.username
    pwd  = each.value.password
  }

  lifecycle {
    ignore_changes = [content["pwd"]]
  }
}

resource "aci_rest" "vmmRsAcc" {
  for_each   = { for vc in var.vcenters : vc.name => vc if lookup(vc, "credential_policy", null) != null }
  dn         = "${aci_rest.vmmCtrlrP[each.value.name].id}/rsacc"
  class_name = "vmmRsAcc"
  content = {
    tDn = "uni/vmmp-VMware/dom-${var.name}/usracc-${each.value.credential_policy}"
  }
}

resource "aci_rest" "vmmRsMgmtEPg" {
  for_each   = { for vc in var.vcenters : vc.name => vc if lookup(vc, "mgmt_epg", "inb") == "inb" }
  dn         = "${aci_rest.vmmCtrlrP[each.value.name].id}/rsmgmtEPg"
  class_name = "vmmRsMgmtEPg"
  content = {
    tDn = "uni/tn-mgmt/mgmtp-default/inb-${var.inband_epg}"
  }
}
