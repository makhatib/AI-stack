#!/bin/bash

################################################################################
# Advanced Automation Stack - Automated Installation Script
# https://www.youtube.com/@malkhatib
# Core: n8n, PostgreSQL, Redis, Qdrant, Supabase, MinIO
# Optional: Ollama, Grafana+Prometheus, Uptime Kuma, Portainer, Open WebUI
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to print colored output
print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}========================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Function to generate secure random string
generate_secret() {
    local length=$1
    openssl rand -hex $length
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate domain format
validate_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Clear screen and show banner
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Advanced Automation Stack - Automated Installer        ║
║                                                           ║
║   Core Services:                                         ║
║   • n8n (Workflow Automation)                           ║
║   • PostgreSQL (Database)                               ║
║   • Redis (Cache/Queue)                                 ║
║   • Qdrant (Vector Database)                            ║
║   • Supabase (Backend API)                              ║
║   • MinIO (Object Storage)                              ║
║                                                           ║
║   Optional Services:                                     ║
║   • Ollama (Local LLM)                                  ║
║   • Grafana + Prometheus (Monitoring)                   ║
║   • Uptime Kuma (Service Monitoring)                    ║
║   • Portainer (Container Management)                    ║
║   • Open WebUI (AI Chat Interface)                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF

echo ""
print_info "Starting installation process..."
sleep 2

################################################################################
# STEP 1: Prerequisites Check
################################################################################

print_header "Step 1: Checking Prerequisites"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_warning "Running as root. Consider using a non-root user with sudo privileges."
   sleep 2
fi

# Check Docker
print_info "Checking for Docker..."
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    print_success "Docker found (version: $DOCKER_VERSION)"
else
    print_error "Docker is not installed!"
    echo ""
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com | sh"
    echo ""
    exit 1
fi

# Check Docker Compose
print_info "Checking for Docker Compose..."
if command_exists docker && docker compose version >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version --short)
    print_success "Docker Compose found (version: $COMPOSE_VERSION)"
else
    print_error "Docker Compose is not installed!"
    echo ""
    echo "Please install Docker Compose"
    exit 1
fi

# Check if Docker daemon is running
print_info "Checking if Docker daemon is running..."
if docker info >/dev/null 2>&1; then
    print_success "Docker daemon is running"
else
    print_error "Docker daemon is not running!"
    echo "Please start Docker and try again."
    exit 1
fi

# Check for openssl (for key generation)
print_info "Checking for OpenSSL..."
if command_exists openssl; then
    print_success "OpenSSL found"
else
    print_error "OpenSSL is not installed!"
    exit 1
fi

# Detect server IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "Unable to detect")
print_info "Detected server IP: $SERVER_IP"

sleep 2

################################################################################
# STEP 2: Collect Configuration Information
################################################################################

print_header "Step 2: Configuration Setup"

echo "Please provide the following information:"
echo ""

# Domain Name
while true; do
    read -p "$(echo -e "${CYAN}Enter your main domain (e.g., example.com): ${NC}")" DOMAIN_NAME
    if validate_domain "$DOMAIN_NAME"; then
        print_success "Valid domain: $DOMAIN_NAME"
        break
    else
        print_error "Invalid domain format. Please try again."
    fi
done

# n8n Subdomain
while true; do
    read -p "$(echo -e "${CYAN}Enter n8n subdomain (default: n8n): ${NC}")" N8N_SUBDOMAIN
    N8N_SUBDOMAIN=${N8N_SUBDOMAIN:-n8n}
    if validate_domain "$N8N_SUBDOMAIN"; then
        print_success "n8n will be accessible at: https://$N8N_SUBDOMAIN.$DOMAIN_NAME"
        break
    else
        print_error "Invalid subdomain format. Please try again."
    fi
done

