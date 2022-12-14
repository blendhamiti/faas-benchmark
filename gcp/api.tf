locals {
  openapi_document_path = "${path.module}/api/openapi.yml"
}

resource "google_api_gateway_api" "api_gw" {
  provider = google-beta
  api_id   = "api"
}

resource "google_api_gateway_api_config" "api_gw" {
  provider = google-beta
  api      = google_api_gateway_api.api_gw.api_id

  api_config_id = "config-${filemd5(local.openapi_document_path)}"

  openapi_documents {
    document {
      path     = local.openapi_document_path
      contents = filebase64(local.openapi_document_path)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_gw.id
  gateway_id = "gw"
}