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
  dataflow_worker_service_account = ((var.dataflow_worker_service_account != "") ?
    ((var.use_externally_managed_dataflow_sa == false) ?
      google_service_account.dataflow_worker_service_account[0].email :
    var.dataflow_worker_service_account) :
  "${data.google_project.project.number}-compute@developer.gserviceaccount.com")

  # Grant Dataflow worker service account required IAM roles over external resources
  # **unless** using an externally managed worker service account (Option 1 and 2):
  grant_service_account_roles = var.use_externally_managed_dataflow_sa == true
  # Grant caller (you!) permissions to impersonate service account
  # **only** when creating a new worker service account (Option 2)
  grant_service_account_impersonation = (
    var.dataflow_worker_service_account != "" && var.use_externally_managed_dataflow_sa == false
  )

  subnet_name           = coalesce(var.subnet, "${var.network}-${var.region}")
  project_log_sink_name = "${var.dataflow_job_name}-project-log-sink"
  # tflint-ignore: terraform_unused_declarations
  organization_log_sink_name = "${var.dataflow_job_name}-organization-log-sink"

  dataflow_main_job_name   = "${var.dataflow_job_name}-main-${random_id.dataflow_job_instance.hex}"
  dataflow_replay_job_name = "${var.dataflow_job_name}-replay-${random_id.dataflow_job_instance.hex}"

  dataflow_input_topic_name             = "${var.dataflow_job_name}-input-topic"
  dataflow_input_subscription_name      = "${var.dataflow_job_name}-input-subscription"
  dataflow_output_deadletter_topic_name = "${var.dataflow_job_name}-deadletter-topic"
  dataflow_output_deadletter_sub_name   = "${var.dataflow_job_name}-deadletter-subscription"
  # Store HEC token secret and secret version IDs in two separate local values.
  # This is needed to disambiguate between the two given that the Dataflow template expects
  # secret version ID whereas the IAM policy binding expects parent secret ID
  splunk_hec_token_secret_version_id = var.splunk_hec_token_secret_id
  # Infer secret ID from input which is actually the secret *version* ID
  splunk_hec_token_secret_id = ((var.splunk_hec_token_secret_id != "")
    ? regex("^(projects\\/[^\\n\\r\\/]+\\/secrets\\/[^\\n\\r\\/]+)\\/versions\\/[^\\n\\r\\/]+$", var.splunk_hec_token_secret_id)[0]
  : "")

  # Dataflow job parameters (not externalized for this project)
  dataflow_job_include_pubsub_message       = true
  dataflow_job_enable_batch_logs            = false
  dataflow_job_enable_gzip_http_compression = true

  # Metrics scope for Monitoring dashboard defaults to project unless explicitly provided
  scoping_project = (var.scoping_project != "") ? var.scoping_project : var.project
}

resource "google_pubsub_topic" "dataflow_input_pubsub_topic" {
  name = local.dataflow_input_topic_name
}

resource "google_pubsub_subscription" "dataflow_input_pubsub_subscription" {
  name  = local.dataflow_input_subscription_name
  topic = google_pubsub_topic.dataflow_input_pubsub_topic.name

  # messages retained for 7 days (max)
  message_retention_duration = "604800s"
  ack_deadline_seconds       = 30

  # subscription never expires
  expiration_policy {
    ttl = ""
  }
}

resource "google_logging_project_sink" "project_log_sink" {
  name        = local.project_log_sink_name
  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.dataflow_input_pubsub_topic.name}"
  filter      = var.log_filter

  exclusions {
    name        = "exclude_dataflow"
    description = "Exclude dataflow logs to not create an infinite loop"
    filter      = "resource.type=\"dataflow_step\" AND resource.labels.job_name = \"${local.dataflow_main_job_name}\""
  }

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