# SSL Email
while true; do
    read -p "$(echo -e "${CYAN}Enter email for SSL certificates (Let's Encrypt): ${NC}")" SSL_EMAIL
    if validate_email "$SSL_EMAIL"; then
        print_success "SSL email: $SSL_EMAIL"
        break
    else
        print_error "Invalid email format. Please try again."
    fi
done

# Timezone selection
echo ""
print_info "Select your timezone:"
echo "1) America/New_York"
echo "2) America/Los_Angeles"
echo "3) America/Chicago"
echo "4) Europe/London"
echo "5) Europe/Paris"
echo "6) Europe/Berlin"
echo "7) Asia/Dubai"
echo "8) Asia/Riyadh"
echo "9) Asia/Tokyo"
echo "10) Asia/Shanghai"
echo "11) Asia/Singapore"
echo "12) Australia/Sydney"
echo "13) Custom (enter manually)"

read -p "$(echo -e "${CYAN}Choose timezone [1-13] (default: 8 - Asia/Riyadh): ${NC}")" TZ_CHOICE
TZ_CHOICE=${TZ_CHOICE:-8}

case $TZ_CHOICE in
    1) GENERIC_TIMEZONE="America/New_York" ;;
    2) GENERIC_TIMEZONE="America/Los_Angeles" ;;
    3) GENERIC_TIMEZONE="America/Chicago" ;;
    4) GENERIC_TIMEZONE="Europe/London" ;;
    5) GENERIC_TIMEZONE="Europe/Paris" ;;
    6) GENERIC_TIMEZONE="Europe/Berlin" ;;
    7) GENERIC_TIMEZONE="Asia/Dubai" ;;
    8) GENERIC_TIMEZONE="Asia/Riyadh" ;;
    9) GENERIC_TIMEZONE="Asia/Tokyo" ;;
    10) GENERIC_TIMEZONE="Asia/Shanghai" ;;
    11) GENERIC_TIMEZONE="Asia/Singapore" ;;
    12) GENERIC_TIMEZONE="Australia/Sydney" ;;
    13) 
        read -p "$(echo -e "${CYAN}Enter timezone (e.g., Asia/Riyadh): ${NC}")" GENERIC_TIMEZONE
        ;;
    *) GENERIC_TIMEZONE="Asia/Riyadh" ;;
esac

print_success "Timezone set to: $GENERIC_TIMEZONE"

################################################################################
# STEP 3: Optional Services Selection
################################################################################

print_header "Step 3: Optional Services Selection"

echo ""
echo -e "${BOLD}${MAGENTA}The following services will be installed by default:${NC}"
echo -e "${GREEN}  ✓ n8n (Workflow Automation)${NC}"
echo -e "${GREEN}  ✓ PostgreSQL (Database)${NC}"
echo -e "${GREEN}  ✓ Redis (Cache/Queue)${NC}"
echo -e "${GREEN}  ✓ Qdrant (Vector Search)${NC}"
echo -e "${GREEN}  ✓ Supabase (Backend API)${NC}"
echo -e "${GREEN}  ✓ MinIO (Object Storage)${NC}"
echo -e "${GREEN}  ✓ Traefik (Reverse Proxy with SSL)${NC}"
echo ""
echo -e "${BOLD}${YELLOW}Would you like to install optional services?${NC}"
echo ""

# Ollama
read -p "$(echo -e "${CYAN}Install Ollama (Local LLM for AI)? [Y/n]: ${NC}")" INSTALL_OLLAMA
if [[ ! "$INSTALL_OLLAMA" =~ ^[Nn]$ ]]; then
    INSTALL_OLLAMA="true"
    print_success "Ollama will be installed at: https://ollama.$DOMAIN_NAME"
else
    INSTALL_OLLAMA="false"
    print_info "Ollama will not be installed"
fi

# Open WebUI (only if Ollama is installed)
if [[ "$INSTALL_OLLAMA" == "true" ]]; then
    read -p "$(echo -e "${CYAN}Install Open WebUI (Chat interface for Ollama)? [Y/n]: ${NC}")" INSTALL_OPENWEBUI
    if [[ ! "$INSTALL_OPENWEBUI" =~ ^[Nn]$ ]]; then
        INSTALL_OPENWEBUI="true"
        print_success "Open WebUI will be installed at: https://ai.$DOMAIN_NAME"
    else
        INSTALL_OPENWEBUI="false"
        print_info "Open WebUI will not be installed"
    fi
else
    INSTALL_OPENWEBUI="false"
fi

# Grafana + Prometheus
read -p "$(echo -e "${CYAN}Install Grafana + Prometheus (Monitoring Stack)? [Y/n]: ${NC}")" INSTALL_MONITORING
if [[ ! "$INSTALL_MONITORING" =~ ^[Nn]$ ]]; then
    INSTALL_MONITORING="true"
    print_success "Grafana will be installed at: https://grafana.$DOMAIN_NAME"
    print_success "Prometheus will be installed at: https://prometheus.$DOMAIN_NAME"
else
    INSTALL_MONITORING="false"
    print_info "Monitoring stack will not be installed"
fi

# Uptime Kuma
read -p "$(echo -e "${CYAN}Install Uptime Kuma (Service Monitoring)? [Y/n]: ${NC}")" INSTALL_UPTIME
if [[ ! "$INSTALL_UPTIME" =~ ^[Nn]$ ]]; then
    INSTALL_UPTIME="true"
    print_success "Uptime Kuma will be installed at: https://uptime.$DOMAIN_NAME"
else
    INSTALL_UPTIME="false"
    print_info "Uptime Kuma will not be installed"
fi

# Portainer
read -p "$(echo -e "${CYAN}Install Portainer (Container Management)? [Y/n]: ${NC}")" INSTALL_PORTAINER
if [[ ! "$INSTALL_PORTAINER" =~ ^[Nn]$ ]]; then
    INSTALL_PORTAINER="true"
    print_success "Portainer will be installed at: https://portainer.$DOMAIN_NAME"
