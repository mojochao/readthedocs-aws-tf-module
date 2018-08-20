locals {
  # ---------------------------------------------------------------------------
  # AWS constants.
  # ---------------------------------------------------------------------------
  ssl_policy                 = "ELBSecurityPolicy-TLS-1-2-2017-01"
  vpc_security_group_ids     = [
    "${aws_security_group.readthedocs.id}"
  ]

  # ---------------------------------------------------------------------------
  # Readthedocs service constants.
  # ---------------------------------------------------------------------------
  readthedocs_root           = "/home/admin/readthedocs"
  readthedocs_sock           = "unix:/home/admin/readthedocs.sock"
}

# -----------------------------------------------------------------------------
# Web External Resources.
#
# The external facing web resources include:
# - DNS CNAME record for the public domain
# - SSL certificate for the public domain
# - an appplication load balancer for backend server EC2 instances
# -----------------------------------------------------------------------------

data "aws_route53_zone" "hosting_zone" {
  name                       = "${var.hosting_zone}"
}

# -----------------------------------------------------------------------------
# DNS resources.
# -----------------------------------------------------------------------------

resource "aws_route53_record" "readthedocs" {
  name                       = "${var.domain_name}"
  ttl                        = 300
  type                       = "CNAME"
  zone_id                    = "${data.aws_route53_zone.hosting_zone.zone_id}"
  records                    = ["${aws_instance.readthedocs.public_dns}"]
}

//resource "aws_route53_record" "cert_validation" {
//  name                    = "${aws_acm_certificate.readthedocs.domain_validation_options.0.resource_record_name}"
//  type                    = "${aws_acm_certificate.readthedocs.domain_validation_options.0.resource_record_type}"
//  zone_id                 = "${data.aws_route53_zone.hosting_zone.id}"
//  records                 = ["${aws_acm_certificate.readthedocs.domain_validation_options.0.resource_record_value}"]
//  ttl                     = 60
//}

# -----------------------------------------------------------------------------
# SSL certificate resources.
# -----------------------------------------------------------------------------

//resource "aws_acm_certificate" "readthedocs" {
//  domain_name             = "${var.domain_name}"
//  validation_method       = "DNS"
//  tags                    = "${local.tags}"
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}
//
//resource "aws_acm_certificate_validation" "readthedocs" {
//  certificate_arn         = "${aws_acm_certificate.readthedocs.arn}"
//  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
//}

# -----------------------------------------------------------------------------
# Web server resources.
# -----------------------------------------------------------------------------

data "template_file" "install_sh" {
  template                   = "${file("${path.module}/templates/install.sh")}"
  vars {
    readthedocs_root         = "${local.readthedocs_root}"
  }
}

data "template_file" "initialize_sh" {
  template                   = "${file("${path.module}/templates/initialize.sh")}"
  vars {
    readthedocs_root         = "${local.readthedocs_root}"
  }
}

data "template_file" "pg_service_conf" {
  template                   = "${file("${path.module}/templates/pg_service.conf")}"
  vars {
    pg_hostname              = "${var.pg_hostname}"
    pg_dbname                = "${var.pg_dbname}"
    pg_username              = "${var.pg_username}"
    pg_password              = "${var.pg_password}"
  }
}

data "template_file" "readthedocs_service" {
  template                   = "${file("${path.module}/templates/readthedocs.service")}"
  vars {
    gunicorn_num_workers     = "${var.gunicorn_num_workers}"
    readthedocs_root         = "${local.readthedocs_root}"
    readthedocs_sock         = "${local.readthedocs_sock}"
  }
}

data "template_file" "readthedocs_nginx" {
  template                   = "${file("${path.module}/templates/readthedocs.nginx")}"
  vars {
    domain_name              = "${var.domain_name}"
    readthedocs_root         = "${local.readthedocs_root}"
    readthedocs_sock         = "${local.readthedocs_sock}"
  }
}

