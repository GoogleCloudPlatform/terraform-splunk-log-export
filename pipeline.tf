# Copyright 2021 Google LLC
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


resource "google_pubsub_topic" "dataflow_deadletter_pubsub_topic" {
  name = local.dataflow_output_deadletter_topic_name
}

resource "google_pubsub_subscription" "dataflow_deadletter_pubsub_sub" {
  name  = local.dataflow_output_deadletter_sub_name
  topic = google_pubsub_topic.dataflow_deadletter_pubsub_topic.name

  # messages retained for 7 days (max)
  message_retention_duration = "604800s"

  # subscription never expires
  expiration_policy {
    ttl = ""
  }
}

resource "google_storage_bucket" "dataflow_job_temp_bucket" {
  name = local.dataflow_temporary_gcs_bucket_name
  location = var.region
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_object" "dataflow_job_temp_object" {
  name = local.dataflow_temporary_gcs_bucket_path
  content = "Placeholder for Dataflow to write temporary files"
  bucket = google_storage_bucket.dataflow_job_temp_bucket.name
}

resource "google_dataflow_job" "dataflow_job" {
  name = var.dataflow_job_name
  template_gcs_path = var.dataflow_template_path
  temp_gcs_location = "gs://${local.dataflow_temporary_gcs_bucket_name}/${local.dataflow_temporary_gcs_bucket_path}"
  machine_type = var.dataflow_job_machine_type
  max_workers = var.dataflow_job_machine_count
  parameters = {
    inputSubscription = google_pubsub_subscription.dataflow_input_pubsub_subscription.id
    outputDeadletterTopic = google_pubsub_topic.dataflow_deadletter_pubsub_topic.id
    url       = var.splunk_hec_url
    token     = var.splunk_hec_token
    parallelism = var.dataflow_job_parallelism
    batchCount = var.dataflow_job_batch_count
    includePubsubMessage = local.dataflow_job_include_pubsub_message
    disableCertificateValidation = var.dataflow_job_disable_certificate_validation
  }
  region = var.region
  network = var.create_network == true ? google_compute_network.splunk_export.id : var.network
  ip_configuration = "WORKER_IP_PRIVATE"
}
