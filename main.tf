locals {
  system                     = "readthedocs"
  cluster_name               = "${local.system}-${var.environment}"
  tags = {
    System                   = "${local.system}"
    Environment              = "${var.environment}"
  }
}

module "alerts" {
  source = "./alerts"

  alerts_email               = "${var.alerts_email}"
  cluster_name               = "${local.cluster_name}"
}

module "db" {
  source = "./db"

  alerts_sns_topic_arn      = "${module.alerts.sns_topic_arn}"
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

  alerts_sns_topic_arn      = "${module.alerts.sns_topic_arn}"
  cluster_name               = "${local.cluster_name}"
  domain_name                = "${var.domain_name}"
  environment                = "${var.environment}"
  gunicorn_num_workers       = "${var.web_num_workers}"
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
