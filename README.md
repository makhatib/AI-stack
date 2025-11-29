<p align="center">
  <img src="https://media.licdn.com/dms/image/v2/D4D16AQFqdNamtkN1zA/profile-displaybackgroundimage-shrink_200_800/profile-displaybackgroundimage-shrink_200_800/0/1719354356592?e=2147483647&v=beta&t=Gix6oMHUtn3k9wB7Ac2-Sh7hKFpvtAglgFJkrZKYHJo" alt="شعار قناة محمود الخطيب" width="100%" />
</p>

# 🚀 Advanced Automation Stack - Automated Installer

## Overview

This comprehensive installer deploys a complete **AI-powered automation infrastructure** with workflow automation, vector search, backend services, and object storage - all with automatic SSL certificates and secure password generation.

## 🎯 What Gets Installed

### **Core Services** (Always Installed)

#### 1. **n8n** - Workflow Automation
- Visual workflow builder
- 400+ integrations
- Webhook support
- Scheduled workflows
- **URL:** `https://n8n.yourdomain.com`

#### 2. **PostgreSQL** - Database
- Shared database for all services
- pgvector extension enabled
- Optimized for AI workloads
- **Internal:** Port 5432

#### 3. **Redis** - Cache & Queue
- High-performance caching
- Job queue management
- Session storage
- **Internal:** Port 6379

#### 4. **Qdrant** - Vector Database
- AI embeddings storage
- Semantic search
- RAG (Retrieval Augmented Generation)
- **URL:** `https://qdrant.yourdomain.com`

#### 5. **MinIO** - Object Storage
- S3-compatible API
- File uploads & storage
- Bucket management
- **API:** `https://s3.yourdomain.com`
- **Console:** `https://minio.yourdomain.com`

#### 6. **Traefik** - Reverse Proxy
- Automatic SSL certificates
- HTTP to HTTPS redirect
- Load balancing
- **Dashboard:** `http://server-ip:8080`

---

### **Optional Services** (Choose During Installation)

#### 8. **Ollama** - Local LLM 🤖
- Run AI models locally
- No API costs (GPT-like capabilities)
- Privacy-first
- Generate embeddings for Qdrant
- **URL:** `https://ollama.yourdomain.com`

**Use Cases:**
- Generate embeddings from text
- Answer questions with RAG
- Summarize documents
- Extract information

#### 9. **Open WebUI** - AI Chat Interface 🤖
- Beautiful chat interface for Ollama
- Multiple model support
- Chat history
- RAG functionality
- **URL:** `https://ai.yourdomain.com`
- **Requires:** Ollama

#### 10. **Grafana + Prometheus** - Monitoring Stack 📊
- Monitor all services
- Custom dashboards
- Metrics collection
- Performance insights
- **Grafana:** `https://grafana.yourdomain.com`
- **Prometheus:** `https://prometheus.yourdomain.com`

#### 11. **Uptime Kuma** - Service Monitoring 📈
- Monitor service uptime
- SMS/Email/Webhook alerts
- Beautiful status page
- Response time tracking
- **URL:** `https://uptime.yourdomain.com`

#### 12. **Portainer** - Container Management 🐳
- Visual Docker management
- Container logs & stats
- Easy updates
- Stack management
- **URL:** `https://portainer.yourdomain.com`

---

## 📋 Prerequisites

### Server Requirements
- **OS:** Ubuntu 20.04+ or Debian 11+
- **RAM:** 4GB minimum (8GB+ recommended)
- **CPU:** 2+ cores (4+ recommended for AI)
- **Disk:** 50GB+ free space
- **Ports:** 80, 443, 8080 must be available

### Software Requirements
- Docker 20.10+
- Docker Compose v2.0+
- OpenSSL
- curl

### Install Docker (if needed)
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

---

## 🚀 Quick Start

### Step 1: Configure DNS (CRITICAL!)

**Before running the installer**, configure these DNS A records:

**Core Services:**
```
n8n.yourdomain.com        A    YOUR_SERVER_IP
qdrant.yourdomain.com     A    YOUR_SERVER_IP
supabase.yourdomain.com   A    YOUR_SERVER_IP
minio.yourdomain.com      A    YOUR_SERVER_IP
s3.yourdomain.com         A    YOUR_SERVER_IP
```