else
    INSTALL_PORTAINER="false"
    print_info "Portainer will not be installed"
fi

################################################################################
# STEP 4: Generate Secure Keys
################################################################################

print_header "Step 4: Generating Secure Keys"

print_info "Generating secure random passwords..."

# PostgreSQL
POSTGRES_PASSWORD=$(generate_secret 32)
print_success "POSTGRES_PASSWORD generated (64 characters)"

# Redis
REDIS_PASSWORD=$(generate_secret 32)
print_success "REDIS_PASSWORD generated (64 characters)"

# Qdrant API Key
QDRANT_API_KEY=$(generate_secret 32)
print_success "QDRANT_API_KEY generated (64 characters)"

# Supabase Keys
SUPABASE_JWT_SECRET=$(generate_secret 32)
SUPABASE_ANON_KEY=$(generate_secret 32)
SUPABASE_SERVICE_KEY=$(generate_secret 32)
SUPABASE_DASHBOARD_PASSWORD=$(generate_secret 16)
print_success "SUPABASE keys generated"

# MinIO
MINIO_ROOT_USER="admin"
MINIO_ROOT_PASSWORD=$(generate_secret 16)
print_success "MINIO credentials generated"

# Optional services keys
if [[ "$INSTALL_MONITORING" == "true" ]]; then
    GRAFANA_PASSWORD=$(generate_secret 16)
    print_success "GRAFANA_PASSWORD generated"
fi

sleep 1

################################################################################
# STEP 5: DNS Verification
################################################################################

print_header "Step 5: DNS Configuration Check"

echo ""
print_warning "IMPORTANT: DNS Configuration Required!"
echo ""
echo "Before proceeding, ensure these DNS A records point to your server:"
echo ""
echo -e "${BOLD}Core Services:${NC}"
echo "  $N8N_SUBDOMAIN.$DOMAIN_NAME           →  $SERVER_IP"
echo "  qdrant.$DOMAIN_NAME         →  $SERVER_IP"
echo "  supabase.$DOMAIN_NAME       →  $SERVER_IP"
echo "  minio.$DOMAIN_NAME          →  $SERVER_IP"
echo "  s3.$DOMAIN_NAME             →  $SERVER_IP"

if [[ "$INSTALL_OLLAMA" == "true" ]]; then
    echo ""
    echo -e "${BOLD}AI Services:${NC}"
    echo "  ollama.$DOMAIN_NAME         →  $SERVER_IP"
fi

if [[ "$INSTALL_OPENWEBUI" == "true" ]]; then
    echo "  ai.$DOMAIN_NAME             →  $SERVER_IP"
fi

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    echo ""
    echo -e "${BOLD}Monitoring:${NC}"
    echo "  grafana.$DOMAIN_NAME        →  $SERVER_IP"
    echo "  prometheus.$DOMAIN_NAME     →  $SERVER_IP"
fi

if [[ "$INSTALL_UPTIME" == "true" ]]; then
    echo "  uptime.$DOMAIN_NAME         →  $SERVER_IP"
fi

if [[ "$INSTALL_PORTAINER" == "true" ]]; then
    echo ""
    echo -e "${BOLD}Management:${NC}"
    echo "  portainer.$DOMAIN_NAME      →  $SERVER_IP"
fi

echo ""
print_info "You can verify DNS with: nslookup $N8N_SUBDOMAIN.$DOMAIN_NAME"
echo ""

read -p "$(echo -e "${YELLOW}Have you configured the DNS records? [y/N]: ${NC}")" DNS_CONFIRMED
if [[ ! "$DNS_CONFIRMED" =~ ^[Yy]$ ]]; then
    print_warning "Please configure DNS records first, then run this script again."
    exit 0
fi

################################################################################
# STEP 6: Create Configuration Files
################################################################################

print_header "Step 6: Creating Configuration Files"

# Create deployment directory
DEPLOY_DIR="automation-stack"
print_info "Creating deployment directory: $DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

# Create docker-compose.yml
print_info "Creating docker-compose.yml..."

cat > docker-compose.yml << 'EOFCOMPOSE'
version: "3.9"

