resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_dataflow_job" "splunk_dataflow_replay" {
  name              = local.dataflow_replay_job_name
  template_gcs_path = local.dataflow_deadletter_template_gcs_path
  temp_gcs_location = "gs://${var.splunk_dataflow_context.dataflow_temporary_bucket_name}/${local.dataflow_temporary_gcs_bucket_path}"
  machine_type      = var.dataflow_replay_job_machine_type
  max_workers       = var.dataflow_replay_job_machine_count
  parameters = {
    inputSubscription = var.splunk_dataflow_context.dataflow_output_deadletter_subscription
    outputTopic       = var.splunk_dataflow_context.dataflow_input_topic
  }
  region                = var.region
  network               = var.splunk_dataflow_context.splunk_network
  subnetwork            = var.splunk_dataflow_context.subnetwork_name
  ip_configuration      = "WORKER_IP_PRIVATE"
  service_account_email = var.splunk_dataflow_context.dataflow_worker_email
}