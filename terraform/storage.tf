# Cloud Storage bucket para hospedar o site estático
resource "google_storage_bucket" "website" {
  name          = "${var.gcp_project_id}-website"
  location      = var.region
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Tornar o bucket público
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Backend bucket para o Cloud CDN
resource "google_compute_backend_bucket" "website" {
  name        = "${var.gcp_project_id}-backend-bucket"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true
}

# Reserva de IP para o load balancer
resource "google_compute_global_address" "website" {
  name = "${var.gcp_project_id}-website-ip"
}

# Certificado SSL gerenciado pelo Google
resource "google_compute_managed_ssl_certificate" "website" {
  name = "${var.gcp_project_id}-cert"
  managed {
    domains = [var.domain_name]
  }
}

# URL map para direcionar o tráfego
resource "google_compute_url_map" "website" {
  name            = "${var.gcp_project_id}-url-map"
  default_service = google_compute_backend_bucket.website.self_link
}

# Proxy HTTPS
resource "google_compute_target_https_proxy" "website" {
  name             = "${var.gcp_project_id}-https-proxy"
  url_map          = google_compute_url_map.website.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.website.self_link]
}

# Forwarding rule para HTTPS
resource "google_compute_global_forwarding_rule" "website" {
  name       = "${var.gcp_project_id}-forwarding-rule"
  target     = google_compute_target_https_proxy.website.self_link
  port_range = "443"
  ip_address = google_compute_global_address.website.address
}

# HTTP to HTTPS redirect
resource "google_compute_url_map" "http_redirect" {
  name = "${var.gcp_project_id}-http-redirect"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_http_proxy" "http_redirect" {
  name    = "${var.gcp_project_id}-http-redirect"
  url_map = google_compute_url_map.http_redirect.self_link
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  name       = "${var.gcp_project_id}-http-redirect"
  target     = google_compute_target_http_proxy.http_redirect.self_link
  port_range = "80"
  ip_address = google_compute_global_address.website.address
}