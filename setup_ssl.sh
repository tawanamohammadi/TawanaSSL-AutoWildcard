# ========================
#   Constants & Config
# ========================
REPO_URL="https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard"
SCRIPT_PATH="/usr/local/bin/tawanassl"
RAW_SCRIPT_URL="https://raw.githubusercontent.com/tawanamohammadi/TawanaSSL-AutoWildcard/main/setup_ssl.sh"

# ========================
#   Helper Functions
# ========================

red()   { echo -e "\e[31m$*\e[0m"; }
green() { echo -e "\e[32m$*\e[0m"; }
yellow(){ echo -e "\e[33m$*\e[0m"; }
blue()  { echo -e "\e[34m$*\e[0m"; }
cyan()  { echo -e "\e[36m$*\e[0m"; }
bold()  { echo -e "\e[1m$*\e[0m"; }

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    red "ERROR: This script must be run as root."
    exit 1
  fi
}

press_enter() {
  echo
  read -rp "Press Enter to return to menu..."
}

update_panel_env() {
  local env_path=$1
  local cert_path=$2
  local key_path=$3
  if [[ -f "$env_path" ]]; then
    yellow "Updating configuration at $env_path..."
    # Update or add UVICORN_SSL_CERTFILE
    if grep -q "UVICORN_SSL_CERTFILE" "$env_path"; then
      sed -i "s|^#*\s*UVICORN_SSL_CERTFILE.*|UVICORN_SSL_CERTFILE = \"$cert_path\"|" "$env_path"
    else
      echo "UVICORN_SSL_CERTFILE = \"$cert_path\"" >> "$env_path"
    fi
    # Update or add UVICORN_SSL_KEYFILE
    if grep -q "UVICORN_SSL_KEYFILE" "$env_path"; then
      sed -i "s|^#*\s*UVICORN_SSL_KEYFILE.*|UVICORN_SSL_KEYFILE = \"$key_path\"|" "$env_path"
    else
      echo "UVICORN_SSL_KEYFILE = \"$key_path\"" >> "$env_path"
    fi
    green "Environment file $env_path updated."
  fi
}

show_banner() {
  clear
  echo -e "\e[1;36m"
  echo "  ████████╗ █████╗ ██╗    ██╗ █████╗ ███╗   ██╗ █████╗     ███████╗███████╗██╗"
  echo "  ╚══██╔══╝██╔══██╗██║    ██║██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔════╝██║"
  echo "     ██║   ███████║██║ █╗ ██║███████║██╔██╗ ██║███████║    ███████╗███████╗██║"
  echo "     ██║   ██╔══██║██║███╗██║██╔══██║██║╚██╗██║██╔══██║    ╚════██║╚════██║██║"
  echo "     ██║   ██║  ██║╚███╔███╔╝██║  ██║██║ ╚████║██║  ██║    ███████║███████║███████╗"
  echo "     ╚═╝   ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚══════╝╚══════╝╚══════╝"
  echo -e "\e[0m"
  bold "  =============================================================================="
  bold "                   TawanaSSL Auto Wildcard Suite (TAW) "
  bold "  =============================================================================="
  echo
}

install_global() {
  show_banner
  yellow "Installing TawanaSSL as a global command..."
  cp "$0" "$SCRIPT_PATH"
  chmod +x "$SCRIPT_PATH"
  green "Success! You can now run the script anytime by typing: tawanassl"
  echo
}

update_script() {
  show_banner
  yellow "Checking for updates..."
  if curl -sL "$RAW_SCRIPT_URL" -o "$SCRIPT_PATH.tmp"; then
    mv "$SCRIPT_PATH.tmp" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    green "TawanaSSL has been updated to the latest version!"
  else
    red "Failed to update. Please check your internet connection."
  fi
  press_enter
}

