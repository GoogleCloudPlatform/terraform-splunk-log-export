<!-- BEGIN_TF_DOCS -->
# Terraform templates for Google Cloud log export to Splunk

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_dataflow_job_name"></a> [dataflow_job_name](#input_dataflow_job_name) | Dataflow job name. No spaces | `string` |
| <a name="input_log_filter"></a> [log_filter](#input_log_filter) | Log filter to use when exporting logs | `string` |
| <a name="input_network"></a> [network](#input_network) | Network to deploy into | `string` |
| <a name="input_project"></a> [project](#input_project) | Project ID to deploy resources in | `string` |
| <a name="input_region"></a> [region](#input_region) | Region to deploy regional-resources into. This must match subnet's region if deploying into existing network (e.g. Shared VPC). See `subnet` parameter below | `string` |
| <a name="input_splunk_hec_url"></a> [splunk_hec_url](#input_splunk_hec_url) | Splunk HEC URL to write data to. Example: https://[MY_SPLUNK_IP_OR_FQDN]:8088 | `string` |
| <a name="input_create_network"></a> [create_network](#input_create_network) | Boolean value specifying if a new network needs to be created. | `bool` |
| <a name="input_dataflow_job_batch_count"></a> [dataflow_job_batch_count](#input_dataflow_job_batch_count) | (Optional) Batch count of messages in single request to Splunk (default 50) | `number` |
| <a name="input_dataflow_job_disable_certificate_validation"></a> [dataflow_job_disable_certificate_validation](#input_dataflow_job_disable_certificate_validation) | (Optional) Boolean to disable SSL certificate validation (default `false`) | `bool` |
| <a name="input_dataflow_job_machine_count"></a> [dataflow_job_machine_count](#input_dataflow_job_machine_count) | (Optional) Dataflow job max worker count (default 2) | `number` |
| <a name="input_dataflow_job_machine_type"></a> [dataflow_job_machine_type](#input_dataflow_job_machine_type) | (Optional) Dataflow job worker machine type (default 'n1-standard-4') | `string` |
| <a name="input_dataflow_job_parallelism"></a> [dataflow_job_parallelism](#input_dataflow_job_parallelism) | (Optional) Maximum parallel requests to Splunk (default 8) | `number` |
| <a name="input_dataflow_job_udf_function_name"></a> [dataflow_job_udf_function_name](#input_dataflow_job_udf_function_name) | (Optional) Name of JavaScript function to be called (default No UDF used) | `string` |
| <a name="input_dataflow_job_udf_gcs_path"></a> [dataflow_job_udf_gcs_path](#input_dataflow_job_udf_gcs_path) | (Optional) GCS path for JavaScript file (default No UDF used) | `string` |
| <a name="input_dataflow_template_version"></a> [dataflow_template_version](#input_dataflow_template_version) | (Optional) Dataflow template release version (default 'latest'). Override this for version pinning e.g. '2021-08-02-00_RC00'. Must specify version only since template GCS path will be deduced automatically: 'gs://dataflow-templates/`version`/Cloud_PubSub_to_Splunk' | `string` |
| <a name="input_dataflow_worker_service_account"></a> [dataflow_worker_service_account](#input_dataflow_worker_service_account) | (Optional) Name of worker service account to be created and used to execute job operations. Must be 6-30 characters long, and match the regular expression [a-z]([-a-z0-9]*[a-z0-9]). If parameter is empty, worker service account defaults to project's Compute Engine default service account. | `string` |
| <a name="input_primary_subnet_cidr"></a> [primary_subnet_cidr](#input_primary_subnet_cidr) | The CIDR Range of the primary subnet | `string` |
| <a name="input_scoping_project"></a> [scoping_project](#input_scoping_project) | Cloud Monitoring scoping project ID to create dashboard under.<br>This assumes a pre-existing scoping project whose metrics scope contains the `project` where dataflow job is to be deployed.<br>See [Cloud Monitoring settings](https://cloud.google.com/monitoring/settings) for more details on scoping project.<br>If parameter is empty, scoping project defaults to value of `project` parameter above. | `string` |
| <a name="input_splunk_hec_token"></a> [splunk_hec_token](#input_splunk_hec_token) | (Optional) Splunk HEC token. Must be defined if `splunk_hec_token_source` if type of `PLAINTEXT` or `KMS`. | `string` |
| <a name="input_splunk_hec_token_kms_encryption_key"></a> [splunk_hec_token_kms_encryption_key](#input_splunk_hec_token_kms_encryption_key) | (Optional) The Cloud KMS key to decrypt the HEC token string. Required if `splunk_hec_token_source` is type of KMS (default: '') | `string` |
| <a name="input_splunk_hec_token_secret_id"></a> [splunk_hec_token_secret_id](#input_splunk_hec_token_secret_id) | (Optional) Id of the Secret for Splunk HEC token. Required if `splunk_hec_token_source` is type of SECRET_MANAGER (default: '') | `string` |
| <a name="input_splunk_hec_token_source"></a> [splunk_hec_token_source](#input_splunk_hec_token_source) | (Optional) Define in which type HEC token is provided. Possible options: [PLAINTEXT, KMS, SECRET_MANAGER]. Default: PLAINTEXT | `string` |
| <a name="input_subnet"></a> [subnet](#input_subnet) | Subnet to deploy into. This is required when deploying into existing network (`create_network=false`) (e.g. Shared VPC) | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_dataflow_input_topic"></a> [dataflow_input_topic](#output_dataflow_input_topic) | n/a |
| <a name="output_dataflow_job_id"></a> [dataflow_job_id](#output_dataflow_job_id) | n/a |
| <a name="output_dataflow_log_export_dashboard"></a> [dataflow_log_export_dashboard](#output_dataflow_log_export_dashboard) | n/a |
| <a name="output_dataflow_output_deadletter_subscription"></a> [dataflow_output_deadletter_subscription](#output_dataflow_output_deadletter_subscription) | n/a |

#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.14.4 |
| <a name="requirement_google"></a> [google](#requirement_google) | >= 3.54.0 |
| <a name="requirement_random"></a> [random](#requirement_random) | >= 2.1.0 |

Terraform scripts for deploying log export to Splunk per Google Cloud reference guide:</br>
[Deploying production-ready log exports to Splunk using Dataflow](https://cloud.google.com/architecture/deploying-production-ready-log-exports-to-splunk-using-dataflow)
.

Resources created include an optional [Cloud Monitoring custom dashboard](#monitoring-dashboard-batteries-included) to monitor your log export operations. For more details on custom metrics in Splunk Dataflow template, see [New observability features for your Splunk Dataflow streaming pipelines](https://cloud.google.com/blog/products/data-analytics/simplify-your-splunk-dataflow-ops-with-improved-pipeline-observability).

These deployment templates are provided as is, without warranty. See [Copyright & License](#copyright-&-license) below.

### Architecture Diagram

![Architecture Diagram of Log Export to Splunk](./images/logging_export_to_splunk.png)

Terraform scripts for deploying log export to Splunk per Google Cloud reference guide:</br>
[Deploying production-ready log exports to Splunk using Dataflow](https://cloud.google.com/architecture/deploying-production-ready-log-exports-to-splunk-using-dataflow)
.

Resources created include an optional [Cloud Monitoring custom dashboard](#monitoring-dashboard-batteries-included) to monitor your log export operations. For more details on custom metrics in Splunk Dataflow template, see [New observability features for your Splunk Dataflow streaming pipelines](https://cloud.google.com/blog/products/data-analytics/simplify-your-splunk-dataflow-ops-with-improved-pipeline-observability).

These deployment templates are provided as is, without warranty. See [Copyright & License](#copyright-&-license) below.

### Architecture Diagram

![Architecture Diagram of Log Export to Splunk](./images/logging_export_to_splunk.png)

### Monitoring Dashboard (Batteries Included)

Deployment templates include an optional Cloud Monitoring custom dashboard to monitor your log export operations:
![Ops Dashboard of Log Export to Splunk](./images/logging_export_ops_dashboard.png)

### Permissions Required

At a minimum, you must have the following roles before you deploy the resources in this Terraform:
- Logs Configuration Writer (`roles/logging.configWriter`) at the project and/or organization level
- Compute Network Admin (`roles/compute.networkAdmin`) at the project level
- Compute Security Admin (`roles/compute.securityAdmin`) at the project level
- Dataflow Admin (`roles/dataflow.admin`) at the project level
- Pub/Sub Admin (`roles/pubsub.admin`) at the project level
- Storage Admin (`roles/storage.admin`) at the project level

To ensure proper pipeline operation, Terraform creates necessary IAM bindings at the resources level as part of this deployment to grant access between newly created resources. For example, Log sink writer is granted Pub/Sub Publisher role over the input topic which collects all the logs, and Dataflow worker service account is granted both Pub/Sub subscriber over the input subscription, and Pub/Sub Publisher role over the deadletter topic.

**Note about Dataflow permissions**: You must also have permission to impersonate Dataflow worker service account in order to attach that service account to Compute Engine VMs which will execute pipeline operations. In case of default worker service account (i.e. your project's Compute Engine default service account), ensure you have `iam.serviceAccounts.actAs` permission over Compute Engine default service account in your project. For security purposes, this Terraform does not modify access to your existing Compute Engine default service account due to risk of granting broad permissions. On the other hand, if you choose to use a user-managed worker service account (by setting `dataflow_worker_service_account` template parameter), this Terraform will add necessary permission over the new service account. The former approach, i.e. user-managed service account, is recommended in order to use a minimally-scoped service account dedicated for this pipeline, and to have impersonation permission managed for you by this Terraform.

**Please Note** that if variable `dataflow_worker_service_account` is not provided. Default Compute Engine service account would be modified by the module.

See [Security and permissions for pipelines](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#security_and_permissions_for_pipelines_on) to learn more about Dataflow service accounts and their permissions.

### Getting Started

Take note of dashboard_id value.

2. Visit newly created Monitoring Dashboard in Cloud Console by replacing dashboard_id in the following URL: https://console.cloud.google.com/monitoring/dashboards/builder/{dashboard_id}

#### Deploy replay pipeline

In the `replay.tf` file, uncomment the code under `splunk_dataflow_replay` and follow the sequence of `terraform plan` and `terraform apply`.

Once the replay pipeline is no longer needed (the number of messages in the PubSub deadletter topic are at 0), comment out `splunk_dataflow_replay` and follow the `plan` and `apply` sequence above.

### Cleanup

To delete resources created by Terraform, run the following then confirm:
``` shell
$ terraform destroy
```

### TODOs

* ~~Support KMS-encrypted HEC token~~
* Expose logging level knob
* ~~Create replay pipeline~~
* ~~Create secure network for self-contained setup if existing network is not provided~~
* ~~Add Cloud Monitoring dashboard~~


### Authors

* **Roy Arsan** - [rarsan](https://github.com/rarsan)
* **Nick Predey** - [npredey](https://github.com/npredey)
* **Igor Lakhtenkov** - [Lakhtenkov-iv](https://github.com/Lakhtenkov-iv)

### Copyright & License

Copyright 2021 Google LLC

Terraform templates for Google Cloud Log Export to Splunk are licensed under the Apache license, v2.0. Details can be found in [LICENSE](./LICENSE) file.
<!-- END_TF_DOCS -->