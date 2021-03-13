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

variable "project" {
  description = "Project for Dataflow job deployment"
}

variable "region" {
  description = "Region to deploy into"
}

variable "zone" {
  description = "Zone to deploy into"
  default = ""
}

variable "network" {
  description = "Network to deploy into"
}

# Dashboard parameters

variable "workspace" {
  description = "Cloud Monitoring Workspace to create dashboard under. This assumes Workspace is already created and project provided is already added to it. If parameter is empty, no dashboard will be created"
  default = ""
}

# Log sink details

variable "log_filter" {
  description = "Log filter to use when exporting logs"
}

# Dataflow job output

variable "splunk_hec_url" {
  description = "Splunk HEC URL to write data to. Example: https://[MY_SPLUNK_IP_OR_FQDN]:8088"
  
  validation {
    condition = can(regex("https?://.*(:[0-9]+)?", var.splunk_hec_url))
    error_message = "Splunk HEC url must of the form <protocol>://<host>:<port> ."
  }
}

variable "splunk_hec_token" {
  description = "Splunk HEC token"
  sensitive = true
}

# Dataflow job parameters

variable "dataflow_template_version" {
  description = "Dataflow template version"
  default = "latest"
}

variable "dataflow_job_name" {
  description = "Dataflow job name. No spaces"
}

variable "dataflow_job_machine_type" {
  description = "Dataflow job worker machine type"
  default = "n1-standard-4"
}

variable "dataflow_job_machine_count" {
  description = "Dataflow job max worker count"
  type = number
  default = 2
}

variable "dataflow_job_parallelism" {
  description = "Maximum parallel requests to Splunk"
  type = number
  default = 8
}

variable "dataflow_job_batch_count" {
  description = "Batch count of messages in single request to Splunk"
  type = number
  default = 50
}

variable "dataflow_job_disable_certificate_validation" {
  description = "Disable SSL certificate validation (default: false)"
  type = bool
  default = false
}