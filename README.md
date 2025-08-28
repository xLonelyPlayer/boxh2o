# BoxH2O - Aplicação Web com Angular, Cloud Storage e CDN

## Visão Geral
Este projeto implementa uma aplicação web Angular hospedada no Google Cloud Storage e distribuída globalmente através do Cloud CDN, oferecendo alta performance e baixa latência.

## Arquitetura
- **Frontend**: Angular (Static Site)
- **Hospedagem**: Google Cloud Storage
- **CDN**: Google Cloud CDN
- **SSL**: Google-managed SSL certificates

## Pré-requisitos
- Node.js e npm
- Google Cloud SDK
- Terraform

## Estrutura do Projeto
```
├── frontend-static/     # Aplicação Angular
├── terraform/           # Configurações IaC
└── .github/workflows    # Pipeline CI/CD
```

## Configuração do Ambiente Local

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/boxh2o.git
cd boxh2o
```

2. Instale as dependências e execute o frontend:
```bash
cd frontend-static
npm install
ng serve
```

## Implantação na GCP

### 1. Configuração do Projeto GCP

1. Crie um novo projeto na GCP
2. Habilite as APIs necessárias:
   - Cloud Storage API
   - Cloud CDN API
   - Cloud Build API
   - Certificate Manager API

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

### 4. Deploy

1. Faça push para a branch main:
```bash
git push origin main
```

2. O GitHub Actions irá:
   - Buildar a aplicação Angular
   - Fazer upload dos arquivos para o Cloud Storage
   - Configurar os headers de cache

## Acesso à Aplicação

- Produção: https://app.boxh2o.com

## Otimizações

### Cache
- Arquivos estáticos (CSS/JS): Cache de 1 hora
- Assets (imagens/fontes): Cache de 24 horas
- index.html: Sem cache para atualizações imediatas

### Performance
- Distribuição global via Cloud CDN
- Compressão automática de arquivos
- SSL/TLS gerenciado pelo Google

## Monitoramento

- Cloud Monitoring para métricas de CDN
- Cloud Logging para logs de acesso
- Alertas configuráveis para:
  - Erros de cache
  - Latência
  - Taxa de hit/miss do CDN

## Segurança

- HTTPS forçado
- Headers de segurança automáticos
- Certificados SSL gerenciados automaticamente

## Suporte

Para questões e suporte, abra uma issue no repositório do GitHub.