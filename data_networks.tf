// define esx-01 local networks
//
data "vsphere_network" "public" {
  name          = "public"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
data "vsphere_network" "private" {
  name          = "private"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
data "vsphere_network" "blue" {
  name          = "blue"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}

// define esx-02 local networks
//
data "vsphere_network" "internal" {
  name          = "internal"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
data "vsphere_network" "external" {
  name          = "external"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
data "vsphere_network" "dmz" {
  name          = "dmz"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}

