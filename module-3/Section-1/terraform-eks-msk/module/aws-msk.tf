############################################ S3 Bucket to capture ALB access logs #################################

resource "time_static" "creation_date" {}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.access_log_bucket}-${formatdate("YYYY-MM-DD", time_static.creation_date.rfc3339)}"
  force_destroy = true
  tags = {
    Environment = var.env
  }
}

############################################# S3 Bucket Server Side Encryption ###################################

resource "aws_s3_bucket_server_side_encryption_configuration" "s3bucket_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

############################################## Security Group for AWS MSK ########################################

resource "aws_security_group" "msk" {
  name   = "${var.prefix}-msk-kraft-sg"
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port   = 11001
    to_port     = 11002
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
    description = "Allow MSK Prometheus JMX and Node Exporter scraping"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################# Cloudwatch Log Group ###########################################

#resource "aws_cloudwatch_log_group" "msk" {
#  name              = "/aws/msk/kraft-cluster"
#  retention_in_days = 7
#}

################################################# AWS MSK Configuration ###########################################

resource "aws_msk_configuration" "kraft" {
  name           = "${var.prefix}-kraft-config"
  kafka_versions = ["3.9.x.kraft"]
  server_properties = <<PROPERTIES
  auto.create.topics.enable=false
  default.replication.factor=3
  min.insync.replicas=2
  num.io.threads=8
  num.network.threads=5
  num.partitions=1
  num.replica.fetchers=2
  replica.lag.time.max.ms=30000
  socket.receive.buffer.bytes=102400
  socket.request.max.bytes=104857600
  socket.send.buffer.bytes=102400
  unclean.leader.election.enable=false
  PROPERTIES
}

################################################# AWS MSK Kafka ###################################################

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = "${var.prefix}-msk-cluster"
  kafka_version          = "3.9.x.kraft"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type = "kafka.m7g.large"
    client_subnets = aws_subnet.private_subnet.*.id    ### concat("${aws_subnet.public_subnet.*.id}", "${aws_subnet.private_subnet.*.id}")
    storage_info {
      ebs_storage_info {
#        provisioned_throughput {
#          enabled           = true
#          volume_throughput = 250
#        }
        volume_size = 1  ### Provide a value between 1 and 16384
      }
    }
    security_groups = [aws_security_group.msk.id]
  }

  configuration_info {
    arn      = aws_msk_configuration.kraft.arn
    revision = aws_msk_configuration.kraft.latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.aws_kafka_kms_key_id
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = true
    }
    tls {}
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
#      cloudwatch_logs {
#        enabled   = true
#        log_group = aws_cloudwatch_log_group.msk.name
#      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.s3_bucket.id
        prefix  = "logs/msk"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client_authentication
    ]
  }

  tags = {
    environment = var.env
  }
}

################################################ Autoscale Volume in AWS MSK ##########################################################

resource "aws_appautoscaling_target" "msk_storage" {
  max_capacity       = 20  ### You can provide upto 16384 GiB.
  min_capacity       = 1
  resource_id        = aws_msk_cluster.msk_cluster.arn
  scalable_dimension = "kafka:broker-storage:VolumeSize"
  service_namespace  = "kafka"
}

resource "aws_appautoscaling_policy" "msk_storage" {
  name               = "${aws_msk_cluster.msk_cluster.cluster_name}-storage"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.msk_storage.resource_id
  scalable_dimension = aws_appautoscaling_target.msk_storage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.msk_storage.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 75 ### When broker storage utilization approaches or exceeds 75%, MSK will automatically increase the EBS volume size to bring utilization back below the target.

    predefined_metric_specification {
      predefined_metric_type = "KafkaBrokerStorageUtilization"
    }

    disable_scale_in = true  ### Once storage is increased, it will NOT be decreased automatically.
  }
}
