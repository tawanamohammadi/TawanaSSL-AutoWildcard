#!/usr/bin/env bash
set -euo pipefail

# ========================
#   Helper Functions
# ========================

red()   { echo -e "\e[31m$*\e[0m"; }
green() { echo -e "\e[32m$*\e[0m"; }
yellow(){ echo -e "\e[33m$*\e[0m"; }
blue()  { echo -e "\e[34m$*\e[0m"; }

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    red "ERROR: This script must be run as root."
    exit 1
  fi
}

press_enter() {
  read -rp "Press Enter to continue..."
}

# ========================
#      Script Start
# ========================

require_root

clear
echo
blue  "==================================================="
blue  "           TawanaSSL Auto Wildcard Tool"
blue  "==================================================="
echo  " Automated wildcard SSL for Marzban / Marzneshin / Custom"
echo  " Using: acme.sh  +  Cloudflare DNS  +  Let's Encrypt"
echo  " Repo : https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard"
echo
echo

# ---- Step 1: Get Cloudflare credentials ----
echo "[Step 1/6] Cloudflare credentials"
read -rp "Enter your Cloudflare Email: " CF_Email
if [[ -z "$CF_Email" ]]; then
  red "ERROR: Cloudflare Email cannot be empty."
  exit 1
fi

read -rsp "Enter your Cloudflare Global API Key: " CF_Key
echo
if [[ -z "$CF_Key" ]]; then
  red "ERROR: Cloudflare Global API Key cannot be empty."
  exit 1
fi
echo

# ---- Step 2: Get domain ----
echo "[Step 2/6] Domain configuration"
read -rp "Enter your main domain (example: panbehpanel.ir): " DOMAIN

if [[ -z "$DOMAIN" ]]; then
  red "ERROR: Domain cannot be empty."
  exit 1
fi

# Very basic validation
if [[ ! "$DOMAIN" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
  yellow "WARNING: Domain format looks unusual. Make sure it is correct."
fi

echo
yellow "Important:"
echo "  - The domain MUST exist in your Cloudflare account."
echo "  - The domain's nameservers MUST point to Cloudflare."
echo
press_enter

# ---- Step 3: Choose certificate path & reload behavior ----
echo
echo "[Step 3/6] Certificate install path & service reload"
echo "Select certificate installation path:"
echo "  1) Marzban      (/var/lib/marzban/certs)"
echo "  2) Marzneshin   (/var/lib/marzneshin/certs)"
echo "  3) Custom Path"
echo

read -rp "Choose (1/2/3): " PATH_CHOICE
echo

RELOAD_CMD="systemctl reload nginx || true"

case "$PATH_CHOICE" in
  1)
    TARGET_DIR="/var/lib/marzban/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart marzban || systemctl restart marzban.service || true)"
    ;;
  2)
    TARGET_DIR="/var/lib/marzneshin/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart marzneshin || systemctl restart marzneshin.service || true)"
    ;;
  3)
    read -rp "Enter full certificate directory path (e.g. /etc/nginx/ssl): " TARGET_DIR
    ;;
  *)
    red "ERROR: Invalid choice."
    exit 1
    ;;
esac

if [[ -z "$TARGET_DIR" ]]; then
  red "ERROR: Target directory cannot be empty."
  exit 1
fi

yellow "Selected certificate directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo
yellow "Service reload command will be:"
echo "  $RELOAD_CMD"
echo
press_enter

# ========================
#   Step 4: Install acme.sh
# ========================

echo
echo "[Step 4/6] Checking acme.sh installation"

ACME_SH="/root/.acme.sh/acme.sh"

if [[ ! -x "$ACME_SH" ]]; then
  yellow "acme.sh not found. Installing..."
  curl https://get.acme.sh | sh
  ACME_SH="/root/.acme.sh/acme.sh"
  if [[ ! -x "$ACME_SH" ]]; then
    red "ERROR: acme.sh installation failed."
    exit 1
  fi
  green "acme.sh installed successfully."
