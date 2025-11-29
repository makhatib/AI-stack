# ⚡ Quick Start Guide - 5 Minutes to Deploy

## 🎯 What You'll Get

**Core Services (Always):**
- n8n - Workflow automation
- PostgreSQL - Database
- Redis - Cache
- Qdrant - Vector search (AI)
- Supabase - Backend API
- MinIO - File storage

**Optional Services (Your Choice):**
- Ollama - Local AI/LLM
- Open WebUI - AI chat
- Grafana/Prometheus - Monitoring
- Uptime Kuma - Uptime monitoring
- Portainer - Container management

---

## 📋 Before You Start

### 1. Server Ready?
```bash
# Check Docker
docker --version

# If not installed:
curl -fsSL https://get.docker.com | sh
```

### 2. DNS Configured?

Point these to your server IP:
```
n8n.yourdomain.com       →  YOUR_IP
qdrant.yourdomain.com    →  YOUR_IP
supabase.yourdomain.com  →  YOUR_IP
minio.yourdomain.com     →  YOUR_IP
s3.yourdomain.com        →  YOUR_IP
```

Plus optional services you want:
```
ollama.yourdomain.com     →  YOUR_IP
ai.yourdomain.com         →  YOUR_IP
grafana.yourdomain.com    →  YOUR_IP
prometheus.yourdomain.com →  YOUR_IP
uptime.yourdomain.com     →  YOUR_IP
portainer.yourdomain.com  →  YOUR_IP
```

**Wait 5-30 min for DNS to propagate!**

---

## 🚀 Installation (3 Commands)

```bash
# 1. Download installer
wget https://your-repo/install-advanced.sh

# 2. Make executable
chmod +x install-advanced.sh

# 3. Run it
./install-advanced.sh
```

---

## 💬 Answer Prompts

The installer will ask:

1. **Domain:** `yourdomain.com`
2. **n8n subdomain:** `n8n` (or custom)
3. **SSL email:** `your@email.com`
4. **Timezone:** Choose from list
5. **Install Ollama?** `Y` or `n`
6. **Install Open WebUI?** `Y` or `n` (needs Ollama)
7. **Install Grafana/Prometheus?** `Y` or `n`
8. **Install Uptime Kuma?** `Y` or `n`
9. **Install Portainer?** `Y` or `n`

**Recommendation:** Install all optional services!

---

## ⏱️ Wait Times

- Image download: **5-10 min**
- Service startup: **2 min**
- SSL certs: **2-5 min**

**Total: ~10-15 minutes**

☕ Grab coffee!

---

## ✅ What Happens Next

The installer will:

1. ✅ Check Docker, ports, etc.
2. ✅ Generate **unique secure passwords**
3. ✅ Create docker-compose.yml
4. ✅ Download all Docker images
5. ✅ Start all services
6. ✅ Initialize databases
7. ✅ Show you all URLs and passwords

---

## 🎉 After Installation

### URLs You'll Get:

```
n8n:      https://n8n.yourdomain.com
Qdrant:   https://qdrant.yourdomain.com
Supabase: https://supabase.yourdomain.com
MinIO:    https://minio.yourdomain.com
```

Plus any optional services you chose!

### Passwords:

**All saved in `.env` file** - installer shows them at the end!

---

## 🔥 First Steps

### 1. Access n8n
```
URL: https://n8n.yourdomain.com
Action: Create owner account on first visit
```

### 2. Access Supabase
```
URL: https://supabase.yourdomain.com
Login: Use password from installation output
```

### 3. Access MinIO
```
URL: https://minio.yourdomain.com
Login: Use credentials from installation output
Action: Create your first bucket
```

### 4. Pull AI Model (if Ollama installed)
```bash
cd automation-stack
docker compose exec ollama ollama pull llama2

# Or use Open WebUI at:
https://ai.yourdomain.com
```

### 5. Setup Monitoring (if Grafana installed)
```
URL: https://grafana.yourdomain.com
Login: admin / (password from install)
Action: Add Prometheus data source
```

---

## 🛠️ Useful Commands

```bash
# Go to install directory
cd automation-stack

# Check status
docker compose ps

# View logs
docker compose logs -f

# Restart everything
docker compose restart

# Stop everything
docker compose down

# Start everything
docker compose up -d

# Update everything
docker compose pull
docker compose up -d
```

---

## 🆘 Troubleshooting

### Can't access services?

**1. Check DNS:**
```bash
nslookup n8n.yourdomain.com
# Should return your server IP
```

**2. Wait for SSL:**
```bash
# SSL certs take 2-5 minutes
# Check Traefik logs:
docker compose logs traefik
```

**3. Check services:**
```bash
docker compose ps
# All should show "Up"
```

### Ollama not working?

```bash
# Check if running
docker compose ps ollama

# Pull a model first
docker compose exec ollama ollama pull llama2

# Test it
curl https://ollama.yourdomain.com/api/tags
```

### Out of memory?

```bash
# Check memory
free -h

# Upgrade server RAM to 8GB+
# Or reduce services
```

---

## 💾 Backup Your Install

```bash
# Quick backup
cd automation-stack
tar czf backup-$(date +%Y%m%d).tar.gz .

# Save to safe location!
```

---

## 📚 Need More Help?

- **Full Docs:** See `ADVANCED_INSTALLER_README.md`
- **Credentials:** Fill out `CREDENTIALS_TEMPLATE.md`
- **n8n Docs:** https://docs.n8n.io
- **Supabase Docs:** https://supabase.com/docs

---

## 🎯 Example: Your First Workflow

### AI-Powered File Processing

1. **Create n8n workflow:**
   - Trigger: MinIO file upload
   - Get file from MinIO
   - Send to Ollama for analysis
   - Store results in Supabase

2. **Upload file to MinIO:**
   - Go to `https://minio.yourdomain.com`
   - Upload PDF/image/document

3. **Watch magic happen:**
   - n8n processes file
   - AI analyzes content
   - Results stored in database

---

## ⚡ Pro Tips

1. **Pull Ollama models ASAP** - they're large (4-8GB each)
2. **Set up Uptime Kuma first** - monitor everything
3. **Use Portainer** - easier container management
4. **Bookmark Grafana** - watch your server health
5. **Backup the .env file** - contains ALL passwords

---

## 🚀 You're Ready!

That's it! Your advanced automation stack is running.

**Questions?** Check the full README or community forums.

**Enjoy!** 🎉

---

**Remember:**
- All passwords in `.env` file
- SSL certs auto-renew
- Backup regularly
- Monitor with Grafana/Uptime Kuma
- Update monthly

**Need detailed info?** Read `ADVANCED_INSTALLER_README.md`
