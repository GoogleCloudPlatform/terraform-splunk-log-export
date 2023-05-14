# Terraform templates for Google Cloud log export to Splunk

Terraform scripts for deploying log export to Splunk per Google Cloud reference guide:</br>
[Deploying production-ready log exports to Splunk using Dataflow](https://cloud.google.com/architecture/deploying-production-ready-log-exports-to-splunk-using-dataflow)
.

Resources created include an optional [Cloud Monitoring custom dashboard](#monitoring-dashboard-batteries-included) to monitor your log export operations. For more details on custom metrics in Splunk Dataflow template, see [New observability features for your Splunk Dataflow streaming pipelines](https://cloud.google.com/blog/products/data-analytics/simplify-your-splunk-dataflow-ops-with-improved-pipeline-observability).

These deployment templates are provided as is, without warranty. See [Copyright & License](#copyright-&-license) below.

### Architecture Diagram

![Architecture Diagram of Log Export to Splunk](./images/logging_export_to_splunk.png)

### Terraform Module
<!-- BEGIN_TF_DOCS -->
#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dataflow_job_name"></a> [dataflow_job_name](#input_dataflow_job_name) | Dataflow job name. No spaces | `string` | n/a | yes |
| <a name="input_log_filter"></a> [log_filter](#input_log_filter) | Log filter to use when exporting logs | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input_network) | Network to deploy into | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input_project) | Project ID to deploy resources in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input_region) | Region to deploy regional-resources into. This must match subnet's region if deploying into existing network (e.g. Shared VPC). See `subnet` parameter below | `string` | n/a | yes |
| <a name="input_splunk_hec_url"></a> [splunk_hec_url](#input_splunk_hec_url) | Splunk HEC URL to write data to. Example: https://[MY_SPLUNK_IP_OR_FQDN]:8088 | `string` | n/a | yes |
| <a name="input_create_network"></a> [create_network](#input_create_network) | Boolean value specifying if a new network needs to be created. | `bool` | `false` | no |
| <a name="input_dataflow_job_batch_count"></a> [dataflow_job_batch_count](#input_dataflow_job_batch_count) | Batch count of messages in single request to Splunk | `number` | `50` | no |
| <a name="input_dataflow_job_disable_certificate_validation"></a> [dataflow_job_disable_certificate_validation](#input_dataflow_job_disable_certificate_validation) | Boolean to disable SSL certificate validation | `bool` | `false` | no |
| <a name="input_dataflow_job_machine_count"></a> [dataflow_job_machine_count](#input_dataflow_job_machine_count) | Dataflow job max worker count | `number` | `2` | no |
| <a name="input_dataflow_job_machine_type"></a> [dataflow_job_machine_type](#input_dataflow_job_machine_type) | Dataflow job worker machine type | `string` | `"n1-standard-4"` | no |
| <a name="input_dataflow_job_parallelism"></a> [dataflow_job_parallelism](#input_dataflow_job_parallelism) | Maximum parallel requests to Splunk | `number` | `8` | no |
| <a name="input_dataflow_job_udf_function_name"></a> [dataflow_job_udf_function_name](#input_dataflow_job_udf_function_name) | Name of JavaScript function to be called | `string` | `""` | no |
| <a name="input_dataflow_job_udf_gcs_path"></a> [dataflow_job_udf_gcs_path](#input_dataflow_job_udf_gcs_path) | GCS path for JavaScript file | `string` | `""` | no |
| <a name="input_dataflow_template_version"></a> [dataflow_template_version](#input_dataflow_template_version) | Dataflow template release version (default 'latest'). Override this for version pinning e.g. '2021-08-02-00_RC00'. Must specify version only since template GCS path will be deduced automatically: 'gs://dataflow-templates/`version`/Cloud_PubSub_to_Splunk' | `string` | `"latest"` | no |
| <a name="input_dataflow_worker_service_account"></a> [dataflow_worker_service_account](#input_dataflow_worker_service_account) | Name of Dataflow worker service account to be created and used to execute job operations. In the default case of creating a new service account (`use_externally_managed_dataflow_sa=false`), this parameter must be 6-30 characters long, and match the regular expression [a-z]([-a-z0-9]*[a-z0-9]). If the parameter is empty, worker service account defaults to project's Compute Engine default service account. If using external service account (`use_externally_managed_dataflow_sa=true`), this parameter must be the full email address of the external service account. | `string` | `""` | no |
| <a name="input_deploy_replay_job"></a> [deploy_replay_job](#input_deploy_replay_job) | Determines if replay pipeline should be deployed or not | `bool` | `false` | no |
| <a name="input_gcs_kms_key_name"></a> [gcs_kms_key_name](#input_gcs_kms_key_name) | Cloud KMS key resource ID, to be used as default encryption key for the temporary storage bucket used by the Dataflow job.<br>    If set, make sure to pre-authorize Cloud Storage service agent associated with that bucket to use that key for encrypting and decrypting. | `string` | `""` | no |
| <a name="input_primary_subnet_cidr"></a> [primary_subnet_cidr](#input_primary_subnet_cidr) | The CIDR Range of the primary subnet | `string` | `"10.128.0.0/20"` | no |
| <a name="input_scoping_project"></a> [scoping_project](#input_scoping_project) | Cloud Monitoring scoping project ID to create dashboard under.<br>This assumes a pre-existing scoping project whose metrics scope contains the `project` where dataflow job is to be deployed.<br>See [Cloud Monitoring settings](https://cloud.google.com/monitoring/settings) for more details on scoping project.<br>If parameter is empty, scoping project defaults to value of `project` parameter above. | `string` | `""` | no |
| <a name="input_splunk_hec_token"></a> [splunk_hec_token](#input_splunk_hec_token) | Splunk HEC token. Must be defined if `splunk_hec_token_source` if type of `PLAINTEXT` or `KMS`. | `string` | `""` | no |
| <a name="input_splunk_hec_token_kms_encryption_key"></a> [splunk_hec_token_kms_encryption_key](#input_splunk_hec_token_kms_encryption_key) | The Cloud KMS key to decrypt the HEC token string. Required if `splunk_hec_token_source` is type of KMS | `string` | `""` | no |
| <a name="input_splunk_hec_token_secret_id"></a> [splunk_hec_token_secret_id](#input_splunk_hec_token_secret_id) | Id of the Secret for Splunk HEC token. Required if `splunk_hec_token_source` is type of SECRET_MANAGER | `string` | `""` | no |
| <a name="input_splunk_hec_token_source"></a> [splunk_hec_token_source](#input_splunk_hec_token_source) | Define in which type HEC token is provided. Possible options: [PLAINTEXT, KMS, SECRET_MANAGER]. | `string` | `"PLAINTEXT"` | no |
| <a name="input_subnet"></a> [subnet](#input_subnet) | Subnet to deploy into. This is required when deploying into existing network (`create_network=false`) (e.g. Shared VPC) | `string` | `""` | no |
| <a name="input_subnet_complete_url"></a> [subnet_complete_url](#input_subnet) | Complete URL of the Subnet to deploy into. This is required when deploying into a Subnet of a shared VPC network residing in a separate project. | `string` | `""` | no |
| <a name="input_use_externally_managed_dataflow_sa"></a> [use_externally_managed_dataflow_sa](#input_use_externally_managed_dataflow_sa) | Determines if the worker service account provided by `dataflow_worker_service_account` variable should be created by this module (default) or is managed outside of the module. In the latter case, user is expected to apply and manage the service account IAM permissions over external resources (e.g. Cloud KMS key or Secret version) before running this module. | `bool` | `false` | no |
#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_dataflow_input_topic"></a> [dataflow_input_topic](#output_dataflow_input_topic) | n/a |
| <a name="output_dataflow_job_id"></a> [dataflow_job_id](#output_dataflow_job_id) | n/a |
| <a name="output_dataflow_log_export_dashboard"></a> [dataflow_log_export_dashboard](#output_dataflow_log_export_dashboard) | n/a |
| <a name="output_dataflow_output_deadletter_subscription"></a> [dataflow_output_deadletter_subscription](#output_dataflow_output_deadletter_subscription) | n/a |
<!-- END_TF_DOCS -->

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

#### Dataflow permissions

The Dataflow worker service service account is the identity used by the Dataflow worker VMs. This module offers three options in terms of which worker service account to use and how to manage their IAM permissions:

1. Module uses your project's [Compute Engine default service account](https://cloud.google.com/compute/docs/access/service-accounts#default_service_account) as Dataflow worker service account, and manages any required IAM permissions. The module grants that service account necessary IAM roles such as `roles/dataflow.worker` and IAM permissions over Google Cloud resources required by the job such as Pub/Sub, Cloud Storage, and secret or KMS if applicable. This is the **default behavior**.

2. Module creates a dedicated service account to be used as Dataflow worker service account, and manages any required IAM permissions. The module grants that service account necessary IAM roles such as `roles/dataflow.worker` and IAM permissions over Google Cloud resources required by the job such as Pub/Sub, Cloud Storage, and secret or KMS key if applicable. To use this option, set `dataflow_worker_service_account` to the name of this new service account.

3. Module uses a service account managed outside of the module. The module grants that service account necessary IAM permissions over Google Cloud resources created by the module such as Pub/Sub, Cloud Storage. You must grant this service account the required IAM roles (`roles/dataflow.worker` ) and IAM permissions over external resources such as any provided secret or KMS key (more below), _before_ running this module. To use this option, set `use_externally_managed_dataflow_sa` to `true` and set `dataflow_worker_service_account` to the email address of this external service account.

For production workloads, as a security best practice, it's recommended to use option 2 or 3, both of which rely on user-managed worker service account, instead of the Compute Engine default service account. This ensures a minimally-scoped service account dedicated for this pipeline.

For option 3, make sure to grant:
- The provided Dataflow service account the following roles:
    - `roles/dataflow.worker`
    - `roles/secretmanager.secretAccessor` on secret - if `SECRET_MANAGER` HEC token source is used
    - `roles/cloudkms.cryptoKeyDecrypter` on KMS key- if `KMS` HEC token source is used

For option 1 & 3, make sure to grant:
- Your user account or service account used to run Terraform the following role:
    - `roles/iam.serviceAccountUser` on the Dataflow service account in order to impersonate the service account. See following note for more details.

**Note about Dataflow worker service account impersonation**: To run this Terraform module, you must have permission to impersonate the Dataflow worker service account in order to attach that service account to Dataflow worker VMs. In case of the default Dataflow worker service account (Option 1), ensure you have `iam.serviceAccounts.actAs` permission over Compute Engine default service account in your project. For security purposes, this Terraform does not modify access to your existing Compute Engine default service account due to risk of granting broad permissions. On the other hand, if you choose to create and use a user-managed worker service account (Option 2) by setting `dataflow_worker_service_account` (and keeping `use_externally_managed_dataflow_sa` = `false`), this Terraform will add necessary impersonation permission over the new service account.

See [Security and permissions for pipelines](https://cloud.google.com/dataflow/docs/concepts/security-and-permissions#security_and_permissions_for_pipelines_on) to learn more about Dataflow service accounts and their permissions.

### Getting Started

#### Requirements
* Terraform 0.13+
* Splunk Dataflow template 2022-04-25-00_RC00 or later

#### Enabling APIs
Before deploying the Terraform in a Google Cloud Platform Project, the following APIs must be enabled:
* Compute Engine API
* Dataflow API

For information on enabling Google Cloud Platform APIs, please see [Getting Started: Enabling APIs](https://cloud.google.com/apis/docs/getting-started#enabling_apis).

#### Setup working directory

1. Copy placeholder vars file `sample.tfvars` into new `terraform.tfvars` to hold your own settings.
2. Update placeholder values in `terraform.tfvars` to correspond to your GCP environment and desired settings. See [list of input parameters](#configurable-parameters) above.
3. Initialize Terraform working directory and download plugins by running:

```shell
$ terraform init
```

#### Authenticate with GCP
Note: You can skip this step if this module is inheriting the Terraform Google provider (e.g. from a parent module) with pre-configured credentials.

```shell
$ gcloud auth application-default login --project <ENTER_YOUR_PROJECT_ID>
```

This assumes you are running Terraform on your workstation with your own identity. For other methods to authenticate such as using a Terraform-specific service account, see [Google Provider authentication docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication).

#### Deploy log export pipeline

```shell
$ terraform plan
$ terraform apply
```

#### View log export monitoring dashboard

1. Retrieve dashboard id from terraform output
```shell
$ terraform output dataflow_log_export_dashboard
```
The output is of the form `"projects/{project_id_or_number}/dashboards/{dashboard_id}"`.

Take note of dashboard_id value.

2. Visit newly created Monitoring Dashboard in Cloud Console by replacing dashboard_id in the following URL: https://console.cloud.google.com/monitoring/dashboards/builder/{dashboard_id}

#### Deploy replay pipeline when needed

The replay pipeline is not deployed by default; instead it is only used to move failed messages from the PubSub deadletter subscription back to the input topic, in order to be redelivered by the main log export pipeline (as depicted in above [diagram](#architecture-diagram)). Refer to [Handling delivery failures](https://cloud.google.com/architecture/deploying-production-ready-log-exports-to-splunk-using-dataflow#handling_delivery_failures) for more detail.

**Caution**: Make sure to deploy replay pipeline only after the root cause of the delivery failure has been fixed. Otherwise, the replay pipeline will cause an infinite loop where failed messages are sent back for re-delivery, only to fail again, causing an infinite loop and wasted resources. For that same reason, make sure to tear down the replay pipeline once the failed messages from the deadletter subscription are all processed or replayed.

1. To deploy replay pipeline, set `deploy_replay_job` variable to `true`, then follow the sequence of `terraform plan` and `terraform apply`.
2. Once the replay pipeline is no longer needed (i.e. the number of messages in the PubSub deadletter subscription is 0), set `deploy_replay_job` variable to `false`, then follow the sequence of `terraform plan` and `terraform apply`.

### Cleanup

To delete resources created by Terraform, run the following then confirm:
``` shell
$ terraform destroy
```

### Using customer-managed encryption keys (CMEK)

For those who require CMEK, this module accepts CMEK keys for the following services:
- Cloud Storage: see `gcs_kms_key_name` input parameter. You are responsible for granting Cloud Storage service agent the role Cloud KMS CryptoKey Encrypter/Decrypter (`roles/cloudkms.cryptoKeyEncrypterDecrypter`) in order to use the provided Cloud KMS key for encrypting and decrypting objects in the temporary storage bucket. The Cloud KMS key must be available in the location that the temporary bucket is created in (specified in `var.region`). For more details, see [Use customer-managed encryption keys](https://cloud.google.com/storage/docs/encryption/using-customer-managed-keys) in Cloud Storage docs.

### Authors

* **Roy Arsan** - [rarsan](https://github.com/rarsan)
* **Nick Predey** - [npredey](https://github.com/npredey)
* **Igor Lakhtenkov** - [Lakhtenkov-iv](https://github.com/Lakhtenkov-iv)

### Copyright & License

Copyright 2021 Google LLC

Terraform templates for Google Cloud Log Export to Splunk are licensed under the Apache license, v2.0. Details can be found in [LICENSE](./LICENSE) file.
