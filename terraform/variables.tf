variable "gcp_project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "region" {
  description = "Região do GCP para os recursos"
  type        = string
  default     = "us-central1"
}

variable "domain_name" {
  description = "Nome do domínio para o site (ex: app.boxh2o.com)"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range para a subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "gke_num_nodes" {
  description = "Número de nodes no GKE"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Tipo de máquina para os nodes do GKE"
  type        = string
  default     = "e2-medium"
}

variable "db_tier" {
  description = "Tier do Cloud SQL"
  type        = string
  default     = "db-f1-micro"
}

variable "db_user" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "Repositório GitHub no formato USUARIO/NOME_DO_REPO"
  type        = string
}