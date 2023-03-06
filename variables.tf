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
  description = "Project ID to deploy resources in"
}

variable "region" {
  type        = string
  description = "Region to deploy regional-resources into. This must match subnet's region if deploying into existing network (e.g. Shared VPC). See `subnet` parameter below"
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
  description = "Subnet to deploy into. This is required when deploying into existing network (`create_network=false`) (e.g. Shared VPC)"
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
  description = <<-EOF
                Cloud Monitoring scoping project ID to create dashboard under.
                This assumes a pre-existing scoping project whose metrics scope contains the `project` where dataflow job is to be deployed.
                See [Cloud Monitoring settings](https://cloud.google.com/monitoring/settings) for more details on scoping project.
                If parameter is empty, scoping project defaults to value of `project` parameter above.
                EOF
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

variable "splunk_hec_token_source" {
  type        = string
  default     = "PLAINTEXT"
  description = "Define in which type HEC token is provided. Possible options: [PLAINTEXT, KMS, SECRET_MANAGER]."

  validation {
    condition     = contains(["PLAINTEXT", "KMS", "SECRET_MANAGER"], var.splunk_hec_token_source)
    error_message = "Valid values for var: dataflow_token_source are ('PLAINTEXT', 'KMS', 'SECRET_MANAGER')."
  }
}

variable "splunk_hec_token" {
  type        = string
  description = "Splunk HEC token. Must be defined if `splunk_hec_token_source` if type of `PLAINTEXT` or `KMS`."
  default     = ""
  sensitive   = true
}

variable "splunk_hec_token_kms_encryption_key" {
  type        = string
  description = "The Cloud KMS key to decrypt the HEC token string. Required if `splunk_hec_token_source` is type of KMS"
  default     = ""
  validation {
    condition     = can(regex("^projects\\/[^\\n\\r\\/]+\\/locations\\/[^\\n\\r\\/]+\\/keyRings\\/[^\\n\\r\\/]+\\/cryptoKeys\\/[^\\n\\r\\/]+$", var.splunk_hec_token_kms_encryption_key)) || var.splunk_hec_token_kms_encryption_key == ""
    error_message = "HEC token encryption key must match rex: '^projects\\/[^\\n\\r\\/]+\\/locations\\/[^\\n\\r\\/]+\\/keyRings\\/[^\\n\\r\\/]+\\/cryptoKeys\\/[^\\n\\r\\/]+$' pattern."
  }
}

# TODO: Make cross variable validation once https://github.com/hashicorp/terraform/issues/25609 is resolved
variable "splunk_hec_token_secret_id" {
  type        = string
  description = "Id of the Secret for Splunk HEC token. Required if `splunk_hec_token_source` is type of SECRET_MANAGER"
  default     = ""
  validation {
    condition     = can(regex("^projects\\/[^\\n\\r\\/]+\\/secrets\\/[^\\n\\r\\/]+\\/versions\\/[^\\n\\r\\/]+$", var.splunk_hec_token_secret_id)) || var.splunk_hec_token_secret_id == ""
    error_message = "HEC token secret id key must match rex: '^projects\\/[^\\n\\r\\/]+\\/secrets\\/[^\\n\\r\\/]+\\/versions\\/[^\\n\\r\\/]+$' pattern."
  }
}

# Dataflow job parameters

variable "dataflow_template_version" {
  type        = string
  description = "Dataflow template release version (default 'latest'). Override this for version pinning e.g. '2021-08-02-00_RC00'. Must specify version only since template GCS path will be deduced automatically: 'gs://dataflow-templates/`version`/Cloud_PubSub_to_Splunk'"
  default     = "latest"
}

variable "dataflow_worker_service_account" {
  type        = string
  description = "Name of Dataflow worker service account to be created and used to execute job operations. In the default case of creating a new service account (`use_externally_managed_dataflow_sa=false`), this parameter must be 6-30 characters long, and match the regular expression [a-z]([-a-z0-9]*[a-z0-9]). If the parameter is empty, worker service account defaults to project's Compute Engine default service account. If using external service account (`use_externally_managed_dataflow_sa=true`), this parameter must be the full email address of the external service account."
  default     = ""

  validation {
    condition = (var.dataflow_worker_service_account == "" ||
      can(regex("[a-z]([-a-z0-9]*[a-z0-9])", var.dataflow_worker_service_account)) ||
      can(regex("[a-z]([-a-z0-9]*[a-z0-9])@[a-z]([-a-z0-9]*[a-z0-9])(\\.iam)?.gserviceaccount.com$", var.dataflow_worker_service_account))
    )
    error_message = "Dataflow worker service account id must match the regular expression '[a-z]([-a-z0-9]*[a-z0-9])' in case of service account name, or '[a-z]([-a-z0-9]*[a-z0-9])@[a-z]([-a-z0-9]*[a-z0-9])(\\.iam)?.gserviceaccount.com$' in case of service account email address."
  }
}

variable "dataflow_job_name" {
  type        = string
  description = "Dataflow job name. No spaces"
}

variable "dataflow_job_machine_type" {
  type        = string
  description = "Dataflow job worker machine type"
  default     = "n1-standard-4"
}

variable "dataflow_job_machine_count" {
  description = "Dataflow job max worker count"
  type        = number
  default     = 2
}

variable "dataflow_job_parallelism" {
  description = "Maximum parallel requests to Splunk"
  type        = number
  default     = 8
}

variable "dataflow_job_batch_count" {
  description = "Batch count of messages in single request to Splunk"
  type        = number
  default     = 50
}

variable "dataflow_job_disable_certificate_validation" {
  description = "Boolean to disable SSL certificate validation"
  type        = bool
  default     = false
}

variable "dataflow_job_udf_gcs_path" {
  type        = string
  description = "GCS path for JavaScript file"
  default     = ""
}

variable "dataflow_job_udf_function_name" {
  type        = string
  description = "Name of JavaScript function to be called"
  default     = ""
}

variable "deploy_replay_job" {
  type        = bool
  description = "Determines if replay pipeline should be deployed or not"
  default     = false
}

variable "use_externally_managed_dataflow_sa" {
  type        = bool
  default     = false
  description = "Determines if the worker service account provided by `dataflow_worker_service_account` variable should be created by this module (default) or is managed outside of the module. In the latter case, user is expected to apply and manage the service account IAM permissions over external resources (e.g. Cloud KMS key or Secret version) before running this module."
}

variable "gcs_kms_key_name" {
  type        = string
  description = <<EOF
    The `id` of a Cloud KMS key that will be used to encrypt objects inserted into temporary bucket.
    User must sure that `roles/cloudkms.cryptoKeyEncrypterDecrypter` is granted to this key for Cloud Storage Service Identity.
  EOF
  default     = ""
  validation {
    condition     = can(regex("^projects\\/[^\\n\\r\\/]+\\/locations\\/[^\\n\\r\\/]+\\/keyRings\\/[^\\n\\r\\/]+\\/cryptoKeys\\/[^\\n\\r\\/]+$", var.gcs_kms_key_name)) || var.gcs_kms_key_name == ""
    error_message = "Cloud Storage KMS key name must match: '^projects\\/[^\\n\\r\\/]+\\/locations\\/[^\\n\\r\\/]+\\/keyRings\\/[^\\n\\r\\/]+\\/cryptoKeys\\/[^\\n\\r\\/]+$' pattern."
  }
}
