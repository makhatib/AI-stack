# 🔐 Installation Credentials Template

**IMPORTANT:** Fill this out after installation and store securely!

## Installation Information

**Installation Date:** ___________________  
**Server IP:** ___________________  
**Domain:** ___________________  
**Installer Version:** Advanced Stack v1.0

---

## 🌐 Service URLs

### Core Services
- **n8n:** https://_________________.___________________
- **Qdrant:** https://qdrant.___________________
- **Supabase:** https://supabase.___________________
- **MinIO Console:** https://minio.___________________
- **MinIO API (S3):** https://s3.___________________
- **Traefik Dashboard:** http://___________________ :8080

### Optional Services (if installed)
- **Ollama:** https://ollama.___________________ (Y/N: ___)
- **Open WebUI:** https://ai.___________________ (Y/N: ___)
- **Grafana:** https://grafana.___________________ (Y/N: ___)
- **Prometheus:** https://prometheus.___________________ (Y/N: ___)
- **Uptime Kuma:** https://uptime.___________________ (Y/N: ___)
- **Portainer:** https://portainer.___________________ (Y/N: ___)

---

## 🔑 Core Service Credentials

### PostgreSQL Database
```
Host:     postgres (internal) or localhost:5432 (if port forwarded)
User:     postgres
Password: ___________________________________________
Databases: n8n, supabase
```

### Redis Cache
```
Host:     redis (internal) or localhost:6379
Password: ___________________________________________
```

### Qdrant Vector Database
```
URL:      https://qdrant.yourdomain.com
API Key:  ___________________________________________
```

### Supabase
```
Dashboard URL:  https://supabase.yourdomain.com
Dashboard Pass: ___________________________________________

JWT Secret:     ___________________________________________
Anon Key:       ___________________________________________
Service Key:    ___________________________________________
```

### MinIO Object Storage
```
Console:  https://minio.yourdomain.com
API (S3): https://s3.yourdomain.com

Access Key (User): ___________________________________________
Secret Key (Pass): ___________________________________________
```

---

## 🤖 Optional Service Credentials

### Ollama (if installed)
```
URL:        https://ollama.yourdomain.com
API Key:    None (public by default)
Models:     Run: docker compose exec ollama ollama list

Installed Models:
- ___________________________________________
- ___________________________________________
- ___________________________________________
```

### Open WebUI (if installed)
```
URL:     https://ai.yourdomain.com
User:    (Create on first visit)
Pass:    ___________________________________________
```

### Grafana (if installed)
```
URL:      https://grafana.yourdomain.com
Username: admin
Password: ___________________________________________
```

### Prometheus (if installed)
```
URL:         https://prometheus.yourdomain.com
Auth:        None (internal use)
Access From: Grafana data source
```

### Uptime Kuma (if installed)
```
URL:     https://uptime.yourdomain.com
User:    (Create on first visit)
Pass:    ___________________________________________
```

### Portainer (if installed)
```
URL:     https://portainer.yourdomain.com
User:    (Create on first visit - usually 'admin')
Pass:    ___________________________________________
```

---

## 🔐 n8n Owner Account

```
URL:      https://n8n.yourdomain.com
Email:    ___________________________________________
Password: ___________________________________________
```

---

## 📋 Configuration Details

### Timezone
```
Selected Timezone: ___________________________________________
```

### SSL Configuration
```
SSL Email (Let's Encrypt): ___________________________________________
Certificate Resolver:      letsencrypt
```

### Network
```
Docker Network: automation-network
Network Driver: bridge
```

---

## 💾 Backup Information

### Backup Location
```
Local Path:  ___________________________________________
Remote Path: ___________________________________________
Frequency:   ___________________________________________
Last Backup: ___________________________________________
```

### Files to Backup
```
□ docker-compose.yml
□ .env file
□ init-scripts/
□ supabase/kong.yml
□ monitoring/prometheus.yml (if monitoring enabled)
□ PostgreSQL database (pg_dump)
□ n8n workflows (Docker volume)
□ Qdrant data (Docker volume)
□ MinIO buckets (Docker volume)
```