services:
  # Traefik - Reverse Proxy with SSL
  traefik:
    image: traefik:latest
    restart: always
    command:
      - "--api=true"
      - "--api.dashboard=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=${SSL_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--log.level=INFO"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - automation-network

  # PostgreSQL - Shared Database
  postgres:
    image: pgvector/pgvector:pg16
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_MULTIPLE_DATABASES=n8n,supabase
    volumes:
      - ./init-scripts:/docker-entrypoint-initdb.d
      - postgres_data:/var/lib/postgresql/data
    networks:
      - automation-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis - Cache and Queue
  redis:
    image: redis:alpine
    restart: always
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - automation-network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # n8n - Workflow Automation
  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    environment:
      - N8N_HOST=${N8N_SUBDOMAIN}.${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${N8N_SUBDOMAIN}.${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_DIAGNOSTICS_ENABLED=false
      - N8N_PERSONALIZATION_ENABLED=false
    volumes:
      - n8n_data:/home/node/.n8n
      - ./n8n-files:/files
    networks:
      - automation-network
    depends_on:
      postgres:
        condition: service_healthy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(`${N8N_SUBDOMAIN}.${DOMAIN_NAME}`)"
      - "traefik.http.routers.n8n.tls=true"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=letsencrypt"
      - "traefik.http.services.n8n.loadbalancer.server.port=5678"

  # Qdrant - Vector Database
  qdrant:
    image: qdrant/qdrant:latest
    restart: always
    environment:
      - QDRANT__SERVICE__API_KEY=${QDRANT_API_KEY}
    volumes:
      - qdrant_data:/qdrant/storage
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.qdrant.rule=Host(`qdrant.${DOMAIN_NAME}`)"
      - "traefik.http.routers.qdrant.tls=true"
      - "traefik.http.routers.qdrant.entrypoints=websecure"
      - "traefik.http.routers.qdrant.tls.certresolver=letsencrypt"
      - "traefik.http.services.qdrant.loadbalancer.server.port=6333"

  # Supabase Studio
  supabase-studio:
    image: supabase/studio:latest
    restart: always
    environment:
      - SUPABASE_URL=https://supabase.${DOMAIN_NAME}
      - SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
      - STUDIO_PG_META_URL=http://supabase-meta:8080
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.supabase.rule=Host(`supabase.${DOMAIN_NAME}`)"
      - "traefik.http.routers.supabase.tls=true"
      - "traefik.http.routers.supabase.entrypoints=websecure"
      - "traefik.http.routers.supabase.tls.certresolver=letsencrypt"
      - "traefik.http.services.supabase.loadbalancer.server.port=3000"

  # Supabase Kong (API Gateway)
  supabase-kong:
    image: kong:latest
    restart: always
    environment:
      - KONG_DATABASE=off
      - KONG_DECLARATIVE_CONFIG=/var/lib/kong/kong.yml
      - KONG_DNS_ORDER=LAST,A,CNAME
      - KONG_PLUGINS=request-transformer,cors,key-auth,acl
    volumes:
      - ./supabase/kong.yml:/var/lib/kong/kong.yml
    networks:
      - automation-network
    depends_on:
      - supabase-auth
      - supabase-rest
      - supabase-realtime
      - supabase-storage

  # Supabase Auth
  supabase-auth:
    image: supabase/gotrue:latest
    restart: always
    environment:
      - GOTRUE_API_HOST=0.0.0.0
      - GOTRUE_API_PORT=9999
      - API_EXTERNAL_URL=https://supabase.${DOMAIN_NAME}
      - GOTRUE_DB_DRIVER=postgres
      - GOTRUE_DB_DATABASE_URL=postgres://postgres:${POSTGRES_PASSWORD}@postgres:5432/supabase?search_path=auth
      - GOTRUE_SITE_URL=https://supabase.${DOMAIN_NAME}
      - GOTRUE_JWT_SECRET=${SUPABASE_JWT_SECRET}
      - GOTRUE_JWT_EXP=3600
      - GOTRUE_DISABLE_SIGNUP=false
    networks:
      - automation-network
    depends_on:
      postgres:
        condition: service_healthy

  # Supabase REST (PostgREST)
  supabase-rest:
    image: postgrest/postgrest:latest
    restart: always
    environment:
      - PGRST_DB_URI=postgres://postgres:${POSTGRES_PASSWORD}@postgres:5432/supabase
      - PGRST_DB_SCHEMAS=public,storage
      - PGRST_DB_ANON_ROLE=anon
      - PGRST_JWT_SECRET=${SUPABASE_JWT_SECRET}
    networks:
      - automation-network
    depends_on:
      postgres:
        condition: service_healthy

  # Supabase Realtime
  supabase-realtime:
    image: supabase/realtime:latest
    restart: always
    environment:
      - PORT=4000
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_NAME=supabase
      - DB_SSL=false
      - JWT_SECRET=${SUPABASE_JWT_SECRET}
    networks:
      - automation-network
    depends_on:
      postgres:
        condition: service_healthy

  # Supabase Storage
  supabase-storage:
    image: supabase/storage-api:latest
    restart: always
    environment:
      - ANON_KEY=${SUPABASE_ANON_KEY}
      - SERVICE_KEY=${SUPABASE_SERVICE_KEY}
      - POSTGREST_URL=http://supabase-rest:3000
      - PGRST_JWT_SECRET=${SUPABASE_JWT_SECRET}
      - DATABASE_URL=postgres://postgres:${POSTGRES_PASSWORD}@postgres:5432/supabase
      - FILE_SIZE_LIMIT=52428800
      - STORAGE_BACKEND=file
      - FILE_STORAGE_BACKEND_PATH=/var/lib/storage
      - TENANT_ID=stub
      - REGION=stub
      - GLOBAL_S3_BUCKET=stub
    volumes:
      - supabase_storage:/var/lib/storage
    networks:
      - automation-network
    depends_on:
      postgres:
        condition: service_healthy

  # Supabase Meta
  supabase-meta:
    image: supabase/postgres-meta:latest
    restart: always
    environment:
      - PG_META_PORT=8080
      - PG_META_DB_HOST=postgres
      - PG_META_DB_PORT=5432
      - PG_META_DB_NAME=supabase
      - PG_META_DB_USER=postgres
      - PG_META_DB_PASSWORD=${POSTGRES_PASSWORD}
    networks:
      - automation-network
    depends_on:
      postgres:
        condition: service_healthy

  # MinIO - Object Storage
  minio:
    image: minio/minio:latest
    restart: always
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ROOT_USER}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
    volumes:
      - minio_data:/data
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      # API
      - "traefik.http.routers.minio-api.rule=Host(`s3.${DOMAIN_NAME}`)"
      - "traefik.http.routers.minio-api.tls=true"
      - "traefik.http.routers.minio-api.entrypoints=websecure"
      - "traefik.http.routers.minio-api.tls.certresolver=letsencrypt"
      - "traefik.http.routers.minio-api.service=minio-api"
      - "traefik.http.services.minio-api.loadbalancer.server.port=9000"
      # Console
      - "traefik.http.routers.minio-console.rule=Host(`minio.${DOMAIN_NAME}`)"
      - "traefik.http.routers.minio-console.tls=true"
      - "traefik.http.routers.minio-console.entrypoints=websecure"
      - "traefik.http.routers.minio-console.tls.certresolver=letsencrypt"
      - "traefik.http.routers.minio-console.service=minio-console"
      - "traefik.http.services.minio-console.loadbalancer.server.port=9001"
EOFCOMPOSE

# Add optional services to docker-compose.yml
if [[ "$INSTALL_OLLAMA" == "true" ]]; then
    cat >> docker-compose.yml << 'EOFOLLAMA'

  # Ollama - Local LLM
  ollama:
    image: ollama/ollama:latest
    restart: always
    volumes:
      - ollama_data:/root/.ollama
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ollama.rule=Host(`ollama.${DOMAIN_NAME}`)"
      - "traefik.http.routers.ollama.tls=true"
      - "traefik.http.routers.ollama.entrypoints=websecure"
      - "traefik.http.routers.ollama.tls.certresolver=letsencrypt"
      - "traefik.http.services.ollama.loadbalancer.server.port=11434"
EOFOLLAMA
fi

if [[ "$INSTALL_OPENWEBUI" == "true" ]]; then
    cat >> docker-compose.yml << 'EOFOPENWEBUI'

  # Open WebUI - Chat Interface for Ollama
  open-webui:
    image: ghcr.io/open-webui/open-webui:latest
    restart: always
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    volumes:
      - open_webui_data:/app/backend/data
    networks:
      - automation-network
    depends_on:
      - ollama
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.openwebui.rule=Host(`ai.${DOMAIN_NAME}`)"
      - "traefik.http.routers.openwebui.tls=true"
      - "traefik.http.routers.openwebui.entrypoints=websecure"
      - "traefik.http.routers.openwebui.tls.certresolver=letsencrypt"
      - "traefik.http.services.openwebui.loadbalancer.server.port=8080"
EOFOPENWEBUI
fi

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    cat >> docker-compose.yml << 'EOFMONITORING'

  # Prometheus - Metrics Collection
  prometheus:
    image: prom/prometheus:latest
    restart: always
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.${DOMAIN_NAME}`)"
      - "traefik.http.routers.prometheus.tls=true"
      - "traefik.http.routers.prometheus.entrypoints=websecure"
      - "traefik.http.routers.prometheus.tls.certresolver=letsencrypt"
      - "traefik.http.services.prometheus.loadbalancer.server.port=9090"

  # Grafana - Monitoring Dashboard
  grafana:
    image: grafana/grafana:latest
    restart: always
    environment:
      - GF_SERVER_ROOT_URL=https://grafana.${DOMAIN_NAME}
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_INSTALL_PLUGINS=
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - automation-network
    depends_on:
      - prometheus
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana.${DOMAIN_NAME}`)"
      - "traefik.http.routers.grafana.tls=true"
      - "traefik.http.routers.grafana.entrypoints=websecure"
      - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
