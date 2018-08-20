# readthedocs service stack terraform module

This module contains the [Terraform](https://terraform.io) configuration for
a [Read the Docs](https://readthedocs.org) service stack cluster running on AWS
infrastructure.

It is composed of `alarm`, `db` and `web` submodules.

It builds the following AWS resources:

- an SNS alarm topic
- a DNS CNAME record for the domain
- an SSL cert for the domain
- a Debian 9 EC2 instance for readthedocs web service
- a PostgreSQL RDS instance for readthedocs database service
- security groups for web and database access
- cloud watch alarms for system health

## Usage

Create a module resource with this repository as its source:

    module "production" {
      source           = "git::ssh://github.com/mojochao/readthedocs-aws-tf-module.git?ref=1.0.0"
      providers        = {
        aws            = { ... }            # yours will vary!
      }

      alerts_email     = "readthedocs-alerts@mydomain.com"
      domain_name      = "readthedocs.mydomain.com"
      environment      = "production"
      hosting_zone     = "com.mydomain."    # yours will vary!
      subnet           = "subnet-7d9e3f39"  # yours will vary!
      tags             = { ... }            # yours will vary!
      vpc              = "vpc-7a2cb214"     # yours will vary!
    }

In the example above, only the minimal required inputs are shown.  Readthedocs
service environments may be further customized with the inputs shown below.


## Inputs

This module provides the following inputs, which are forwarded to its `alarm`,
`db` and `web` sub-modules.

| Name | Description | Type | Default |
|------|-------------|------|---------|
| alerts_email | Email address to send CloudWatch alerts to | string | - |
| domain_name | Domain name | string | - |
| environment | Environment name | string | - |
| hosting_zone | Hosting zone name | string | - |
| pg_dbname | AWS DB instance database name | string | `"readthedocs"` |
| pg_instance_type | AWS DB instance type | string | `"db.m4.large"` |
| pg_storage_size_gb | AWS DB instance database size in GB | integer | `25` |
| pg_password | AWS DB instance password | string | - |
| pg_username | AWS DB instance username | string | - |
| pg_version | PostgreSQL version | string | `"10"` |
| region | AWS region name | string | `"us-west-2"` |
| ssh_key| AWS SSH key name | string | - |
| ssl_policy | AWS ssl policy name| string | `"ELBSecurityPolicy-TLS-1-2-2017-01"` |
| subnet | AWS subnet id | string | - |
| tags | AWS resource tags | map | - |
| vpc | AWS VPC id | string | - |
| web_instance_ami | AWS Debian AMI to use | string | `"ami-0574f98a32ba41dd7"` |
| web_instance_type | AWS EC2 instance type | string | `"m5.large"` |
| web_volume_size_gb | Data volume size in gigabytes | integer | `25` |

The default AMI used is a Debian 9 AMI for the default `us-west-2` region.
See https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch for more details.

## Outputs

This module itself provides no outputs, however, its `alarm`, `db` and 
`web` sub-modules do.
