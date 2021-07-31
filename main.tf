/*
In this module you can configure
application load balancerbetween two instances.
Enter your key_pair for instance, choose instance type,
opne ports.
*/
provider "aws" {
  region = "eu-central-1"
}

module "launch_configuration" {
  source = "./modules/instance"

  instance_type     = "t2.micro"
  security_groups   = [module.security_group_1.security_group_id]
  user_data         = file("server.sh")
  pair_key          = "aws-key-Frankfurt"
  public_ip_address = true
}

module "security_group_1" {
  source                     = "./modules/security_group"
  security_group_description = "sec-gr-from-module"
  vpc_id                     = module.network.vpc_id
  allow_ports                = ["22", "80"]
}

module "elb" {
  source               = "./modules/elb"
  elb_name             = "web-elb"
  subnet_ids           = [module.network.subnet_id_1, module.network.subnet_id_2]
  security_groups      = [module.security_group_1.security_group_id]
  launch_configuration = module.launch_configuration.launch_configuration_id
  cross_zone_balancing = true
}

module "network" {
  source = "./modules/network"
  #vpc_id
  #subnet_ids
}

output "elb_url" {
  value = module.elb.elb_url
}