EOFMONITORING
fi

if [[ "$INSTALL_UPTIME" == "true" ]]; then
    cat >> docker-compose.yml << 'EOFUPTIME'

  # Uptime Kuma - Service Monitoring
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    restart: always
    volumes:
      - uptime_kuma_data:/app/data
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.uptime.rule=Host(`uptime.${DOMAIN_NAME}`)"
      - "traefik.http.routers.uptime.tls=true"
      - "traefik.http.routers.uptime.entrypoints=websecure"
      - "traefik.http.routers.uptime.tls.certresolver=letsencrypt"
      - "traefik.http.services.uptime.loadbalancer.server.port=3001"
EOFUPTIME
fi

if [[ "$INSTALL_PORTAINER" == "true" ]]; then
    cat >> docker-compose.yml << 'EOFPORTAINER'

  # Portainer - Container Management
  portainer:
    image: portainer/portainer-ce:latest
    restart: always
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - automation-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`portainer.${DOMAIN_NAME}`)"
      - "traefik.http.routers.portainer.tls=true"
      - "traefik.http.routers.portainer.entrypoints=websecure"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
EOFPORTAINER
fi

# Now add volumes section
cat >> docker-compose.yml << 'EOFVOLUMES'

volumes:
  traefik_data:
  postgres_data:
  redis_data:
  n8n_data:
  qdrant_data:
  supabase_storage:
  minio_data:
EOFVOLUMES

# Add optional service volumes
if [[ "$INSTALL_OLLAMA" == "true" ]]; then
    echo "  ollama_data:" >> docker-compose.yml
fi

if [[ "$INSTALL_OPENWEBUI" == "true" ]]; then
    echo "  open_webui_data:" >> docker-compose.yml
fi

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    echo "  prometheus_data:" >> docker-compose.yml
    echo "  grafana_data:" >> docker-compose.yml
fi

if [[ "$INSTALL_UPTIME" == "true" ]]; then
    echo "  uptime_kuma_data:" >> docker-compose.yml
fi

if [[ "$INSTALL_PORTAINER" == "true" ]]; then
    echo "  portainer_data:" >> docker-compose.yml
fi

# Finally add networks section
cat >> docker-compose.yml << 'EOFNETWORKS'

networks:
  automation-network:
    driver: bridge
EOFNETWORKS

print_success "docker-compose.yml created"

# Create .env file
print_info "Creating .env file with generated keys..."
cat > .env << EOFENV
# ==============================================
# DOMAIN CONFIGURATION
# ==============================================
DOMAIN_NAME=$DOMAIN_NAME
N8N_SUBDOMAIN=$N8N_SUBDOMAIN
SSL_EMAIL=$SSL_EMAIL

# ==============================================
# TIMEZONE CONFIGURATION
# ==============================================
GENERIC_TIMEZONE=$GENERIC_TIMEZONE

# ==============================================
# POSTGRESQL DATABASE
# ==============================================
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# ==============================================
# REDIS CONFIGURATION
# ==============================================
REDIS_PASSWORD=$REDIS_PASSWORD

# ==============================================
# QDRANT CONFIGURATION
# ==============================================
QDRANT_API_KEY=$QDRANT_API_KEY

# ==============================================
# SUPABASE CONFIGURATION
# ==============================================
SUPABASE_JWT_SECRET=$SUPABASE_JWT_SECRET
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY
SUPABASE_DASHBOARD_PASSWORD=$SUPABASE_DASHBOARD_PASSWORD

# ==============================================
# MINIO CONFIGURATION
# ==============================================
MINIO_ROOT_USER=$MINIO_ROOT_USER
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD
EOFENV

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    cat >> .env << EOFGRAFANA

# ==============================================
# GRAFANA CONFIGURATION
# ==============================================
GRAFANA_PASSWORD=$GRAFANA_PASSWORD
EOFGRAFANA
fi

print_success ".env file created with auto-generated secure keys"

# Set secure permissions on .env
chmod 600 .env
print_success "Secure permissions set on .env file (600)"

# Create init script for PostgreSQL
print_info "Creating PostgreSQL initialization script..."
mkdir -p init-scripts
cat > init-scripts/init-db.sh << 'EOFINIT'
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE n8n;
    CREATE DATABASE supabase;
    
    -- Enable extensions for Supabase
    \c supabase
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";
    CREATE EXTENSION IF NOT EXISTS "pgjwt";
    
    -- Create auth schema for Supabase
    CREATE SCHEMA IF NOT EXISTS auth;
    CREATE SCHEMA IF NOT EXISTS storage;
EOSQL
EOFINIT

chmod +x init-scripts/init-db.sh
print_success "PostgreSQL initialization script created"

# Create Supabase Kong configuration
if [ ! -d "supabase" ]; then
    mkdir -p supabase
