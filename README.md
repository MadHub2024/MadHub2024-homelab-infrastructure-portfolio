# Denny Brathwaite — Homelab Infrastructure Portfolio

This repository documents the design, operation, security, and troubleshooting of an enterprise-style homelab.

## Live site

Designed for deployment to Cloudflare Pages at:

`portfolio.dbservicessolutions.org`

## Portfolio highlights

- Multi-VLAN TP-Link Omada network with least-privilege ACLs
- Layered DNS using Technitium DNS and AdGuard Home
- Docker Compose services with persistent data and health checks
- Caddy reverse proxy with internal PKI and HTTPS
- Monitoring with LibreNMS, Prometheus, Grafana, exporters, and Uptime Kuma
- Secure remote administration using SSH and Tailscale
- Bash automation for backup, validation, recovery, and readiness testing

## Repository structure

```text
.
├── index.html
├── styles.css
├── script.js
├── projects/
├── docs/
├── configs/
├── resume/
└── DEPLOYMENT.md
```

## Local preview

From the repository directory:

```bash
python3 -m http.server 8080
```

Open `http://127.0.0.1:8080`.

## Security

All examples are sanitized. Never publish passwords, API keys, private keys, tokens, session cookies, public IP allocations, or production secrets.
