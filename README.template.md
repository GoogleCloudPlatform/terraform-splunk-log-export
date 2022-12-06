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