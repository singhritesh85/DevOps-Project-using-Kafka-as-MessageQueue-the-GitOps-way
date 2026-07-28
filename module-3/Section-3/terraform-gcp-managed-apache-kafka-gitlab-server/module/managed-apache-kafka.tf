resource "google_managed_kafka_cluster" "managed_kafka_cluster" {
  cluster_id = "${var.prefix[1]}-cluster"
  location = join("-", slice(split("-", google_compute_instance.vm_instance[1].zone), 0, 2))
  capacity_config {
    vcpu_count = 3 ### Minimum number of vCPUs
    memory_bytes = 3221225472  ###3GiB
  }
  gcp_config {
    access_config {
      network_configs {
        subnet = google_compute_subnetwork.gcp_private_subnet.id 
      }
    }
  }
  rebalance_config {
    mode = "AUTO_REBALANCE_ON_SCALE_UP"
  }
  labels = {
    environment = "${var.env}"
  }
}

resource "google_managed_kafka_topic" "managed_kafka_topic" {
  topic_id = "${var.prefix[1]}-topic"
  cluster = google_managed_kafka_cluster.managed_kafka_cluster.cluster_id
  location = google_managed_kafka_cluster.managed_kafka_cluster.location
  partition_count = 2
  replication_factor = 3
  configs = {
    "cleanup.policy" = "compact"
  }
}
