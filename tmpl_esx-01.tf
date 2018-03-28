////// define a powerDNS resource record (optional)
//////
////resource "powerdns_record" "klessen-cloud-dns-a-rec-<hostname>" {
////  zone = "${var.net_domain_name}."
////  // TODO: setup hostname
////  name = "<hostname>.${var.net_domain_name}."
////  type = "A"
////  ttl = 300
////  // TODO: setup IP address to use - must be specific to your local ESXi host networks
////  records = [ "<IP>" ]
////}
//
////// define extra storage for persistant data
//////
////// TODO: setup extra storage space - check mountpoint below
////resource "vsphere_virtual_disk" "<hostname>-storage-0" {
////  size          = 64
////  vmdk_path     = "storage/<hostname>-storage-0.vmdk"
////  datacenter    = "${data.vsphere_datacenter.example.name}"
////  datastore     = "${data.vsphere_datastore.esx-01-local-storage-example-1.name}"
////  type          = "thin"
////}
//
//resource "vsphere_virtual_machine" "<hostname>" {
//  // TODO: setup hostname
//  name                       = "<hostname>"
//  resource_pool_id           = "${data.vsphere_resource_pool.esx-01.id}"
//  datastore_id               = "${data.vsphere_datastore.esx-01-local-storage-example-1.id}"
//
//  num_cpus                   = 1
//  memory                     = 512
//
//  guest_id                   = "${data.vsphere_virtual_machine.esx-01-centos-latest.guest_id}"
//  wait_for_guest_net_timeout = -1
//  nested_hv_enabled          = true
//
//  network_interface {
//    network_id   = "${data.vsphere_network.internal.id}"
//    adapter_type = "${data.vsphere_virtual_machine.esx-01-centos-latest.network_interface_types[0]}"
//  }
//
//  disk {
//    // TODO: change naming - use disk0 to be backwards-compatible
//    label       = "<hostname>-disk0"
//    size        = "${data.vsphere_virtual_machine.esx-01-centos-latest.disks.0.size}"
//    unit_number = 0
//  }
//
//  clone {
//    template_uuid = "${data.vsphere_virtual_machine.esx-01-centos-latest.id}"
//
//    customize {
//
//      linux_options {
//        // TODO: setup actual hostname of VM
//        host_name = "<hostname>"
//        domain    = "${var.net_domain_name}"
//      }
//
//      network_interface {
//        // TODO: setup actual IP address of VM
//        ipv4_address = "<IP>"
//        ipv4_netmask = 24
//      }
//
//      ipv4_gateway    = "${var.net_esx_01_gateway}"
//      dns_server_list = "${var.net_dns_servers}"
//
//    }
//  }
//
////  // attach the extra storage created for this machine (optional)
////  //
////  disk {
////    label        = "<hostname>-disk1"
////    attach       = true
////    unit_number  = 1
////    path         = "${vsphere_virtual_disk.<hostname>-storage-0.vmdk_path}"
////    datastore_id = "${data.vsphere_datastore.esx-01-local-storage-example-1.id}"
////  }
//
//  connection {
//    user        = "root"
//    private_key = "${file(var.user_ssh_key)}"
//    // TODO: setup host IP to connect to
//    host        = "<IP>"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "echo '{' > /root/metadata.json",
//      "echo '  \"meta\": {' >> metadata.json",
//      // TODO: define the mount-point for the extra storage
//      //  "echo '    \"volume.sdb\": \"<mountpoint>,lvm\"' >> /root/metadata.json",
//      "echo '  }' >> /root/metadata.json",
//      "echo '}' >> /root/metadata.json"
//    ]
//  }
//
//  provisioner "file" {
//    source      = "./scripts/user-data.sh"
//    destination = "/root/user-data.sh"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "chmod +x /root/user-data.sh",
//      "/root/user-data.sh",
//    ]
//  }
//
////// define chef provisioner (optional)
////
////  provisioner "chef" {
////    // TODO: setup node name for chef server
////    node_name               = "<hostname>.${var.net_domain_name}"
////
////    fetch_chef_certificates = true
////    prevent_sudo            = true
////    recreate_client         = true
////    environment             = "cloud"
////    secret_key              = "${var.chef_secret_key}"
////    server_url              = "${var.chef_server_url}"
////    user_key                = "${file(var.chef_auth_pem)}"
////    user_name               = "${var.chef_user_name}"
////    version                 = "${var.chef_client_version}"
////
////    // TODO: give the node an individual run list
////    run_list                = [ "role[base_config]" ]
////  }
//}
