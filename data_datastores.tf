// define storage connected to first ESXi host
//
data "vsphere_datastore" "esx-01-local-storage-example-1" {
  name          = "esx-01-local-storage-example-1"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
data "vsphere_datastore" "esx-01-local-storage-example-2" {
  name          = "esx-01-local-storage-example-2"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}

// define storage connected to second ESXi host
//
data "vsphere_datastore" "esx-02-local-storage-example-1" {
  name          = "esx-02-local-storage-example-1"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
data "vsphere_datastore" "esx-02-local-storage-2" {
  name          = "esx-02-local-storage-example-2"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}