fi

print_info "Creating Supabase Kong configuration..."
cat > supabase/kong.yml << 'EOFKONG'
_format_version: "1.1"

services:
  - name: auth-v1-open
    url: http://supabase-auth:9999/verify
    routes:
      - name: auth-v1-open
        strip_path: true
        paths:
          - /auth/v1/verify
    plugins:
      - name: cors

  - name: auth-v1
    url: http://supabase-auth:9999
    routes:
      - name: auth-v1-all
        strip_path: true
        paths:
          - /auth/v1/
    plugins:
      - name: cors

  - name: rest-v1
    url: http://supabase-rest:3000
    routes:
      - name: rest-v1-all
        strip_path: true
        paths:
          - /rest/v1/
    plugins:
      - name: cors
      - name: key-auth
        config:
          hide_credentials: false

  - name: realtime-v1
    url: http://supabase-realtime:4000/socket
    routes:
      - name: realtime-v1-all
        strip_path: true
        paths:
          - /realtime/v1/
    plugins:
      - name: cors

  - name: storage-v1
    url: http://supabase-storage:5000
    routes:
      - name: storage-v1-all
        strip_path: true
        paths:
          - /storage/v1/
    plugins:
      - name: cors

consumers:
  - username: anon
    keyauth_credentials:
      - key: ${SUPABASE_ANON_KEY}
  - username: service_role
    keyauth_credentials:
      - key: ${SUPABASE_SERVICE_KEY}
EOFKONG

print_success "Supabase Kong configuration created"

# Create monitoring configuration
if [[ "$INSTALL_MONITORING" == "true" ]]; then
    mkdir -p monitoring
    print_info "Creating Prometheus configuration..."
    cat > monitoring/prometheus.yml << 'EOFPROM'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
EOFPROM
    print_success "Prometheus configuration created"
fi

################################################################################
# STEP 7: Create Required Directories
################################################################################

print_header "Step 7: Creating Required Directories"

print_info "Creating data directories..."
mkdir -p n8n-files

print_success "Directories created"

################################################################################
# STEP 8: Pull Docker Images
################################################################################

print_header "Step 8: Downloading Docker Images"

print_info "This may take several minutes depending on your internet connection..."
docker compose pull

print_success "All Docker images downloaded"

################################################################################
# STEP 9: Start Services
################################################################################

print_header "Step 9: Starting Services"

print_info "Starting all services..."
docker compose up -d

print_info "Waiting for services to initialize (60 seconds)..."
sleep 60

print_success "Services started"

################################################################################
# STEP 10: Service Verification
################################################################################

print_header "Step 10: Verifying Deployment"

print_info "Checking service status..."
docker compose ps

sleep 2

################################################################################
# DEPLOYMENT COMPLETE
################################################################################

print_header "🎉 Deployment Complete!"

cat << EOF

${GREEN}${BOLD}Installation Summary${NC}
${GREEN}═══════════════════════════════════════════${NC}

${CYAN}${BOLD}Core Services:${NC}
  • n8n:       ${GREEN}https://$N8N_SUBDOMAIN.$DOMAIN_NAME${NC}
  • Qdrant:    ${GREEN}https://qdrant.$DOMAIN_NAME${NC}
  • Supabase:  ${GREEN}https://supabase.$DOMAIN_NAME${NC}
  • MinIO API: ${GREEN}https://s3.$DOMAIN_NAME${NC}
  • MinIO UI:  ${GREEN}https://minio.$DOMAIN_NAME${NC}
  • Traefik:   ${GREEN}http://$SERVER_IP:8080${NC}

EOF

if [[ "$INSTALL_OLLAMA" == "true" ]]; then
    echo -e "${CYAN}${BOLD}AI Services:${NC}"
    echo -e "  • Ollama:    ${GREEN}https://ollama.$DOMAIN_NAME${NC}"
fi

if [[ "$INSTALL_OPENWEBUI" == "true" ]]; then
    echo -e "  • Open WebUI: ${GREEN}https://ai.$DOMAIN_NAME${NC}"
fi

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    echo ""
    echo -e "${CYAN}${BOLD}Monitoring:${NC}"
    echo -e "  • Grafana:    ${GREEN}https://grafana.$DOMAIN_NAME${NC}"
    echo -e "  • Prometheus: ${GREEN}https://prometheus.$DOMAIN_NAME${NC}"
fi

if [[ "$INSTALL_UPTIME" == "true" ]]; then
    echo -e "  • Uptime Kuma: ${GREEN}https://uptime.$DOMAIN_NAME${NC}"
fi

if [[ "$INSTALL_PORTAINER" == "true" ]]; then
    echo ""
    echo -e "${CYAN}${BOLD}Management:${NC}"
    echo -e "  • Portainer:  ${GREEN}https://portainer.$DOMAIN_NAME${NC}"
