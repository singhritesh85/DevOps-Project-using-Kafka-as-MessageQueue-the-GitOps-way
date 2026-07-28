############################ Create Service Account to Grant Access for Kafka ####################################         

resource "google_service_account" "kafka_client" {
  account_id   = "kafka-client"
  display_name = "Kafka Client Service Account"
}

resource "google_project_iam_member" "managed_kafka_client" {
  project = var.project_name
  role    = "roles/managedkafka.client"
  member = "serviceAccount:${google_service_account.kafka_client.email}"
}

resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.kafka_client.name
  role               = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project_name}.svc.id.goog[kafka/kafka-client]"    ### [namespace/serviceaccount]
}

############################# Create Service Account to Grant Access for Prometheus and Grafana ###################

resource "google_service_account" "kafka_monitor" {
  account_id   = "kafka-monitor-sa"
  display_name = "GCP Managed Kafka Monitoring Service Account"
}

resource "google_project_iam_member" "managed_kafka_monitor" {
  project = var.project_name
  role    = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.kafka_monitor.email}"
}

###Bind the GCP service account to the specific Kubernetes Service Account used by Grafana
resource "google_service_account_iam_member" "workload_identity_managed_kafka_monitor" {
  service_account_id = google_service_account.kafka_monitor.name
  role               = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project_name}.svc.id.goog[monitoring/kube-prometheus-stack-grafana]"    ### [namespace/serviceaccount]
}
