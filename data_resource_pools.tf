// define first ESXi host as a resource pool
//
data "vsphere_resource_pool" "esx-01" {
  name          = "esx-01"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}

// define second ESXi host as a resource pool
//
data "vsphere_resource_pool" "esx-02" {
  name          = "esx-02"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
