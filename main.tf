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

terraform {
  required_version = ">= 0.13"
}

provider "google" {
  project = var.project
  region  = var.region
}

data "google_project" "project" {}

data "google_client_openid_userinfo" "provider_identity" {}

# Generate new random hex to be used for bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Generate new random id each time we switch to a new template version id,
# to be used for pipeline job name to force job replacement vs in-place update
resource "random_id" "dataflow_job_instance" {
  byte_length = 2
  keepers = {
    dataflow_template_version = var.dataflow_template_version
  }
}

locals {
  dataflow_temporary_gcs_bucket_name = "${var.project}-${var.dataflow_job_name}-${random_id.bucket_suffix.hex}"
  dataflow_temporary_gcs_bucket_path = "tmp/"

  dataflow_splunk_template_gcs_path = "gs://dataflow-templates/${var.dataflow_template_version}/Cloud_PubSub_to_Splunk"
  dataflow_pubsub_template_gcs_path = "gs://dataflow-templates/${var.dataflow_template_version}/Cloud_PubSub_to_Cloud_PubSub"

  # If provided, set Dataflow worker to new user-managed service account;
  # otherwise, use Compute Engine default service account
  dataflow_worker_service_account = ((var.dataflow_worker_service_account != "")
    ? "${var.dataflow_worker_service_account}"
    : "${data.google_project.project.number}-compute@developer.gserviceaccount.com")

  subnet_name = coalesce(var.subnet, "${var.network}-${var.region}")
  project_log_sink_name = "${var.dataflow_job_name}-project-log-sink"
  organization_log_sink_name = "${var.dataflow_job_name}-organization-log-sink"

  dataflow_main_job_name = "${var.dataflow_job_name}-main-${random_id.dataflow_job_instance.hex}"
  dataflow_replay_job_name = "${var.dataflow_job_name}-replay-${random_id.dataflow_job_instance.hex}"

  dataflow_input_topic_name = "${var.dataflow_job_name}-input-topic"
  dataflow_input_subscription_name = "${var.dataflow_job_name}-input-subscription"
  dataflow_output_deadletter_topic_name = "${var.dataflow_job_name}-deadletter-topic"
  dataflow_output_deadletter_sub_name = "${var.dataflow_job_name}-deadletter-subscription"

  # dataflow job parameters (not externalized for this project)
  dataflow_job_include_pubsub_message = true
  dataflow_job_enable_batch_logs = false
  dataflow_job_enable_gzip_http_compression = true
}

resource "google_pubsub_topic" "dataflow_input_pubsub_topic" {
  name = local.dataflow_input_topic_name
}

resource "google_pubsub_subscription" "dataflow_input_pubsub_subscription" {
  name  = local.dataflow_input_subscription_name
  topic = google_pubsub_topic.dataflow_input_pubsub_topic.name

  # messages retained for 7 days (max)
  message_retention_duration = "604800s"
  ack_deadline_seconds = 30

  # subscription never expires
  expiration_policy {
    ttl = ""
  }
}

resource "google_logging_project_sink" "project_log_sink" {
  name = local.project_log_sink_name
  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.dataflow_input_pubsub_topic.name}"
  filter = var.log_filter

  unique_writer_identity = true
}

# resource "google_logging_organization_sink" "organization_log_sink" {
#   name = local.organization_log_sink_name
#   org_id = "ORGANIZATION_ID"
#   destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.dataflow_input_pubsub_topic.name}"
#   filter = var.log_filter
#
#   include_children = "true"
# }

output "dataflow_job_id" {
    value = google_dataflow_job.dataflow_job.job_id
}

output "dataflow_input_topic" {
    value = google_pubsub_topic.dataflow_input_pubsub_topic.name
}

output "dataflow_output_deadletter_subscription" {
    value = google_pubsub_subscription.dataflow_deadletter_pubsub_sub.name
}

output "dataflow_log_export_dashboard" {
    value = var.workspace != "" ? google_monitoring_dashboard.splunk-export-pipeline-dashboard[0].id : ""
}
