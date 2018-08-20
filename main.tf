locals {
  system                     = "readthedocs"
  cluster_name               = "${local.system}-${var.environment}"
  tags = {
    System                   = "${local.system}"
    Environment              = "${var.environment}"
  }
}

module "db" {
  source = "./db"

  cluster_name               = "${local.cluster_name}"
  instance_type              = "${var.pg_instance_type}"
  pg_dbname                  = "${var.pg_dbname}"
  pg_password                = "${var.pg_password}"
  pg_size_gb                 = "${var.pg_storage_size_gb}"
  pg_username                = "${var.pg_username}"
  region                     = "${var.region}"
  tags                       = "${merge(var.tags, local.tags)}"
  web_security_group_id      = "${module.web.security_group_id}"
}


module "web" {
  source = "./web"

  cluster_name               = "${local.cluster_name}"
  domain_name                = "${var.domain_name}"
  environment                = "${var.environment}"
  hosting_zone               = "${var.hosting_zone}"
  instance_ami               = "${var.web_instance_ami}"
  instance_ssh_key           = "${var.ssh_key}"
  instance_type              = "${var.web_instance_type}"
  pg_hostname                = "${module.db.hostname}"
  pg_dbname                  = "${var.pg_dbname}"
  pg_password                = "${var.pg_password}"
  pg_username                = "${var.pg_username}"
  region                     = "${var.region}"
  subnet                     = "${var.subnet}"
  tags                       = "${merge(var.tags, local.tags)}"
  vpc                        = "${var.vpc}"
  volume_size_gb             = "${var.web_volume_size_gb}"
}
