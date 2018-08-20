output "hostname" {
  value = "${aws_db_instance.database.address}"
}
