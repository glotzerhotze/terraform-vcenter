variable "vcs_username" {
  description = "the username for the vCenter instance"
  type        = "string"
}
variable "vcs_password" {
  description = "the password for the vCenter instance"
  type        = "string"
}
variable "vcs_server" {
  description = "the vSphere vCenter instance to talk to"
  type        = "string"
}
variable "chef_auth_pem" {
  description = "the chef identity to be used for provisioning the host"
  type        = "string"
}
variable "chef_user_name" {
  description = "the chef username to be used for authenticating against chef server"
  type        = "string"
}
variable "chef_server_url" {
  description = "the URL of the chef server"
  type        = "string"
}
variable "chef_secret_key" {
  description = "the secret key for encrypted data bags"
  type        = "string"
}
variable "chef_client_version" {
  description = "the version of the chef client to use"
  type        = "string"
  default     = "13.7.16"
}
variable "user_ssh_key" {
  description = "the ssh key used to connect to the machines"
  type        = "string"
}
variable "pdns_api_key" {
  description = "the api key to register DNS records with the powerDNS server"
  type        = "string"
}
variable "pdns_server_url" {
  description = "the URL of the powerDNS authorative server managing the zones"
  type        = "string"
}
variable "net_esx_01_gateway" {
  description = "the gateway IP address of the network on esx-01"
}
variable "net_esx_02_gateway" {
  description = "the gateway IP address of the network on esx-02"
}
variable "net_dns_servers" {
  description = "a list of recursive DNS server IP's to be used"
  type = "list"
  default = [ "your.first.dns.ip", "your.second.dns.ip" ]
}
variable "net_domain_name" {
  description = "the domain name to put vm's into"
  type = "string"
}