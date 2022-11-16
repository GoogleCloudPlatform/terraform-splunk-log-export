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
  type        = string
<<<<<<< HEAD
  description = "Project ID to deploy resources in"
=======
  description = "Project for Dataflow job deployment"
>>>>>>> Applyind terraform format to all files
}

variable "region" {
  type        = string
<<<<<<< HEAD
  description = "Region to deploy regional-resources into. This must match subnet's region if deploying into existing network (e.g. Shared VPC). See `subnet` parameter below"
=======
  description = "Region to deploy regional-resources into. This must match subnet's region if deploying into existing network (e.g. Shared VPC)"
>>>>>>> Applyind terraform format to all files
}

variable "create_network" {
  description = "Boolean value specifying if a new network needs to be created."
  default     = false
  type        = bool
}

variable "network" {
  description = "Network to deploy into"
  type        = string
}

variable "subnet" {
  type        = string
<<<<<<< HEAD
  description = "Subnet to deploy into. This is required when deploying into existing network (`create_network=false`) (e.g. Shared VPC)"
=======
  description = "Subnet to deploy into. This is required when deploying into existing network (e.g. Shared VPC)"
>>>>>>> Applyind terraform format to all files
  default     = ""
}

variable "primary_subnet_cidr" {
  type        = string
  description = "The CIDR Range of the primary subnet"
  default     = "10.128.0.0/20"
}

# Dashboard parameters

variable "scoping_project" {
  type        = string
<<<<<<< HEAD
  description = <<-EOF
                Cloud Monitoring scoping project ID to create dashboard under.
                This assumes a pre-existing scoping project whose metrics scope contains the `project` where dataflow job is to be deployed.
                See [Cloud Monitoring settings](https://cloud.google.com/monitoring/settings) for more details on scoping project.
                If parameter is empty, scoping project defaults to value of `project` parameter above.
                EOF
=======
  description = "Cloud Monitoring scoping project to create dashboard under. This assumes a pre-existing scoping project whose metrics scope contains the service project. If parameter is empty, scoping project defaults to service project where dataflow job is running."
>>>>>>> Applyind terraform format to all files
  default     = ""
}

# Log sink details

variable "log_filter" {
  type        = string
  description = "Log filter to use when exporting logs"
}

# Dataflow job output

variable "splunk_hec_url" {
  type        = string
  description = "Splunk HEC URL to write data to. Example: https://[MY_SPLUNK_IP_OR_FQDN]:8088"

  validation {
    condition     = can(regex("https?://.*(:[0-9]+)?", var.splunk_hec_url))
    error_message = "Splunk HEC url must of the form <protocol>://<host>:<port> ."
  }
}

variable "splunk_hec_token" {
  type        = string
  description = "Splunk HEC token"
  sensitive   = true
}

# Dataflow job parameters

variable "dataflow_template_version" {
  type        = string
  description = "(Optional) Dataflow template release version (default 'latest'). Override this for version pinning e.g. '2021-08-02-00_RC00'. Must specify version only since template GCS path will be deduced automatically: 'gs://dataflow-templates/`version`/Cloud_PubSub_to_Splunk'"
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
  type        = string
  description = "Dataflow job name. No spaces"
}

variable "dataflow_job_machine_type" {
  type        = string
  description = "(Optional) Dataflow job worker machine type (default 'n1-standard-4')"
  default     = "n1-standard-4"
}

variable "dataflow_job_machine_count" {
  description = "(Optional) Dataflow job max worker count (default 2)"
  type        = number
  default     = 2
}

variable "dataflow_job_parallelism" {
  description = "(Optional) Maximum parallel requests to Splunk (default 8)"
  type        = number
  default     = 8
}

variable "dataflow_job_batch_count" {
  description = "(Optional) Batch count of messages in single request to Splunk (default 50)"
  type        = number
  default     = 50
}

variable "dataflow_job_disable_certificate_validation" {
  description = "(Optional) Boolean to disable SSL certificate validation (default `false`)"
  type        = bool
  default     = false
}

variable "dataflow_job_udf_gcs_path" {
  type        = string
  description = "(Optional) GCS path for JavaScript file (default No UDF used)"
  default     = ""
}

variable "dataflow_job_udf_function_name" {
  type        = string
  description = "(Optional) Name of JavaScript function to be called (default No UDF used)"
  default     = ""
}
