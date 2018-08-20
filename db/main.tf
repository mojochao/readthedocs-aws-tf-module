# -----------------------------------------------------------------------------
# Database instance resources.
# -----------------------------------------------------------------------------

resource "aws_db_instance" "database" {
  identifier                = "${var.cluster_name}"
  engine                    = "postgres"
  engine_version            = "${var.pg_version}"
  allocated_storage         = "${var.pg_size_gb}"
  instance_class            = "${var.instance_type}"
  name                      = "postgres"
  username                  = "postgres"
  password                  = "postgres"
  publicly_accessible       = false
  skip_final_snapshot       = true
  tags                      = "${var.tags}"
  vpc_security_group_ids    = ["${aws_security_group.database.id}"]
}

# -----------------------------------------------------------------------------
# Database security group resources.
# -----------------------------------------------------------------------------

resource "aws_security_group" "database" {
  name                      = "${var.cluster_name}-database-sg"
  tags                      = "${var.tags}"
}

resource "aws_security_group_rule" "allow_pg_inbound_from_web_backend" {
  type                      = "ingress"
  security_group_id         = "${aws_security_group.database.id}"
  source_security_group_id  = "${var.web_security_group_id}"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type                      = "egress"
  security_group_id         = "${aws_security_group.database.id}"
  from_port                 = 0
  to_port                   = 0
  protocol                  = "-1"
  cidr_blocks               = ["0.0.0.0/0"]
}

//# -----------------------------------------------------------------------------
//# Database monitoring resources.
//# -----------------------------------------------------------------------------
//
//resource "aws_cloudwatch_metric_alarm" "database-storage-low-alarm" {
//  alarm_name                = "${var.cluster_name}-database-storage-low-alarm"
//  alarm_description         = "This metric monitors ${var.cluster_name} database storage dipping below threshold"
//  alarm_actions             = ["${var.alerts_arn}"]
//  comparison_operator       = "LessThanThreshold"
//  threshold                 = "20"
//  evaluation_periods        = "2"
//  metric_name               = "FreeStorageSpace"
//  namespace                 = "AWS/RDS"
//  period                    = "120"
//  statistic                 = "Average"
//
//  dimensions {
//    DBInstanceIdentifier    = "${aws_db_instance.database.id}"
//  }
//}