---

## 🛠️ Maintenance Schedule

### Weekly Tasks
```
□ Check service status: docker compose ps
□ Review logs for errors: docker compose logs --tail=100
□ Verify backups completed
□ Monitor disk space: df -h
```

### Monthly Tasks
```
□ Update services: docker compose pull && docker compose up -d
□ Test backup restoration
□ Review resource usage: docker stats
□ Update DNS records if needed
□ Rotate old logs
```

### Quarterly Tasks
```
□ Security audit
□ Review and update passwords
□ Check SSL certificate expiration
□ Update server OS packages
```

---

## 📞 Emergency Contacts

### Technical Support
```
Primary Contact:   ___________________________________________
Phone:             ___________________________________________
Email:             ___________________________________________

Backup Contact:    ___________________________________________
Phone:             ___________________________________________
Email:             ___________________________________________
```

### Service Providers
```
Domain Registrar:  ___________________________________________
DNS Provider:      ___________________________________________
Hosting Provider:  ___________________________________________
SSL Provider:      Let's Encrypt (automatic)
```

---

## 🚨 Recovery Information

### Emergency Access
```
SSH Access:    ssh ___________@___________
SSH Key Path:  ___________________________________________
Sudo Password: ___________________________________________
```

### Installation Directory
```
Path: ___________________________________________
```

### Docker Commands
```
# View logs
docker compose -f ___________/docker-compose.yml logs -f

# Restart all
docker compose -f ___________/docker-compose.yml restart

# Stop all
docker compose -f ___________/docker-compose.yml down

# Start all
docker compose -f ___________/docker-compose.yml up -d
```

---

## 📝 Notes & Custom Configurations

### Custom Modifications
```
___________________________________________
___________________________________________
___________________________________________
___________________________________________
```

### Known Issues
```
___________________________________________
___________________________________________
___________________________________________
```

### Future Improvements
```
___________________________________________
___________________________________________
___________________________________________
```

---

## ✅ Installation Checklist

### Pre-Installation
- [ ] DNS records configured
- [ ] Server meets requirements (4GB+ RAM, 2+ CPU)
- [ ] Docker installed
- [ ] Firewall rules configured (ports 80, 443, 8080)

### Post-Installation
- [ ] All services accessible via HTTPS
- [ ] SSL certificates generated
- [ ] n8n owner account created
- [ ] Supabase dashboard accessible
- [ ] MinIO console accessible
- [ ] Ollama models pulled (if installed)
- [ ] Grafana configured (if installed)
- [ ] Uptime Kuma monitors configured (if installed)
- [ ] Portainer admin account created (if installed)
- [ ] First backup completed
- [ ] Credentials stored securely
- [ ] Team members notified

---

## 🔒 Security Checklist

- [ ] Changed all default passwords
- [ ] Enabled 2FA where available
- [ ] Restricted Traefik dashboard access (port 8080)
- [ ] Configured firewall (UFW/iptables)
- [ ] Set up automated backups
- [ ] Tested backup restoration
- [ ] Reviewed service logs for anomalies
- [ ] Configured SSL certificate renewal alerts
- [ ] Documented all custom configurations
- [ ] Stored credentials in password manager

---

**Date Completed:** ___________________  
**Completed By:** ___________________  
**Verified By:** ___________________

---

## 📚 Quick Reference Commands

```bash
# Navigate to installation
cd ___________________________________________

# Check status
docker compose ps

# View logs
docker compose logs -f

# Restart service
docker compose restart SERVICE_NAME

# Update all
docker compose pull && docker compose up -d

# Backup
tar czf backup-$(date +%Y%m%d).tar.gz .

# Emergency stop
docker compose down
```

---

**Keep this document secure and up-to-date!**

**Last Updated:** ___________________