data "template_file" "local_settings_py" {
  template                   = "${file("${path.module}/templates/local_settings.py")}"
  vars {
    domain_name              = "${var.domain_name}"
    pg_hostname              = "${var.pg_hostname}"
    pg_dbname                = "${var.pg_dbname}"
    pg_username              = "${var.pg_username}"
    pg_password              = "${var.pg_password}"
  }
}

resource "aws_instance" "readthedocs" {
  ami                        = "${var.instance_ami}"
  ebs_optimized              = true
  instance_type              = "${var.instance_type}"
  key_name                   = "${var.instance_ssh_key}"
  subnet_id                  = "${var.subnet}"
  tags                       = "${var.tags}"
  vpc_security_group_ids     = ["${local.vpc_security_group_ids}"]

  ebs_block_device {
    delete_on_termination    = false
    device_name              = "/dev/sdi"
    volume_size              = "${var.volume_size_gb}"
  }


  user_data = <<-EOF
              #!/bin/bash
              [ `sudo file -bs /dev/nvme1n1` == "data" ] && sudo mkfs -t ext4 /dev/nvme1n1
              mkdir /home/admin/data && sudo mount /dev/nvme1n1 /home/admin/data && sudo chown -R admin:admin /home/admin/data
              mkdir /home/admin/configs && sudo chown -R admin:admin /home/admin/configs
              mkdir /home/admin/scripts && sudo chown -R admin:admin /home/admin/scripts
              echo "${data.template_file.install_sh.rendered}" > /home/admin/scripts/install.sh && sudo chown -R admin:admin /home/admin/scripts/install.sh
              echo "${data.template_file.initialize_sh.rendered}" > /home/admin/scripts/initialize.sh && sudo chown -R admin:admin /home/admin/scripts/initialize.sh
              echo "${data.template_file.readthedocs_service.rendered}" > /home/admin/configs/readthedocs.service && sudo chown -R admin:admin /home/admin/configs/readthedocs.service
              echo "${data.template_file.readthedocs_nginx.rendered}" > /home/admin/configs/readthedocs.nginx && sudo chown -R admin:admin /home/admin/configs/readthedocs.nginx
              echo "${data.template_file.local_settings_py.rendered}" > /home/admin/configs/local_settings.py && sudo chown -R admin:admin /home/admin/configs/local_settings.py
              echo "${data.template_file.pg_service_conf.rendered}" > /home/admin/.pg_service.conf && sudo chown -R admin:admin /home/admin/.pg_service.conf
              EOF
}

# -----------------------------------------------------------------------------
# Web security group resources.
# -----------------------------------------------------------------------------

resource "aws_security_group" "readthedocs" {
  name                       = "${var.cluster_name}-sg"
  tags                       = "${var.tags}"
}

resource "aws_security_group_rule" "readthedocs_allow_http_inbound" {
  type                       = "ingress"
  security_group_id          = "${aws_security_group.readthedocs.id}"
  from_port                  = 80
  to_port                    = 80
  protocol                   = "tcp"
  cidr_blocks                = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "readthedocs_allow_ssh_inbound" {
  type                       = "ingress"
  security_group_id          = "${aws_security_group.readthedocs.id}"
  from_port                  = 22
  to_port                    = 22
  protocol                   = "tcp"
  cidr_blocks                = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "readthedocs_allow_all_outbound" {
  type                       = "egress"
  security_group_id          = "${aws_security_group.readthedocs.id}"
  from_port                  = 0
  to_port                    = 0
  protocol                   = "-1"
  cidr_blocks                = ["0.0.0.0/0"]
}

# -----------------------------------------------------------------------------
# Web monitoring resources.
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "readthedocs_cpu_alarm" {
  alarm_name                = "${var.cluster_name}-web-cpu-alarm"
  alarm_description         = "CPU utilization on ${var.cluster_name} web EC2 instance"
  alarm_actions             = ["${var.alerts_sns_topic_arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "80"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"

  dimensions {
    InstanceId              = "${aws_instance.readthedocs.id}"
  }
}
