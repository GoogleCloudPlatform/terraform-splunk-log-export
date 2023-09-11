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

/*
When the replay job needs to be run, simply run terraform with overriding variable
`terraform apply -var deploy_replay_job="true"` or change the value in tfvars file.
After the deadletter Pub/Sub topic has no more messages, set `deploy_replay_job` value to `false ` and 
run a regular terraform deployment (ex. terraform apply). 
*/


resource "google_dataflow_job" "splunk_dataflow_replay" {
  count = var.deploy_replay_job == true ? 1 : 0

  project           = var.project
  name              = local.dataflow_replay_job_name
  template_gcs_path = local.dataflow_pubsub_template_gcs_path
  temp_gcs_location = "gs://${local.dataflow_temporary_gcs_bucket_name}/${local.dataflow_temporary_gcs_bucket_path}"
  machine_type      = var.dataflow_job_machine_type
  max_workers       = var.dataflow_job_machine_count
  parameters = {
    inputSubscription = google_pubsub_subscription.dataflow_deadletter_pubsub_sub.id
    outputTopic       = google_pubsub_topic.dataflow_input_pubsub_topic.id
  }
  region           = var.region
  network          = var.network
  subnetwork       = "regions/${var.region}/subnetworks/${local.subnet_name}"
  ip_configuration = "WORKER_IP_PRIVATE"

  on_delete = "cancel"

  lifecycle {
    ignore_changes = [
      additional_experiments # Ignore default experiments that may be added by Dataflow templates API
    ]
  }

  depends_on = [
    google_compute_subnetwork.splunk_subnet,
    google_storage_bucket_object.dataflow_job_temp_object
  ]
}
