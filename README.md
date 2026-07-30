## Denny Brathwaite — Homelab Infrastructure Portfolio


## About Me

I'm an aspiring Infrastructure and Network Administrator with a passion for designing secure, enterprise-style home lab environments.

This repository documents real-world projects involving:

- Multi-VLAN network design
- Enterprise DNS architecture
- Reverse proxy infrastructure
- Docker container orchestration
- Infrastructure documentation
- Security hardening

Every project reflects production-style engineering practices while protecting sensitive information through sanitization.

This repository documents the design, operation, security, and troubleshooting of an enterprise-style homelab.

## Live site

## Badges

![Cloudflare Pages](https://img.shields.io/badge/Hosted_on-Cloudflare_Cloud-orange)

![Docker](https://img.shields.io/badge/Docker-20+-2496ED)

![TP-Link Omada](https://img.shields.io/badge/Network-TP--Link_Omada-00B8E6)

![Technitium DNS](https://img.shields.io/badge/DNS-Technitium-success)

![AdGuard Home](https://img.shields.io/badge/Filtering-AdGuard_Home-green)

![Vaultwarden](https://img.shields.io/badge/Password_Manager-Vaultwarden-red)

![License-MIT](https://img.shields.io/badge/License-MIT-blue)


Designed for deployment to Cloudflare Pages at:

`portfolio.dbservicessolutions.org`


## Certifications

[![Google Cybersecurity Professional Certificate](https://img.shields.io/badge/Google_Cybersecurity-Professional_Certificate-blue?logo=google)](certificates.html)
![Google Cybersecurity Specialization](https://img.shields.io/badge/Google_Cybersecurity-Specialization-blue?logo=google)
![Network Administration](https://img.shields.io/badge/Network_Administration-Completed-green)
![Computer Maintenance](https://img.shields.io/badge/Computer_Maintenance-Completed-green)

- Google Cybersecurity Professional Certificate (Coursera)
- Google Cybersecurity Specialization
- Network Administration
- Computer Maintenance





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



## Network Architecture 


[![Network architecture diagram](https://raw.githubusercontent.com/MadHub2024/MadHub2024-homelab-infrastructure-portfolio/50d80195d688ace9631cabb2e94a142fd0d29aff/assets/images/0C2274B9-713F-41C5-B935-696DF4746B12.PNG)](https://github.com/MadHub2024/MadHub2024-homelab-infrastructure-portfolio/blob/50d80195d688ace9631cabb2e94a142fd0d29aff/assets/images/0C2274B9-713F-41C5-B935-696DF4746B12.PNG)




## DNS Flow


Clients

↓

Technitium DNS

↓

AdGuard Home

↓

AdGuard Private DNS

↓

Internet


## Reverse Proxy


Internet

↓

Cloudflare

↓

Caddy

↓

Portainer

Homepage

Vaultwarden

Uptime Kuma

Home Assistant

LibreNMS


## Dell Hybrid Architecture 


    Dell OptiPlex 7060
    ├── Native Services
    │   ├── Technitium DNS
    │   ├── Docker Engine
    │   ├── containerd
    │   ├── OpenPostings API
    │   ├── OpenPostings Web
    │   ├── Tailscale
    │   ├── SNMP
    │   ├── SSH
    │   ├── nftables
    │   ├── lm-sensors
    │   └── smartmontools
    └── Docker Services
        ├── Vaultwarden
        ├── LibreNMS
        │   ├── LibreNMS application
        │   ├── Dispatcher
        │   ├── Redis
        │   └── MariaDB
        ├── Home Assistant
        ├── Portainer
        ├── ESPHome
        ├── Matter Server
        ├── cAdvisor
        └── Node Exporter


## Lenovo Hybrid Architecture 


    Lenovo ThinkCentre M73
    ├── Native Services
    │   ├── AdGuard Home
    │   ├── Caddy
    │   ├── Cloudflared
    │   ├── Docker Engine
    │   ├── containerd
    │   ├── Homebridge
    │   ├── Grafana
    │   ├── Prometheus
    │   ├── Prometheus Blackbox Exporter
    │   ├── Prometheus Node Exporter
    │   ├── AdGuard Exporter
    │   ├── Technitium Exporter
    │   ├── Glances
    │   ├── Ollama
    │   ├── n8n
    │   ├── PM2 Process Manager
    │   ├── MTA-STS
    │   ├── Tailscale
    │   ├── SNMP
    │   ├── SSH
    │   ├── UFW
    │   ├── Chrony
    │   ├── smartmonttools
    │   ├── lm-sensors
    │   └── zram Swap
    └── Docker Services
        ├── Homepage
        ├── Open WebUI
        ├── Portainer
        ├── Uptime Kuma
        ├── WatchYourLAN
        ├── Glances
        └── cAdvisor


## Security

All examples are sanitized. Never publish passwords, API keys, private keys, tokens, session cookies, public IP allocations, or production secrets.

This repository has been sanitized for public release.

The following information has been intentionally removed or replaced:

- Public IP addresses
- Internal network addresses
- Authentication credentials
- API tokens
- TLS certificates
- Private keys
- Vaultwarden secrets
- Cloudflare credentials
- Tailscale authentication keys

The architecture, configuration methodology, and deployment processes remain technically accurate while protecting production infrastructure.
