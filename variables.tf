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
  description = "Region to deploy regional-resources into. This must match subnet's region if deploying into existing network (e.g. Shared VPC)"
}

variable "create_network" {
  description = "Boolean value specifying if a new network needs to be created."
  default     = false
  type        = bool
}

variable "network" {
  description = "Network to deploy into"
}

variable "subnet" {
  description = "Subnet to deploy into. This is required when deploying into existing network (e.g. Shared VPC)"
  default = ""
}

variable "primary_subnet_cidr" {
  type        = string
  description = "The CIDR Range of the primary subnet"
  default     = "10.128.0.0/20"
}

# Dashboard parameters

variable "scoping_project" {
  description = "Cloud Monitoring scoping project to create dashboard under. This assumes a pre-existing scoping project whose metrics scope contains the service project. If parameter is empty, scoping project defaults to service project where dataflow job is running."
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
  type        = string
  description = "Dataflow template version for the replay job."
  default     = "latest"
}

variable "dataflow_worker_service_account" {
  type        = string
  description = "(Optional) Name of worker service account to be created and used to execute job operations. Must be 6-30 characters long, and match the regular expression [a-z]([-a-z0-9]*[a-z0-9]). If parameter is empty, worker service account defaults to project's Compute Engine default service account."
  default     = ""

  validation {
    condition = (var.dataflow_worker_service_account == "" ||
                can(regex("[a-z]([-a-z0-9]*[a-z0-9])", var.dataflow_worker_service_account)))
    error_message = "Dataflow worker service account id must match the regular expression [a-z]([-a-z0-9]*[a-z0-9])."
  }
}

variable "dataflow_job_name" {
  description = "Dataflow job name. No spaces"
}

variable "dataflow_job_machine_type" {
  description = "Dataflow job worker machine type"
  default = "n1-standard-4"
}

variable "dataflow_job_machine_count" {
  description = "Dataflow job max worker count. Defaults to 2."
  type = number
  default = 2
}

variable "dataflow_job_parallelism" {
  description = "Maximum parallel requests to Splunk. Defaults to 8."
  type = number
  default = 8
}

variable "dataflow_job_batch_count" {
  description = "Batch count of messages in single request to Splunk. Defaults to 50."
  type = number
  default = 50
}

variable "dataflow_job_disable_certificate_validation" {
  description = "Disable SSL certificate validation (default: false)"
  type = bool
  default = false
}

variable "dataflow_job_udf_gcs_path" {
  description = "[Optional Dataflow UDF] GCS path for JavaScript file (default: '')"
  default = ""
}

variable "dataflow_job_udf_function_name" {
  description = "[Optional Dataflow UDF] Name of JavaScript function to be called (default: '')"
  default = ""
}
