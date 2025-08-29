terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  backend "gcs" {
    bucket  = "dev-boxh2o-terraform-state"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.gcp_project_id}-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.gcp_project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.subnet_cidr
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "${var.gcp_project_id}-gke"
  location = var.region
  network  = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.gcp_project_id}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    machine_type = var.machine_type
    disk_size_gb = 50

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      env = var.gcp_project_id
    }

    tags = ["gke-node"]
  }
}

# Cloud SQL
resource "google_sql_database_instance" "instance" {
  name             = "${var.gcp_project_id}-db"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }

    backup_configuration {
      enabled = false
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = "boxh2o"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = var.db_password
}

# 1. Cria o "Pool" de identidades externas
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
}

# 2. Cria o "Provedor" de identidades, ligando o Pool ao GitHub
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  
  # Mapeia os atributos do token do GitHub para a GCP
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  
  # Define o emissor do token (issuer) como sendo o GitHub
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 3. Permite que o Provedor do GitHub personifique (impersonate) nossa Conta de Serviço
resource "google_service_account_iam_member" "wif_iam_binding" {
  # A conta de serviço que será usada pelo pipeline
  service_account_id = "projects/${var.gcp_project_id}/serviceAccounts/terraform@${var.gcp_project_id}.iam.gserviceaccount.com"
  
  # O papel necessário para a personificação
  role               = "roles/iam.workloadIdentityUser"
  
  # Arquiteto GCP: Define QUEM pode personificar. Neste caso, qualquer workflow
  # do seu repositório GitHub.
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}" # Ex: "google-github-actions/auth"
}