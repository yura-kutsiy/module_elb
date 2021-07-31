variable "security_group_description" {
  default = "port-22"
}
variable "vpc_id" {
  default = ""
}
variable "allow_ports" {
  default = ["22"]
}