**Optional Services** (if you plan to install them):
```
ollama.yourdomain.com     A    YOUR_SERVER_IP
ai.yourdomain.com         A    YOUR_SERVER_IP
grafana.yourdomain.com    A    YOUR_SERVER_IP
prometheus.yourdomain.com A    YOUR_SERVER_IP
uptime.yourdomain.com     A    YOUR_SERVER_IP
portainer.yourdomain.com  A    YOUR_SERVER_IP
```

**Wait 5-30 minutes for DNS propagation!**

Verify with:
```bash
nslookup n8n.yourdomain.com
```

### Step 2: Download & Run Installer

```bash
# Download the installer
git clone https://raw.githubusercontent.com/YOUR_REPO/install-advanced.sh](https://github.com/makhatib/AI-stack.git

# Enter folder 
cd AI-stack

# Make executable
chmod +x install-advanced.sh

# Run installer
./install-advanced.sh
```

### Step 3: Answer Prompts

The installer will ask you:

1. **Domain name** (e.g., `yourdomain.com`)
2. **n8n subdomain** (default: `n8n`)
3. **SSL email** (for Let's Encrypt)
4. **Timezone** (choose from list)
5. **Optional services** (Y/n for each):
   - Ollama (Local LLM)
   - Open WebUI (Chat interface)
   - Grafana + Prometheus (Monitoring)
   - Uptime Kuma (Service monitoring)
   - Portainer (Container management)

### Step 4: Wait for Installation

- Prerequisites check: ~30 seconds
- Docker image download: 5-10 minutes
- Service startup: ~2 minutes
- SSL certificate generation: 2-5 minutes

**Total time: 10-20 minutes**

---

## 🔐 Security Features

### Auto-Generated Secrets

Every installation generates **unique, cryptographically secure** passwords:

- **PostgreSQL Password:** 64 characters (128-bit entropy)
- **Redis Password:** 64 characters
- **Qdrant API Key:** 64 characters
- **MinIO Credentials:** 32 characters
- **Grafana Password:** 32 characters (if installed)

**No two installations share the same credentials!**

### Additional Security

- ✅ HTTPS enforced (HTTP redirects to HTTPS)
- ✅ Let's Encrypt automatic SSL certificates
- ✅ Secure file permissions (`.env` = 600)
- ✅ Password-protected services
- ✅ Isolated Docker network
- ✅ No hardcoded defaults

---

## 📊 Architecture

### Service Dependencies

```
Internet
   ↓
Traefik (SSL/Reverse Proxy)
   ├─→ n8n → PostgreSQL
   ├─→ Qdrant (Vector Search)
   │    ├─→ Auth
   │    ├─→ REST API
   │    ├─→ Realtime
   │    └─→ Storage
   ├─→ MinIO (S3 Storage)
   ├─→ Ollama (if installed)
   ├─→ Open WebUI → Ollama (if installed)
   ├─→ Grafana → Prometheus (if installed)
   ├─→ Uptime Kuma (if installed)
   └─→ Portainer (if installed)

Shared Infrastructure:
   • PostgreSQL (shared DB)
   • Redis (shared cache)
```

### Network Architecture

All services communicate on the **`automation-network`** bridge network:
- Internal DNS resolution
- Service isolation
- Secure inter-service communication

---

## 💡 Use Cases & Integration Examples

### 1. AI-Powered Document Processing

```
Upload PDF → MinIO
           → n8n workflow triggers
           → Ollama extracts text
           → Ollama generates embeddings
           → Store in Qdrant
           → Save metadata in Supabase
```

**n8n Workflow:**
```javascript
// 1. Trigger: MinIO file upload webhook
// 2. Get file from MinIO
// 3. Send to Ollama for text extraction
// 4. Generate embeddings with Ollama
// 5. Store embeddings in Qdrant
// 6. Save metadata to Supabase REST API
```

### 2. Semantic Search System

```
User query → n8n workflow
           → Generate query embedding (Ollama)
           → Search Qdrant for similar vectors
           → Retrieve top matches
           → Send to Ollama for answer generation
           → Return formatted response
```

### 3. Data Pipeline with Monitoring

```
Schedule (n8n) → Extract data from API
               → Transform data
               → Load to PostgreSQL
               → Grafana auto-updates dashboard
               → Uptime Kuma monitors job
```

### 4. AI Chat with Knowledge Base (RAG)

```
User message → Open WebUI
            → Generate embedding (Ollama)
            → Search knowledge base (Qdrant)
            → Combine context + query
            → Generate answer (Ollama)
            → Stream response to user
```

### 5. File Processing Automation

```
File upload → MinIO
           → Webhook to n8n
           → Process file
           → Store results in Supabase
           → Send notification
```

---

## 🛠️ Post-Installation Setup

### Configure n8n

1. Visit `https://n8n.yourdomain.com`
2. Create owner account
3. Explore workflow templates
4. Connect integrations

**Useful n8n Nodes:**
- **Qdrant:** Vector search operations
- **S3/MinIO:** File storage operations
- **HTTP Request:** Call Ollama API
- **PostgreSQL:** Direct database queries

### Configure MinIO

1. Visit `https://minio.yourdomain.com`
2. Login with credentials (from `.env`)
3. Create first bucket
4. Set bucket policy
5. Get access keys

**MinIO with n8n:**
```javascript
// n8n S3 node configuration
{
  "endpoint": "https://s3.yourdomain.com",
  "accessKeyId": "YOUR_MINIO_USER",
  "secretAccessKey": "YOUR_MINIO_PASSWORD",
  "bucket": "your-bucket"
}
```

### Setup Ollama (if installed)

1. Pull AI model:
```bash
docker compose exec ollama ollama pull llama2
# or
docker compose exec ollama ollama pull mistral
```

2. Test Ollama:
```bash
curl https://ollama.yourdomain.com/api/tags
```

3. Generate text:
```bash
curl https://ollama.yourdomain.com/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?"
}'
```

4. Use in n8n:
```javascript
// HTTP Request node to Ollama
POST https://ollama.yourdomain.com/api/generate
{
  "model": "llama2",
  "prompt": "{{$json.userQuery}}",
  "stream": false
}
```

### Configure Qdrant

1. Access API: `https://qdrant.yourdomain.com`
2. Use API key from `.env`
3. Create collection
4. Insert vectors

**Example with Python:**
```python
from qdrant_client import QdrantClient

client = QdrantClient(
    url="https://qdrant.yourdomain.com",
    api_key="YOUR_QDRANT_API_KEY"
)

# Create collection
client.create_collection(
    collection_name="documents",
    vectors_config={"size": 384, "distance": "Cosine"}
)

# Insert vector
client.upsert(
    collection_name="documents",
    points=[{
        "id": 1,
        "vector": [0.1, 0.2, ...],  # 384 dimensions
        "payload": {"text": "Document content"}
    }]
)
```

### Setup Grafana (if installed)

1. Visit `https://grafana.yourdomain.com`
2. Login (admin / password from `.env`)
3. Add data source:
   - Type: Prometheus
   - URL: `http://prometheus:9090`
4. Import dashboards
5. Create custom dashboards

---

## 📝 Useful Commands

### Service Management

```bash
# Navigate to installation
cd automation-stack

# View all logs
docker compose logs -f

# View specific service
docker compose logs -f n8n
docker compose logs -f qdrant
docker compose logs -f ollama

# Restart all services
docker compose restart

# Restart specific service
docker compose restart n8n

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Check service status
docker compose ps

# View resource usage
docker stats
```

### Ollama Management

```bash
# List installed models
docker compose exec ollama ollama list

# Pull new model
docker compose exec ollama ollama pull llama2

# Remove model
docker compose exec ollama ollama rm llama2

# Run model interactively
docker compose exec ollama ollama run llama2
```

### Database Operations

```bash
# Access PostgreSQL
docker compose exec postgres psql -U postgres

# List databases
docker compose exec postgres psql -U postgres -c "\l"

# Connect to n8n database
docker compose exec postgres psql -U postgres -d n8n

# Backup database
docker compose exec postgres pg_dump -U postgres n8n > backup-n8n.sql

# Restore database
cat backup-n8n.sql | docker compose exec -T postgres psql -U postgres -d n8n
```

### MinIO Operations

```bash
# Access MinIO Client
docker compose exec minio mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD

# List buckets
docker compose exec minio mc ls local

# Create bucket
docker compose exec minio mc mb local/my-bucket

# Upload file
docker compose exec minio mc cp /path/to/file local/my-bucket/
```

---

## 🔧 Troubleshooting

### Services Won't Start

```bash
# Check logs for errors
docker compose logs --tail=100

# Check specific service
docker compose logs rails --tail=50

# Verify ports aren't in use
netstat -tulpn | grep -E ':80|:443'

# Restart Docker
sudo systemctl restart docker
docker compose up -d
```

### SSL Certificates Not Generating

```bash
# Check Traefik logs
docker compose logs traefik

# Verify DNS
nslookup n8n.yourdomain.com

# Manual certificate check
curl -I https://n8n.yourdomain.com

# Wait 5-10 minutes - Let's Encrypt can be slow
```

### Ollama Not Responding

```bash
# Check if Ollama is running
docker compose ps ollama

# Check logs
docker compose logs ollama

# Restart Ollama
docker compose restart ollama

# Check if models are pulled
docker compose exec ollama ollama list
```

### Supabase Issues

```bash
# Check all Supabase services
docker compose ps | grep supabase

# Check auth service
docker compose logs supabase-auth

# Check database connection
docker compose exec postgres psql -U postgres -d supabase -c "SELECT 1;"

# Restart Supabase stack
docker compose restart supabase-studio supabase-auth supabase-rest
```

### Out of Memory

```bash
# Check memory usage
free -h
docker stats

# Increase swap (temporary fix)
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
sudo mkswap /swapfile
sudo swapon /swapfile

# Long-term: Upgrade server RAM to 8GB+
```

---

## 💾 Backup & Restore

### Quick Backup

```bash
# Backup everything
tar czf backup-$(date +%Y%m%d).tar.gz \
  docker-compose.yml \
  .env \
  init-scripts/ \
  supabase/ \
  monitoring/

# Backup databases
docker compose exec postgres pg_dumpall -U postgres > backup-databases.sql

# Backup volumes
docker run --rm \
  -v automation-stack_n8n_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/n8n-backup.tar.gz -C /data .
```

### Restore

```bash
# Restore configuration
tar xzf backup-YYYYMMDD.tar.gz

# Restore databases
cat backup-databases.sql | docker compose exec -T postgres psql -U postgres

# Restore volumes
docker run --rm \
  -v automation-stack_n8n_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/n8n-backup.tar.gz -C /data
```

### Automated Backups

Create `/root/backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/root/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup databases
docker compose -f /root/automation-stack/docker-compose.yml \
  exec -T postgres pg_dumpall -U postgres > $BACKUP_DIR/db-$DATE.sql

# Backup configuration
tar czf $BACKUP_DIR/config-$DATE.tar.gz \
  -C /root/automation-stack \
  docker-compose.yml .env

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

Add to crontab:
```bash
# Daily backup at 2 AM
0 2 * * * /root/backup.sh
```

---

## 🔄 Updating Services

### Update All Services

```bash
cd automation-stack

# Pull latest images
docker compose pull

# Recreate containers
docker compose up -d

# Check logs
docker compose logs -f
```

### Update Specific Service

```bash
# Update just n8n
docker compose pull n8n
docker compose up -d n8n

# Update Ollama
docker compose pull ollama
docker compose up -d ollama
```

---

## 📞 Support & Resources

### Documentation

- **n8n:** https://docs.n8n.io
- **Qdrant:** https://qdrant.tech/documentation/
- **MinIO:** https://min.io/docs/
- **Ollama:** https://ollama.ai/
- **Grafana:** https://grafana.com/docs/
- **Prometheus:** https://prometheus.io/docs/

### Community


👉 موقعي الالكتروني: https://malkhatib.com/
👉 لينكدإن:   / malkhatib1  
👉 الديسكورد:   / discord  
👉 تليجرام: https://t.me/+YAHmKBLoLWoxNWQ0
👉 تويتر:   / malkhateeb  

---

## ⚠️ Important Notes

- **First Run:** SSL certificates take 2-5 minutes to generate
- **DNS:** Must be configured BEFORE installation
- **Backups:** Set up automated backups immediately
- **Security:** Keep `.env` file secure
- **Updates:** Check for updates monthly
- **Monitoring:** Use Grafana to track resource usage

---

## 🎉 Next Steps

After installation:

1. ✅ Access each service and verify it works
2. ✅ Configure n8n with your first workflow
3. ✅ Pull Ollama models (if installed)
4. ✅ Set up Grafana dashboards (if installed)
5. ✅ Create Supabase database tables
6. ✅ Configure MinIO buckets
7. ✅ Set up automated backups
8. ✅ Monitor services with Uptime Kuma (if installed)

---

**Enjoy your advanced automation infrastructure! 🚀**
