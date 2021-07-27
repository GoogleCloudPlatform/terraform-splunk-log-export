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
The replay job should stay commented out while the main export pipeline is initially deployed.
When the replay job needs to be run, simply uncomment the module and deploy the replay pipeline. 
From the CLI, this may look like `terraform apply -target="google_dataflow_job.splunk_dataflow_replay"`
After the deadletter Pub/Sub topic has no more messages, comment out the module and run a regular terraform deployment (ex. terraform apply). Terraform will automatically destroy the replay job.

`terraform apply -target` usage documentation is here: https://www.terraform.io/docs/cli/commands/apply.html
*/

# resource "random_id" "bucket_suffix" {
#   byte_length = 4
# }

# resource "google_dataflow_job" "splunk_dataflow_replay" {
#   name              = local.dataflow_replay_job_name
#   template_gcs_path = local.dataflow_deadletter_template_gcs_path
#   temp_gcs_location = "gs://${var.splunk_dataflow_context.dataflow_temporary_bucket_name}/${local.dataflow_temporary_gcs_bucket_path}"
#   machine_type      = var.dataflow_replay_job_machine_type
#   max_workers       = var.dataflow_replay_job_machine_count
#   parameters = {
#     inputSubscription = var.splunk_dataflow_context.dataflow_output_deadletter_subscription
#     outputTopic       = var.splunk_dataflow_context.dataflow_input_topic
#   }
#   region                = var.region
#   network               = var.splunk_dataflow_context.splunk_network
#   subnetwork            = var.splunk_dataflow_context.subnetwork_name
#   ip_configuration      = "WORKER_IP_PRIVATE"
#   service_account_email = var.splunk_dataflow_context.dataflow_worker_email
# }