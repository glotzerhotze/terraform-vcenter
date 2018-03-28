// initial image hosted on first ESXi
//
data "vsphere_virtual_machine" "esx-02-centos-latest" {
  name = "esx-01-centos-latest"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}

// initial image hosted on second ESXi
//
data "vsphere_virtual_machine" "esx-01-centos-latest" {
  name = "esx-02-centos-lates"
  datacenter_id = "${data.vsphere_datacenter.example.id}"
}