else
  green "acme.sh is already installed."
fi

# Set Let's Encrypt as default CA
yellow "Setting Let's Encrypt as default CA..."
"$ACME_SH" --set-default-ca --server letsencrypt
green "Default CA set to Let's Encrypt."
echo

# Set Cloudflare env vars
export CF_Email
export CF_Key

# ========================
#   Step 5: Issue wildcard cert
# ========================

echo "[Step 5/6] Requesting wildcard SSL certificate"
yellow "Requesting wildcard SSL for:"
echo "  - $DOMAIN"
echo "  - *.$DOMAIN"
echo

if ! "$ACME_SH" --issue \
  --dns dns_cf \
  -d "$DOMAIN" \
  -d "*.$DOMAIN" \
  --keylength ec-256; then

  red "ERROR: Failed to issue wildcard certificate."
  echo
  yellow "Common reasons:"
  echo "  - The domain is NOT in your Cloudflare account."
  echo "  - The nameservers are NOT pointing to Cloudflare."
  echo "  - Cloudflare Email or Global API Key is incorrect."
  echo
  yellow "You can re-run the script after fixing the configuration."
  exit 1
fi

green "Wildcard certificate successfully issued."
echo

# ========================
#   Step 6: Install cert
# ========================

echo "[Step 6/6] Installing certificate to target directory"

TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")

# Backup old certs if they exist
if [[ -f "$TARGET_DIR/fullchain.pem" ]]; then
  cp "$TARGET_DIR/fullchain.pem" "$TARGET_DIR/fullchain.pem.bak-$TIMESTAMP"
  yellow "Backup created: $TARGET_DIR/fullchain.pem.bak-$TIMESTAMP"
fi

if [[ -f "$TARGET_DIR/key.pem" ]]; then
  cp "$TARGET_DIR/key.pem" "$TARGET_DIR/key.pem.bak-$TIMESTAMP"
  yellow "Backup created: $TARGET_DIR/key.pem.bak-$TIMESTAMP"
fi

yellow "Installing new certificate and key..."
if ! "$ACME_SH" --install-cert -d "$DOMAIN" --ecc \
  --key-file "$TARGET_DIR/key.pem" \
  --fullchain-file "$TARGET_DIR/fullchain.pem" \
  --reloadcmd "$RELOAD_CMD"; then

  red "ERROR: Failed to install certificate."
  echo "Check that the target directory exists and is writable:"
  echo "  $TARGET_DIR"
  exit 1
fi

green "Certificate installed and services reload command executed."
echo

# ========================
#   Final Summary
# ========================

clear
echo
blue  "==================================================="
blue  "         TawanaSSL Wildcard Setup Summary"
blue  "==================================================="
echo
green " Status:           SUCCESS ✅"
echo
echo  " Domain:           $DOMAIN"
echo  " Wildcard:         *.$DOMAIN"
echo  " Certificate path: $TARGET_DIR"
echo  " Files used:       fullchain.pem (certificate)"
echo  "                   key.pem       (private key)"
echo
echo  " Services reload command executed:"
echo  "   $RELOAD_CMD"
echo
echo  " Useful test commands:"
echo
echo  "   # Check certificate from this server"
echo  "   echo | openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} 2>/dev/null | openssl x509 -noout -dates -issuer -subject"
echo
echo  "   # Example Marzban subdomain (edit if needed):"
echo  "   echo | openssl s_client -connect panel.${DOMAIN}:443 -servername panel.${DOMAIN} 2>/dev/null | openssl x509 -noout -dates -issuer -subject"
echo
echo  " acme.sh auto-renew cron is installed by default."
echo  " Certificates will be renewed automatically, and this"
echo  " script ensures they are copied to the correct path and"
echo  " selected services are reloaded."
echo
green "Done. Have a secure day. 🔐"
echo
