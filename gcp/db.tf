resource "google_compute_network" "private_network" {
  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "instance" {
  name             = "seeu-gcp-db"
  database_version = "MYSQL_5_7"

  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier      = "db-f1-micro"
    disk_size = 10
    disk_type = "PD_HDD"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "test-net"
        value = "0.0.0.0/0"
      }
      private_network = google_compute_network.private_network.id
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = "root"
  password = "password123"
  instance = google_sql_database_instance.instance.name
}
