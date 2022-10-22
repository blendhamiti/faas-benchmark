output "api_gateway_hostname" {
  description = "API gateway host name"

  value = google_api_gateway_gateway.api_gw.default_hostname
}