check_ssl_status() {
  show_banner
  yellow "SSL Certificate Status Monitor"
  echo "------------------------------------------------"
  
  local paths=(
    "/var/lib/marzban/certs"
    "/var/lib/marzneshin/certs"
    "/var/lib/pasarguard/certs"
    "/etc/x-ui/certs"
  )

  for p in "${paths[@]}"; do
    if [[ -f "$p/fullchain.pem" ]]; then
      cyan "Checking: $p"
      openssl x509 -in "$p/fullchain.pem" -noout -dates -subject || red "Error reading certificate."
      echo "------------------------------------------------"
    fi
  done
  press_enter
}

# ========================
#   Core SSL Logic
# ========================

issue_ssl() {
  show_banner
  bold "  Automated Wildcard SSL for Marzban / Marzneshin / Pasargad / X-UI"
  cyan "  Repo : $REPO_URL"
  echo

  # ---- Step 1: Get Cloudflare credentials ----
  yellow "[Step 1/6] Cloudflare credentials"
  read -rp "Enter your Cloudflare Email: " CF_Email
  if [[ -z "$CF_Email" ]]; then
    red "ERROR: Cloudflare Email cannot be empty."
    return 1
  fi

  read -rsp "Enter your Cloudflare Global API Key: " CF_Key
  echo
  if [[ -z "$CF_Key" ]]; then
    red "ERROR: Cloudflare Global API Key cannot be empty."
    return 1
  fi
  echo

# ---- Step 1: Get Cloudflare credentials ----
yellow "[Step 1/6] Cloudflare credentials"
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

# ---- Step 1: Get Cloudflare credentials ----
msg "[Step 1/6] Cloudflare credentials" "[مرحله ۱/۶] اطلاعات کلودفلر" "\e[33m"
read -rp "$(msg "Enter your Cloudflare Email: " "ایمیل کلودفلر خود را وارد کنید: ") " CF_Email
if [[ -z "$CF_Email" ]]; then
  msg "ERROR: Cloudflare Email cannot be empty." "خطا: ایمیل کلودفلر نمی‌تواند خالی باشد." "\e[31m"
  exit 1
fi

read -rsp "$(msg "Enter your Cloudflare Global API Key: " "کلید API کلودفلر را وارد کنید: ") " CF_Key
echo
if [[ -z "$CF_Key" ]]; then
  msg "ERROR: Cloudflare Global API Key cannot be empty." "خطا: کلید API کلودفلر نمی‌تواند خالی باشد." "\e[31m"
  exit 1
fi
echo

# ---- Step 2: Get domain ----
yellow "[Step 2/6] Domain configuration"
read -rp "Enter your main domain (example: panbehpanel.ir): " DOMAIN

if [[ -z "$DOMAIN" ]]; then
  red "ERROR: Domain cannot be empty."
  exit 1
fi

echo
bold "Important:"
echo "  - The domain MUST exist in your Cloudflare account."
echo "  - The domain's nameservers MUST point to Cloudflare."
echo "  - Ensure you have an A record pointing your domain to this server."
cyan "  - Magic: This issues a Wildcard SSL (*.domain) for ALL subdomains!"
echo
press_enter

# ---- Step 3: Choose certificate path & reload behavior ----
echo
yellow "[Step 3/6] Certificate install path & service reload"
echo "Select certificate installation path:"
echo "  1) Marzban      (/var/lib/marzban/certs)"
echo "  2) Marzneshin   (/var/lib/marzneshin/certs)"
echo "  3) Pasargad     (/var/lib/pasarguard/certs)"
echo "  4) 3X-UI / X-UI (/etc/x-ui/certs)"
echo "  5) Custom Path"
echo

read -rp "Choose (1/2/3/4/5): " PATH_CHOICE
echo

RELOAD_CMD="systemctl reload nginx || true"

case "$PATH_CHOICE" in
  1)
    TARGET_DIR="/var/lib/marzban/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart marzban || systemctl restart marzban.service || true)"
    ENV_FILE="/opt/marzban/.env"
    ;;
  2)
    TARGET_DIR="/var/lib/marzneshin/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart marzneshin || systemctl restart marzneshin.service || true)"
    ENV_FILE=""
    ;;
  3)
    TARGET_DIR="/var/lib/pasarguard/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart pasarguard || systemctl restart pasarguard.service || true)"
    ENV_FILE="/opt/pasarguard/.env"
    ;;
  4)
    TARGET_DIR="/etc/x-ui/certs"
    RELOAD_CMD="$RELOAD_CMD; (x-ui restart || systemctl restart x-ui || true)"
    ENV_FILE=""
    ;;
  5)
    read -rp "Enter full certificate directory path: " TARGET_DIR
    ENV_FILE=""
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

