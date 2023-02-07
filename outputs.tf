output "dataflow_job_id" {
  value = google_dataflow_job.dataflow_job.job_id
}

output "dataflow_input_topic" {
  value = google_pubsub_topic.dataflow_input_pubsub_topic.name
}

output "dataflow_output_deadletter_subscription" {
  value = google_pubsub_subscription.dataflow_deadletter_pubsub_sub.name
}

output "dataflow_log_export_dashboard" {
  value = google_monitoring_dashboard.splunk-export-pipeline-dashboard.id
}
