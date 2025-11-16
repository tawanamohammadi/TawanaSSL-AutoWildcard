# TawanaSSL-AutoWildcard

**Automated Wildcard SSL Installer for Marzban, Marzneshin & Custom Linux Servers (Cloudflare + acme.sh + Let’s Encrypt)**

🔗 **Repository:** [https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard](https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard)
🌐 **Author Website:** [https://tawana.online](https://tawana.online)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell Script](https://img.shields.io/badge/language-Bash-blue)
![Cloudflare](https://img.shields.io/badge/DNS-Cloudflare-orange)

TawanaSSL-AutoWildcard is a simple, interactive Bash script that automates issuing and installing **Let’s Encrypt wildcard SSL certificates** using **Cloudflare DNS**, designed especially for **Marzban**, **Marzneshin**, and any **custom HTTPS server setup**.

It handles everything for you:

* Installs **acme.sh** (if missing)
* Issues wildcard SSL for `domain` and `*.domain`
* Uses **Cloudflare DNS-01 challenge** (no HTTP challenge needed)
* Installs certs into Marzban / Marzneshin / custom paths
* Backs up old certificates safely
* Reloads Nginx and restarts Marzban / Marzneshin
* Works with **auto-renewal** via acme.sh cron

---

## 🚀 Features

* ✅ **Wildcard SSL Support**

  * Automatically issues certificates for:

    * `yourdomain.com`
    * `*.yourdomain.com`

* ✅ **Cloudflare DNS Integration**

  * Uses Cloudflare DNS API with:

    * Cloudflare **Account Email**
    * Cloudflare **Global API Key**

* ✅ **Auto Install & Auto Renew**

  * Installs **acme.sh** automatically (if not found)
  * Uses Let’s Encrypt as default CA
  * Ensures certificates are renewed and reinstalled automatically

* ✅ **Marzban & Marzneshin Friendly**

  * Built-in support for:

    * `/var/lib/marzban/certs`
    * `/var/lib/marzneshin/certs`
  * Option for **custom certificate paths** (e.g. `/etc/nginx/ssl`)

* ✅ **Service Reload & Restart**

  * Reloads **Nginx**
  * Tries to restart:

    * `marzban` / `marzban.service`
    * `marzneshin` / `marzneshin.service`

* ✅ **Backup & Safety**

  * Automatically creates timestamped backups:

    * `fullchain.pem.bak-YYYY-MM-DD-HHMMSS`
    * `key.pem.bak-YYYY-MM-DD-HHMMSS`

* ✅ **Clean, Human-Friendly Output**

  * Colored terminal messages
  * Step-by-step flow (6 clear steps)
  * Summary screen at the end with test commands

---

## 🧩 Use Cases

* Securing **Marzban panel** and proxy infrastructures
* Securing **Marzneshin** deployments
* Deploying **wildcard HTTPS** for multiple subdomains
* Automated SSL for:

  * VPN / proxy servers
  * Reverse proxies (Nginx)
  * Custom web applications

If you’re running a panel or proxy infrastructure and want **zero-pain SSL**, this script is for you.

---

## 📋 Requirements

Before using TawanaSSL-AutoWildcard, make sure you have:

1. **Linux server with root access**

   * Ubuntu 20.04+ / Debian / other systemd-based distros

2. **Domain managed in Cloudflare**

   * The domain **must exist** in your Cloudflare account
   * The domain’s **nameservers must point to Cloudflare**

3. **Cloudflare credentials**

   * Cloudflare **Account Email**
   * Cloudflare **Global API Key**

4. **Basic tools**

   * `curl` (usually installed by default)
   * `systemd` for service management (nginx, marzban, etc.)

> 🔐 Your Cloudflare Global API Key is sensitive. Treat it like a password. The script does **not** save it to disk, only uses it in the current shell.

---

## 📦 Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard.git
cd TawanaSSL-AutoWildcard

chmod +x setup_ssl.sh
```

---

## 🛠 Usage: Step-by-Step

Run the script as **root**:

```bash
sudo ./setup_ssl.sh
```

You’ll be guided through 6 steps:

### 1️⃣ Cloudflare Credentials

* **Cloudflare Email**
* **Cloudflare Global API Key** (input is hidden)

### 2️⃣ Domain Configuration

Enter your primary domain, for example:

```text
tawana.online
```

The script will request wildcard SSL for:

* `tawana.online`
* `*.tawana.online`

### 3️⃣ Certificate Path & Service Mode

You choose where the certificate should be installed:

* `1` → **Marzban** → `/var/lib/marzban/certs`
* `2` → **Marzneshin** → `/var/lib/marzneshin/certs`
* `3` → **Custom path** (you specify directory path)

The script then configures a **reload command** such as:

```bash
systemctl reload nginx || true; (systemctl restart marzban || systemctl restart marzban.service || true)
```

### 4️⃣ acme.sh Installation

* Checks if `acme.sh` exists under `/root/.acme.sh/acme.sh`
* If missing, downloads and installs it
* Sets **Let’s Encrypt** as the default Certificate Authority

### 5️⃣ Wildcard SSL Issuance

The script uses `acme.sh` with **Cloudflare DNS validation**:

```bash
acme.sh --issue \
  --dns dns_cf \
  -d yourdomain.com \
  -d "*.yourdomain.com" \
  --keylength ec-256
```

If anything fails, you’ll see:

* Clear error message
* Common reasons (e.g. domain not in Cloudflare, wrong nameservers, wrong API key)

### 6️⃣ Certificate Installation & Reload

* Backs up any existing `fullchain.pem` and `key.pem` in the target directory
* Installs the new certificate and key:

  * `fullchain.pem` → certificate
  * `key.pem` → private key
* Executes the reload command (e.g. reloads Nginx, restarts Marzban/Marzneshin)

Finally, you get a **summary screen** with:

* Domain and wildcard
* Certificate path
* Reload command used
* Handy `openssl` test commands

---

## 🔍 Verifying Your SSL Certificate

You can verify your SSL certificate directly from the server.

### Check Main Domain

```bash
echo | openssl s_client -connect yourdomain.com:443 -servername yourdomain.com 2>/dev/null | openssl x509 -noout -dates -issuer -subject
```

### Check a Subdomain (e.g. Marzban Panel)

```bash
echo | openssl s_client -connect panel.yourdomain.com:443 -servername panel.yourdomain.com 2>/dev/null | openssl x509 -noout -dates -issuer -subject
```

You should see:

* `issuer` → Let’s Encrypt (E6/E7, etc.)
* `notAfter` → expiry date ~90 days in the future
* `subject` → matching your domain

---

## 🔁 Auto-Renewal & Maintenance

The underlying **acme.sh** client automatically:

* Installs a cron job
* Renews certificates **before** they expire

Because this script uses:

```bash
acme.sh --install-cert ... --reloadcmd "..."
```

On each renewal:

* The new certificate and key are written to your target directory
* The configured reload command is executed (e.g. Nginx reload + Marzban/Marzneshin restart)

You don’t need to manually repeat the setup process unless you:

* Change the domain
* Change the server
* Change the certificate path

---

## 🔐 Security Best Practices

* **Never** hard-code your Cloudflare Global API Key inside the script
* Do **not** commit API keys or secrets to GitHub or any VCS
* Restrict Cloudflare account access and enable 2FA
* Use separate API keys for production vs. testing when possible

The script only uses `CF_Email` and `CF_Key` as **environment variables** in the current shell during execution.

---

## 🧠 SEO Keywords (for search engines)

This project is relevant for:

* `marzban ssl`
* `marzneshin ssl`
* `cloudflare wildcard ssl script`
* `acme.sh cloudflare dns wildcard`
* `letsencrypt wildcard certificate automation`
* `ubuntu marzban https setup`
* `vpn panel ssl automation`

If you searched for any of those, you’re in the right place.

---

## 👤 Author

**Tawana Mohammadi**
Ethical AI, Security & Infrastructure Researcher
🌐 Website: [https://tawana.online](https://tawana.online)
GitHub: [https://github.com/tawanamohammadi](https://github.com/tawanamohammadi)

If you find this tool useful, consider giving the repository a ⭐ on GitHub.

---

## 📜 License

This project is licensed under the **MIT License**.

You are free to:

* Use it commercially
* Modify it
* Distribute it
* Private use

As long as you retain the original copyright and license notice.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome.

You can:

* Open an **Issue** for bugs or feature ideas
* Submit **Pull Requests** for:

  * New DNS providers
  * Additional panels or service integrations
  * Better error handling or UX improvements

---

## 💡 Ideas for Future Extensions

* Support for other DNS providers (e.g. Cloudflare API Tokens, DNSPod, Route53)
* Automatic Nginx config generator for Marzban / Marzneshin
* Systemd service wrapper for full one-command bootstrap
* Web UI wrapper for non-technical users

---

Happy encrypting and stay safe on the Internet. 🔐