if [[ -n "$ENV_FILE" ]]; then
  update_panel_env "$ENV_FILE" "$TARGET_DIR/fullchain.pem" "$TARGET_DIR/key.pem"
fi

echo
yellow "Service reload command will be:"
echo "  $RELOAD_CMD"
echo
press_enter

# ========================
#   Step 4: Install acme.sh
# ========================

echo
yellow "[Step 4/6] Checking acme.sh installation"

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

yellow "[Step 5/6] Requesting wildcard SSL certificate"
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
  exit 1
fi

green "Wildcard certificate successfully issued."
echo

# ========================
#   Step 6: Install cert
# ========================

yellow "[Step 6/6] Installing certificate to target directory"

TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")

# Backup old certs if they exist
if [[ -f "$TARGET_DIR/fullchain.pem" ]]; then
  cp "$TARGET_DIR/fullchain.pem" "$TARGET_DIR/fullchain.pem.bak-$TIMESTAMP"
fi

if [[ -f "$TARGET_DIR/key.pem" ]]; then
  cp "$TARGET_DIR/key.pem" "$TARGET_DIR/key.pem.bak-$TIMESTAMP"
fi

yellow "Installing new certificate and key..."
if ! "$ACME_SH" --install-cert -d "$DOMAIN" --ecc \
  --key-file "$TARGET_DIR/key.pem" \
  --fullchain-file "$TARGET_DIR/fullchain.pem" \
  --reloadcmd "$RELOAD_CMD"; then

  red "ERROR: Failed to install certificate."
  exit 1
fi

  green "Certificate installed and services reload command executed."
  echo
  
  # Final Summary
  show_banner
  green "                   TawanaSSL Setup Completed! ✅"
  bold "  =============================================================================="
  echo
  green " Status:           SUCCESS ✅"
  echo
  echo " Domain:           $DOMAIN"
  echo " Wildcard:         *.$DOMAIN"
  echo " Certificate path: $TARGET_DIR"
  echo
  if [[ -n "$ENV_FILE" ]]; then
    yellow " Configuration:    Updated $ENV_FILE"
  fi
  echo
  yellow " Useful test command:"
  echo "   echo | openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} 2>/dev/null | openssl x509 -noout -dates"
  echo
  green " acme.sh auto-renew is active. Enjoy your secure server!"
  echo
  press_enter
}

# ========================
#   Main Application
# ========================

main_menu() {
  while true; do
    show_banner
    echo "  What would you like to do?"
    echo "  1) Issue Wildcard SSL (New Setup)"
    echo "  2) Check SSL Status"
    echo "  3) Update TawanaSSL Script"
    echo "  4) Uninstall / Remove Global Command"
    echo "  0) Exit"
    echo
    read -rp "  Select an option [0-4]: " choice

    case $choice in
      1) issue_ssl ;;
      2) check_ssl_status ;;
      3) update_script ;;
      4) 
        rm -i "$SCRIPT_PATH" && green "Global command removed." || red "Removal canceled."
        exit 0
        ;;
      0) exit 0 ;;
      *) red "Invalid option." ; sleep 1 ;;
    esac
  done
}

# Auto-install or Main execution
require_root
if [[ "${1:-}" == "@" && "${2:-}" == "--install" ]]; then
  install_global
else
  # If not installed globally, offer to install it
  if [[ ! -f "$SCRIPT_PATH" ]]; then
    install_global
  fi
  main_menu
fi
```
