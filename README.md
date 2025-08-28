# BoxH2O - Aplicação Web na GCP

## Visão Geral
Este projeto implementa uma aplicação web moderna usando a seguinte stack:
- Frontend: Angular
- Backend: .NET Core API
- Banco de Dados: PostgreSQL
- Infraestrutura: Google Cloud Platform (GCP)

## Pré-requisitos
- Docker e Docker Compose
- Google Cloud SDK
- Terraform
- kubectl
- Node.js e npm
- .NET SDK

## Estrutura do Projeto
```
├── api/                # Backend .NET Core
├── frontend/          # Frontend Angular
├── terraform/         # Configurações IaC
├── k8s/               # Manifestos Kubernetes
└── .github/workflows  # Pipeline CI/CD
```

## Configuração do Ambiente Local

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/boxh2o.git
cd boxh2o
```

2. Inicie os serviços localmente:
```bash
docker-compose up -d
```

## Implantação na GCP

### 1. Configuração do Projeto GCP

1. Crie um novo projeto na GCP
2. Habilite as APIs necessárias:
   - Kubernetes Engine API
   - Cloud SQL Admin API
   - Container Registry API
   - Cloud Build API

### 2. Configuração do Terraform

1. Crie um bucket para o estado do Terraform:
```bash
gsutil mb gs://boxh2o-terraform-state
```

2. Configure as variáveis:
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edite as variáveis conforme necessário
```

3. Inicialize e aplique o Terraform:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Configuração do GitHub Actions

1. Configure os seguintes secrets no GitHub:
   - GCP_PROJECT_ID
   - WIF_PROVIDER
   - WIF_SERVICE_ACCOUNT

### 4. Implantação

1. Faça push para a branch main:
```bash
git push origin main
```

2. O GitHub Actions irá:
   - Construir as imagens Docker
   - Publicar no Artifact Registry
   - Implantar no GKE

## Acesso à Aplicação

- Frontend: https://app.boxh2o.com
- API: https://api.boxh2o.com

## Monitoramento e Logs

- Acesse o Cloud Monitoring para métricas
- Utilize o Cloud Logging para logs
- Configure alertas no Cloud Monitoring

## Segurança

- Todas as comunicações são criptografadas via TLS
- Banco de dados acessível apenas pela VPC privada
- Autenticação via Workload Identity Federation

## Suporte

Para questões e suporte, abra uma issue no repositório do GitHub.