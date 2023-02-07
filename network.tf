resource "google_compute_network" "splunk_export" {
  count = var.create_network == true ? 1 : 0

  project                 = var.project
  name                    = var.network
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "splunk_subnet" {
  count = var.create_network == true ? 1 : 0

  project                  = var.project
  name                     = local.subnet_name
  ip_cidr_range            = var.primary_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.splunk_export[count.index].id
  private_ip_google_access = true

  # Optional configuration to log network traffic at the subnet level 
  #   log_config {
  #     aggregation_interval = "INTERVAL_15_MIN"
  #     flow_sampling        = 0.1
  #     metadata             = "INCLUDE_ALL_METADATA"
  #   }

}

# Create DNS policy that enables logging of DNS queries in new network
resource "google_dns_policy" "splunk_network_dns_policy" {
  count = var.create_network == true ? 1 : 0

  project = var.project
  name    = "${var.network}-dns-policy"

  enable_logging = true

  networks {
    network_url = google_compute_network.splunk_export[count.index].id
  }
}

resource "google_compute_router" "dataflow_to_splunk_router" {
  count = var.create_network == true ? 1 : 0

  project = var.project
  name    = "${var.network}-${var.region}-router"
  region  = google_compute_subnetwork.splunk_subnet[count.index].region
  network = google_compute_network.splunk_export[count.index].id
}

resource "google_compute_address" "dataflow_nat_ip_address" {
  count = var.create_network == true ? 1 : 0

  project = var.project
  name    = "dataflow-splunk-nat-ip-address"
  region  = google_compute_subnetwork.splunk_subnet[count.index].region
}

resource "google_compute_router_nat" "dataflow_nat" {
  count = var.create_network == true ? 1 : 0

  project                            = var.project
  name                               = "${var.network}-${var.region}-router-nat"
  router                             = google_compute_router.dataflow_to_splunk_router[count.index].name
  region                             = google_compute_router.dataflow_to_splunk_router[count.index].region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ips                            = google_compute_address.dataflow_nat_ip_address[*].self_link
  min_ports_per_vm                   = 128
  subnetwork {
    name                    = google_compute_subnetwork.splunk_subnet[count.index].id
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Creating firewall rule so that dataflow jobs with > 1 worker can communicate over internal IPs.
# Source: https://cloud.google.com/dataflow/docs/guides/routes-firewall#firewall_rules_required_by
resource "google_compute_firewall" "connect_dataflow_workers" {
  count = var.create_network == true ? 1 : 0

  project = var.project
  name    = "dataflow-internal-ip-fwr"
  network = google_compute_network.splunk_export[count.index].id

  allow {
    protocol = "tcp"
    ports    = ["12345-12346"]
  }

  source_tags = ["dataflow"]
  target_tags = ["dataflow"]
}
