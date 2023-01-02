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

project = "[MY_PROJECT]"
region  = "[MY_REGION]"

create_network      = false
network             = ""
subnet              = ""
primary_subnet_cidr = "10.128.0.0/20"

# Log sink details
log_filter = ""

# Dataflow job output
splunk_hec_url                      = ""
splunk_hec_token_source             = ""
splunk_hec_token                    = ""
splunk_hec_token_secret_id          = ""
splunk_hec_token_kms_encryption_key = ""

# Dataflow job parameters
dataflow_worker_service_account             = "export-pipeline-worker"
create_service_account                      = true
dataflow_job_name                           = "export-pipeline"
dataflow_job_machine_type                   = "n1-standard-4"
dataflow_job_machine_count                  = 2
dataflow_job_parallelism                    = 16
dataflow_job_batch_count                    = 10
dataflow_job_disable_certificate_validation = false
dataflow_job_udf_gcs_path                   = ""
dataflow_job_udf_function_name              = ""

# Dashboard parameters
scoping_project = "[MY_PROJECT]"

# Replay job settings
deploy_replay_job = false

# Security parameters
pubsub_kms_key_name = "projects/[MY_PROJECT]/locations/[MY_REGION]/keyRings/[MY_KEYRING_NAME]/cryptoKeys/[MY_KEY_NAME]"
gcs_kms_key_name    = "projects/[MY_PROJECT]/locations/[MY_REGION]/keyRings/[MY_KEYRING_NAME]/cryptoKeys/[MY_KEY_NAME]"