fi

cat << EOF

${CYAN}${BOLD}Credentials:${NC}

  ${BOLD}PostgreSQL:${NC}
    User:     postgres
    Password: $POSTGRES_PASSWORD
    
  ${BOLD}Redis:${NC}
    Password: $REDIS_PASSWORD
    
  ${BOLD}Qdrant:${NC}
    API Key:  $QDRANT_API_KEY
    
  ${BOLD}Supabase:${NC}
    JWT Secret:     $SUPABASE_JWT_SECRET
    Anon Key:       $SUPABASE_ANON_KEY
    Service Key:    $SUPABASE_SERVICE_KEY
    Dashboard Pass: $SUPABASE_DASHBOARD_PASSWORD
    
  ${BOLD}MinIO:${NC}
    User:     $MINIO_ROOT_USER
    Password: $MINIO_ROOT_PASSWORD

EOF

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    cat << EOFGRAF
  ${BOLD}Grafana:${NC}
    User:     admin
    Password: $GRAFANA_PASSWORD

EOFGRAF
fi

cat << EOF
${CYAN}${BOLD}Installation Location:${NC}
  • Directory: ${GREEN}$(pwd)${NC}

${CYAN}${BOLD}Next Steps:${NC}

  ${BOLD}1. Access n8n:${NC}
     Visit: https://$N8N_SUBDOMAIN.$DOMAIN_NAME
     Create your owner account on first visit

  ${BOLD}2. Access Supabase:${NC}
     Visit: https://supabase.$DOMAIN_NAME
     Use the dashboard password above

  ${BOLD}3. Configure MinIO:${NC}
     Visit: https://minio.$DOMAIN_NAME
     Login and create your first bucket

EOF

if [[ "$INSTALL_OLLAMA" == "true" ]]; then
    cat << EOFOLLAMA2
  ${BOLD}4. Setup Ollama:${NC}
     Pull a model: docker compose exec ollama ollama pull llama2
     Test: curl https://ollama.$DOMAIN_NAME/api/tags

EOFOLLAMA2
fi

if [[ "$INSTALL_MONITORING" == "true" ]]; then
    cat << EOFGRAF2
  ${BOLD}5. Configure Grafana:${NC}
     Visit: https://grafana.$DOMAIN_NAME
     Add Prometheus data source: http://prometheus:9090

EOFGRAF2
fi

cat << EOF
${CYAN}${BOLD}Useful Commands:${NC}

  ${BOLD}View logs:${NC}
    docker compose logs -f

  ${BOLD}View specific service:${NC}
    docker compose logs -f n8n
    docker compose logs -f qdrant
    docker compose logs -f supabase-studio

  ${BOLD}Restart services:${NC}
    docker compose restart

  ${BOLD}Stop services:${NC}
    docker compose down

  ${BOLD}Update services:${NC}
    docker compose pull
    docker compose up -d

  ${BOLD}Check status:${NC}
    docker compose ps

  ${BOLD}Backup data:${NC}
    tar czf backup-\$(date +%Y%m%d).tar.gz .

${YELLOW}${BOLD}⚠️  IMPORTANT:${NC}
  • SSL certificates may take 2-5 minutes to generate
  • Keep your .env file secure - it contains all passwords!
  • Set up regular backups of data directories
  • All credentials are saved in: ${YELLOW}.env${NC}

${GREEN}${BOLD}Documentation:${NC}
  • n8n: https://docs.n8n.io
  • Qdrant: https://qdrant.tech/documentation/
  • Supabase: https://supabase.com/docs
  • MinIO: https://min.io/docs/minio/linux/index.html

${GREEN}═══════════════════════════════════════════${NC}
${GREEN}${BOLD}Thank you for using this installer!${NC}
${GREEN}═══════════════════════════════════════════${NC}

EOF

# Save installation info
cat > INSTALLATION_INFO.txt << EOFINST
Installation completed on: $(date)
Server IP: $SERVER_IP
Domain: $DOMAIN_NAME

Core Services:
- n8n: https://$N8N_SUBDOMAIN.$DOMAIN_NAME
- Qdrant: https://qdrant.$DOMAIN_NAME
- Supabase: https://supabase.$DOMAIN_NAME
- MinIO: https://minio.$DOMAIN_NAME

Optional Services Installed:
- Ollama: $INSTALL_OLLAMA
- Open WebUI: $INSTALL_OPENWEBUI
- Monitoring (Grafana+Prometheus): $INSTALL_MONITORING
- Uptime Kuma: $INSTALL_UPTIME
- Portainer: $INSTALL_PORTAINER

Timezone: $GENERIC_TIMEZONE
Installation Directory: $(pwd)

All credentials are stored in .env file
EOFINST

print_success "Installation information saved to INSTALLATION_INFO.txt"

exit 0
