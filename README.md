# TawanaSSL-AutoWildcard

**A fully automated wildcard SSL installer for Marzban, Marzneshin, and custom server environments — built using acme.sh and Cloudflare DNS API.**

🔗 Repository: <https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard>  
🌐 Author website: <https://tawana.online>

---

## 🚀 What Is This?

**TawanaSSL-AutoWildcard** is a simple but powerful Bash script that automates:

- Issuing **Let’s Encrypt wildcard SSL certificates**
- Using **Cloudflare DNS validation** (Email + Global API Key)
- Installing SSL certificates for:
  - **Marzban** → `/var/lib/marzban/certs`
  - **Marzneshin** → `/var/lib/marzneshin/certs`
  - **Custom paths** (e.g. `/etc/nginx/ssl`)
- Backing up old certificates
- Reloading / restarting:
  - `nginx`
  - `marzban` / `marzneshin` (if present)
- Enabling **automatic renewal** via `acme.sh` cron

The script is designed to be:

- **Interactive**
- **Human-readable**
- **Safe** (creates backups)
- **Production-ready**

---

## ✨ Features

- ✅ Fully automated wildcard SSL for `domain` and `*.domain`
- ✅ Cloudflare DNS-based validation (no HTTP challenges needed)
- ✅ Auto-installation of `acme.sh` if not already installed
- ✅ Built-in backup of existing `key.pem` and `fullchain.pem`
- ✅ Nginx reload + Marzban/Marzneshin restart support
- ✅ Clean, colored terminal output with clear step-by-step flow
- ✅ Works on most modern Linux distributions (Ubuntu/Debian recommended)

---

## 🧩 Requirements

- Linux server with **root** access
- Domain managed in **Cloudflare**
  - Domain must exist in the Cloudflare account
  - Domain **nameservers must point to Cloudflare**
- Cloudflare:
  - **Account Email**
  - **Global API Key**
- `curl` installed (usually pre-installed on most systems)
- Optional but recommended: `nginx` and Marzban/Marzneshin for full integration

---

## 📥 Installation

Clone this repository:

```bash
git clone https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard.git
cd TawanaSSL-AutoWildcard
