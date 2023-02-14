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
  display_name = "Splunk Log Export Group"
  project      = local.scoping_project

  filter = "resource.metadata.name=starts_with(\"${var.dataflow_job_name}\")"
}

resource "google_monitoring_dashboard" "splunk-export-pipeline-dashboard" {
  project        = local.scoping_project
  dashboard_json = <<EOF
  {
    "displayName": "Splunk Log Export Ops",
    "mosaicLayout": {
      "columns": 12,
      "tiles": [
        {
          "height": 2,
          "width": 3,
          "yPos": 1,
          "widget": {
            "title": "Total Messages Exported (All-time)", 
            "scorecard": {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_MAX",
                    "perSeriesAligner": "ALIGN_MAX"
                  },
                  "filter": "metric.type=\"dataflow.googleapis.com/job/user_counter\" metric.label.\"metric_name\"=\"outbound-successful-events\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_main_job_name}\""
                }
              }
            }
          }
        },
        {
          "height": 4,
          "width": 6,
          "yPos": 3,
          "widget": {
            "title": "Input Data Rate ",
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "timeSeriesFilter": {
                      "filter": "metric.type=\"pubsub.googleapis.com/topic/byte_cost\" resource.type=\"pubsub_topic\"  resource.label.\"topic_id\"=\"${local.dataflow_input_topic_name}\"",
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 6,
          "xPos": 6,
          "yPos": 3,
          "widget": {
            "title": "Logs Exported (Hourly)",
            "xyChart": {
              "chartOptions": {
                "mode": "COLOR"
              },
              "dataSets": [
                {
                  "plotType": "STACKED_BAR",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesQueryLanguage": "fetch dataflow_job\n| metric 'dataflow.googleapis.com/job/user_counter'\n| filter metric.metric_name='outbound-successful-events' && (resource.job_name == '${local.dataflow_main_job_name}')\n| align next_older(1m)\n| every 1m\n| adjacent_delta\n| group_by 60m, sum(val())\n"
                  }
                }
              ],
              "timeshiftDuration": "0s",
              "yAxis": {
                "label": "y1Axis",
                "scale": "LINEAR"
              }
            }
          }
        },
        {
          "height": 2,
          "width": 3,
          "xPos": 6,
          "yPos": 1,
          "widget": {
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
                "sparkChartType": "SPARK_LINE"
              },
              "thresholds": [
                {
                  "value": 1000,
                  "color": "RED",
                  "direction": "ABOVE"
                },
                {
                  "value": 100,
                  "color": "YELLOW",
                  "direction": "ABOVE"
                }
              ]
            }
          }
        },
        {
          "height": 4,
          "width": 6,
          "yPos": 8,
          "widget": {
            "title": "Input Throughput from Log Sink(s) (EPS)",
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "timeSeriesFilter": {
                      "filter": "metric.type=\"pubsub.googleapis.com/topic/send_message_operation_count\" resource.type=\"pubsub_topic\" resource.label.\"topic_id\"=\"${local.dataflow_input_topic_name}\"",
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 6,
          "xPos": 6,
          "yPos": 8,
          "widget": {
            "title": "Output Throughput to Splunk (EPS)",
            "xyChart": {
              "chartOptions": {
                "mode": "COLOR"
              },
              "dataSets": [
                {
                  "plotType": "LINE",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesQueryLanguage": "fetch dataflow_job\n| metric 'dataflow.googleapis.com/job/user_counter'\n| filter metric.metric_name=='outbound-successful-events' && (resource.job_name =='${local.dataflow_main_job_name}')\n| align next_older(1m)\n| every 1m\n| adjacent_delta\n| align rate(1m)\n| every 1m"
                  }
                }
              ],
              "timeshiftDuration": "0s",
              "yAxis": {
                "label": "y1Axis",
                "scale": "LINEAR"
              }
            }
          }
        },
        {
          "height": 2,
          "width": 3,
          "xPos": 9,
          "yPos": 1,
          "widget": {
            "title": "Deadletter Queue Size",
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
                  "value": 100,
                  "color": "RED",
                  "direction": "ABOVE"
                },
                {
                  "color": "YELLOW",
                  "direction": "ABOVE"
                }
              ]
            }
          }
        },
        {
          "height": 3,
          "width": 3,
          "xPos": 9,
          "yPos": 12,
          "widget": {
            "title": "Splunk HEC - 5xx Errors",
            "xyChart": {
              "chartOptions": {
                "mode": "COLOR"
              },
              "dataSets": [
                {
                  "plotType": "STACKED_BAR",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesQueryLanguage": "fetch dataflow_job\n| metric 'dataflow.googleapis.com/job/user_counter'\n| filter metric.metric_name=='http-server-error-requests' && (resource.job_name==\"${local.dataflow_main_job_name}\")\n| align next_older(1m)\n| every 1m\n| adjacent_delta"
                  }
                }
              ],
              "timeshiftDuration": "0s",
              "yAxis": {
                "label": "y1Axis",
                "scale": "LINEAR"
              }
            }
          }
        },
        {
          "height": 3,
          "width": 3,
          "xPos": 6,
          "yPos": 12,
          "widget": {
            "title": "Splunk HEC - 4xx or Network Errors",
            "xyChart": {
              "chartOptions": {
                "mode": "COLOR"
              },
              "dataSets": [
                {
                  "plotType": "STACKED_BAR",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesQueryLanguage": "fetch dataflow_job\n| metric 'dataflow.googleapis.com/job/user_counter'\n| filter metric.metric_name=='http-invalid-requests' && (resource.job_name =\"${local.dataflow_main_job_name}\")\n| align next_older(1m)\n| every 1m\n| adjacent_delta"
                  }
                }
              ],
              "timeshiftDuration": "0s",
              "yAxis": {
                "label": "y1Axis",
                "scale": "LINEAR"
              }
            }
          }
        },
        {
          "height": 3,
          "width": 3,
          "xPos": 3,
          "yPos": 12,
          "widget": {
            "title": "Splunk HEC - Avg Batch Size (All-time)",
            "scorecard": {
              "sparkChartView": {
                "sparkChartType": "SPARK_LINE"
              },
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "perSeriesAligner": "ALIGN_MEAN"
                  },
                  "filter": "metric.type=\"dataflow.googleapis.com/job/user_counter\" metric.label.\"metric_name\"=\"write_to_splunk_batch_MEAN\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_main_job_name}\""
                }
              }
            }
          }
        },
        {
          "height": 3,
          "width": 3,
          "yPos": 12,
          "widget": {
            "title": "Splunk HEC - Avg Latency (ms) (All-time)",
            "scorecard": {
              "sparkChartView": {
                "sparkChartType": "SPARK_LINE"
              },
              "thresholds": [
                {
                  "color": "RED",
                  "direction": "ABOVE",
                  "value": 2000
                },
                {
                  "color": "YELLOW",
                  "direction": "ABOVE",
                  "value": 500
                }
              ],
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "perSeriesAligner": "ALIGN_MEAN"
                  },
                  "filter": "metric.type=\"dataflow.googleapis.com/job/user_counter\" metric.label.\"metric_name\"=\"successful_write_to_splunk_latency_ms_MEAN\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_main_job_name}\""
                }
              }
            }
          }
        },
        { 
          "height": 4,
          "width": 4,
          "yPos": 15,
          "widget": {
            "title": "Total Messages Exported (All-time)",
            "scorecard": {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"dataflow.googleapis.com/job/user_counter\" metric.label.\"metric_name\"=\"outbound-successful-events\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_main_job_name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "crossSeriesReducer": "REDUCE_MAX",
                    "perSeriesAligner": "ALIGN_MAX"
                  }
                }
              },
              "sparkChartView": {
                "sparkChartType": "SPARK_BAR"
              }
            }
          }
        },
        {
          "height": 4,
          "width": 4,
          "xPos": 4,
          "yPos": 15,
          "widget": {
            "title": "Total Messages Failed",
            "xyChart": {
              "dataSets": [
                {
                  "plotType": "LINE",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesQueryLanguage": "fetch dataflow_job\n| metric 'dataflow.googleapis.com/job/user_counter'\n| filter metric.metric_name=='total-failed-messages'&& (resource.job_name =\"${local.dataflow_main_job_name}\")\n| align next_older(1m)\n| every 1m\n| adjacent_delta"
                  }
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
        },
        {
          "height": 4,
          "width": 4,
          "xPos": 8,
          "yPos": 15,
          "widget": {
            "title": "Total Messages Replayed",
            "xyChart": {
              "dataSets": [
                {
                  "plotType": "LINE",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesQueryLanguage": "fetch dataflow_job\n| filter resource.job_name =\"${local.dataflow_replay_job_name}\"\n| metric 'dataflow.googleapis.com/job/elements_produced_count'\n| align next_older(1m)\n| every 1m\n| adjacent_delta"
                  }
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
        },
        {
          "height": 2,
          "width": 3,
          "xPos": 3,
          "yPos": 1,
          "widget": {
            "title": "Current Throughput (EPS)",
            "scorecard": {
              "sparkChartView": {
                "sparkChartType": "SPARK_LINE"
              },
              "timeSeriesQuery": {
                "timeSeriesQueryLanguage": "fetch dataflow_job\n| metric 'dataflow.googleapis.com/job/user_counter'\n|  filter metric.metric_name=='outbound-successful-events' && (resource.job_name =='${local.dataflow_main_job_name}')\n| align next_older(1m)\n| every 1m\n| adjacent_delta| align rate(1m)\n| every 1m\n"
              }
            }
          }
        },
        {
          "height": 4,
          "width": 4,
          "yPos": 19,
          "widget": {
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 4,
          "xPos": 4,
          "yPos": 19,
          "widget": {
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 4,
          "xPos": 8,
          "yPos": 19,
          "widget": {
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
          }
        },
        {
          "height": 4,
          "width": 3,
          "xPos": 3,
          "yPos": 23,
          "widget": {
            "title": "Dataflow Cores In Use",
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "timeSeriesFilter": {
                      "filter": "metric.type=\"dataflow.googleapis.com/job/current_num_vcpus\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_main_job_name}\"",
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 3,
          "yPos": 23,
          "widget": {
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 3,
          "xPos": 9,
          "yPos": 23,
          "widget": {
            "title": "Dataflow System Lag",
            "xyChart": {
              "dataSets": [
                {
                  "timeSeriesQuery": {
                    "timeSeriesFilter": {
                      "filter": "metric.type=\"dataflow.googleapis.com/job/system_lag\" resource.type=\"dataflow_job\" resource.label.\"job_name\"=\"${local.dataflow_main_job_name}\"",
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
                  "targetAxis": "Y1",
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
        },
        {
          "height": 4,
          "width": 6,
          "yPos": 27,
          "widget": {
            "title": "Dataflow worker error logs",
            "logsPanel": {
              "filter": "resource.type=\"dataflow_step\"\nlog_id(\"dataflow.googleapis.com/worker\")\nseverity=ERROR",
              "resourceNames": [
                "projects/${data.google_project.project.number}"
              ]
            }
          }
        },
        {
          "height": 4,
          "width": 6,
          "xPos": 6,
          "yPos": 27,
          "widget": {
            "title": "Dataflow worker UDF stdout logs",
            "logsPanel": {
              "filter": "resource.type=\"dataflow_step\"\nlog_id(\"dataflow.googleapis.com/worker\")\njsonPayload.logger=\"System.out\"",
              "resourceNames": [
                "projects/${data.google_project.project.number}"
              ]
            }
          }
        },
        {
          "height": 1,
          "widget": {
            "text": {
              "format": "MARKDOWN"
            },
            "title": "Pipeline Throughput (EPS), Latency (ms), Errors"
          },
          "width": 12,
          "yPos": 7
        },
        {
          "height": 1,
          "widget": {
            "text": {
              "format": "MARKDOWN"
            },
            "title": "Pipeline Performance Summary"
          },
          "width": 12
        },
        {
          "height": 4,
          "widget": {
            "collapsibleGroup": {},
            "title": "Pipeline Logs for Troubleshooting"
          },
          "width": 12,
          "yPos": 27
        },
        {
          "height": 4,
          "widget": {
            "collapsibleGroup": {},
            "title": "Pipeline Utilization"
          },
          "width": 12,
          "yPos": 23
        },
        {
          "height": 4,
          "widget": {
            "collapsibleGroup": {},
            "title": "Source Pub/Sub Metrics"
          },
          "width": 12,
          "yPos": 19
        },
        {
          "height": 4,
          "widget": {
            "collapsibleGroup": {},
            "title": "Processed Messages"
          },
          "width": 12,
          "yPos": 15
        },
        {
          "height": 4,
          "width": 3,
          "xPos": 6,
          "yPos": 23,
          "widget": {
            "title": "Cloud NAT Open connections",
            "xyChart": {
              "chartOptions": {
                "mode": "COLOR"
              },
              "dataSets": [
                {
                  "minAlignmentPeriod": "60s",
                  "plotType": "LINE",
                  "targetAxis": "Y1",
                  "timeSeriesQuery": {
                    "timeSeriesFilter": {
                      "aggregation": {
                        "alignmentPeriod": "60s",
                        "perSeriesAligner": "ALIGN_MEAN"
                      },
                      "filter": "metric.type=\"router.googleapis.com/nat/open_connections\" resource.type=\"nat_gateway\" resource.label.\"gateway_name\"=\"${length(google_compute_router_nat.dataflow_nat) > 0 ? google_compute_router_nat.dataflow_nat[0].name : ""}\"",
                      "secondaryAggregation": {
                        "alignmentPeriod": "60s"
                      }
                    }
                  }
                }
              ],
              "timeshiftDuration": "0s",
              "yAxis": {
                "label": "y1Axis",
                "scale": "LINEAR"
              }
            }
          }
        }
      ]
    }
  }

  EOF
}
