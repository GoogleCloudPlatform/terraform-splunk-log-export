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

resource "google_monitoring_group" "splunk-export-pipeline-group" {
  count  = var.workspace != "" ? 1 : 0

  display_name = "Splunk Log Export Group"
  project = var.workspace

  filter = "resource.metadata.name=starts_with(\"${var.dataflow_job_name}\")"
}

resource "google_monitoring_dashboard" "splunk-export-pipeline-dashboard" {
  count  = var.workspace != "" ? 1 : 0

  project = var.workspace
  dashboard_json = <<EOF
{
  "displayName": "Splunk Log Export Ops",
  "gridLayout": {
    "columns": "3",
    "widgets": [
      {
        "title": "Log Sink Volume (Hourly)",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"logging.googleapis.com/exports/byte_count\" resource.type=\"logging_sink\" resource.label.\"name\"=\"${local.project_log_sink_name}\"",
              "aggregation": {
                "alignmentPeriod": "3600s",
                "perSeriesAligner": "ALIGN_SUM",
                "crossSeriesReducer": "REDUCE_SUM"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_LINE"
          }
        }
      },
      {
        "title": "Total Logs Exported (Hourly)",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"dataflow.googleapis.com/job/elements_produced_count\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\" metric.label.\"ptransform\"=\"WriteToSplunk/Create KV pairs/Inject Keys\"",
              "aggregation": {
                "alignmentPeriod": "3600s",
                "perSeriesAligner": "ALIGN_SUM",
                "crossSeriesReducer": "REDUCE_SUM"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_LINE"
          }
        }
      },
      {
        "title": "Current Logs in Deadletter",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=monitoring.regex.full_match(\"${local.dataflow_output_deadletter_sub_name}\")",
              "aggregation": {
                "alignmentPeriod": "60s",
                "perSeriesAligner": "ALIGN_NEXT_OLDER",
                "crossSeriesReducer": "REDUCE_SUM"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_LINE"
          },
          "thresholds": [
            {
              "color": "RED",
              "direction": "ABOVE"
            },
            {
              "color": "RED",
              "direction": "BELOW"
            },
            {
              "color": "YELLOW",
              "direction": "ABOVE"
            }
          ]
        }
      },
      {
        "title": "Logs Throughput from Log Sink (Input Rate)",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"logging.googleapis.com/exports/log_entry_count\" resource.type=\"logging_sink\" resource.label.\"name\"=\"${local.project_log_sink_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Logs Throughput to Splunk (Output Rate)",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"dataflow.googleapis.com/job/elements_produced_count\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\" metric.label.\"pcollection\"=\"WriteToSplunk/Create KV pairs/Inject Keys.out0\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Backlog Size",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"pubsub.googleapis.com/subscription/num_undelivered_messages\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=\"${local.dataflow_input_subscription_name}\"",
              "aggregation": {
                "alignmentPeriod": "60s",
                "perSeriesAligner": "ALIGN_NEXT_OLDER",
                "crossSeriesReducer": "REDUCE_SUM"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_BAR"
          },
          "thresholds": [
            {
              "value": 10000,
              "color": "RED",
              "direction": "ABOVE"
            },
            {
              "value": 1000,
              "color": "YELLOW",
              "direction": "ABOVE"
            }
          ]
        }
      },
      {
        "title": "Total Messages Exported (All-time)",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"custom.googleapis.com/dataflow/outbound-successful-events\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\"",
              "aggregation": {
                "alignmentPeriod": "60s",
                "perSeriesAligner": "ALIGN_MAX",
                "crossSeriesReducer": "REDUCE_MAX"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_LINE"
          }
        }
      },
      {
        "title": "Total Messages Failed (All-time)",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/dataflow/outbound-failed-events\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_SUM"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            },
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"custom.googleapis.com/dataflow/total-failed-messages\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_SUM"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Total Messages Replayed (All-time)",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"dataflow.googleapis.com/job/elements_produced_count\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_replay_job_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Log Sink Exported Count",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"logging.googleapis.com/exports/log_entry_count\" resource.type=\"logging_sink\"  resource.label.\"name\"=\"${local.project_log_sink_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              },
              "plotType": "STACKED_BAR",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Log Sink Exported Volume",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"logging.googleapis.com/exports/byte_count\" resource.type=\"logging_sink\"  resource.label.\"name\"=\"${local.project_log_sink_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "STACKED_BAR",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Log Sink Error Count",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"logging.googleapis.com/exports/error_count\" resource.type=\"logging_sink\" resource.label.\"name\"=\"${local.project_log_sink_name}\"",
              "aggregation": {
                "alignmentPeriod": "60s",
                "perSeriesAligner": "ALIGN_SUM",
                "crossSeriesReducer": "REDUCE_SUM"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_LINE"
          }
        }
      },
      {
        "title": "Pub/Sub Publishing Rate",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"pubsub.googleapis.com/topic/send_message_operation_count\" resource.type=\"pubsub_topic\" resource.label.\"topic_id\"=\"${local.dataflow_input_topic_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "resource.label.\"topic_id\""
                    ]
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Pub/Sub Streaming Pull Rate",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"pubsub.googleapis.com/subscription/pull_message_operation_count\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=\"${local.dataflow_input_subscription_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "resource.label.\"subscription_id\""
                    ]
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Data Lag in Backlog",
        "scorecard": {
          "timeSeriesQuery": {
            "timeSeriesFilter": {
              "filter": "metric.type=\"pubsub.googleapis.com/subscription/oldest_unacked_message_age\" resource.type=\"pubsub_subscription\" resource.label.\"subscription_id\"=\"${local.dataflow_input_subscription_name}\"",
              "aggregation": {
                "alignmentPeriod": "60s",
                "perSeriesAligner": "ALIGN_NEXT_OLDER",
                "crossSeriesReducer": "REDUCE_MEAN"
              }
            }
          },
          "sparkChartView": {
            "sparkChartType": "SPARK_LINE"
          },
          "thresholds": [
            {
              "value": 60,
              "color": "YELLOW",
              "direction": "ABOVE"
            }
          ]
        }
      },
      {
        "title": "Dataflow Cores In Use",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"dataflow.googleapis.com/job/current_num_vcpus\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "resource.label.\"job_name\""
                    ]
                  }
                },
                "unitOverride": "1"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Dataflow CPU Utilization",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": [
                      "metadata.user_labels.\"dataflow_job_name\""
                    ]
                  }
                },
                "unitOverride": "ratio"
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      },
      {
        "title": "Dataflow System Lag",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"dataflow.googleapis.com/job/system_lag\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${var.dataflow_job_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN",
                    "crossSeriesReducer": "REDUCE_SUM"
                  },
                  "secondaryAggregation": {
                    "alignmentPeriod": "60s"
                  }
                }
              },
              "plotType": "LINE",
              "minAlignmentPeriod": "60s"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          },
          "chartOptions": {
            "mode": "COLOR"
          }
        }
      }
    ]
  }
}

EOF
}