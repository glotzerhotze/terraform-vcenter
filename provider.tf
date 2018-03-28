provider "vsphere" {
  user           = "${var.vcs_username}"
  password       = "${var.vcs_password}"
  vsphere_server = "${var.vcs_server}"
  # if you have a self-signed cert
  allow_unverified_ssl = true
}

//provider "powerdns" {
//  api_key    = "${var.pdns_api_key}"
//  server_url = "${var.pdns_server_url}"
//}
