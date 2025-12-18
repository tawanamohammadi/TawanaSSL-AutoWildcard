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
  echo "    ████████╗ █████╗ ██╗    ██╗ █████╗ ███╗   ██╗ █████╗ "
  echo "    ╚══██╔══╝██╔══██╗██║    ██║██╔══██╗████╗  ██║██╔══██╗"
  echo "       ██║   ███████║██║ █╗ ██║███████║██╔██╗ ██║███████║"
  echo "       ██║   ██╔══██║██║███╗██║██╔══██║██║╚██╗██║██╔══██║"
  echo "       ██║   ██║  ██║╚███╔███╔╝██║  ██║██║ ╚████║██║  ██║"
  echo "       ╚═╝   ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝"
  echo -e "\e[1;34m"
  echo "          S S L   A U T O M A T I O N   S U I T E "
  echo -e "\e[0m"
  bold "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  bold "             TawanaSSL Elite v2.0 | Advanced Edition "
  bold "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
}

install_global() {
  show_banner
  yellow "  [⚡] Preliminary setup: Registering global command..."
  cp "$0" "$SCRIPT_PATH"
  chmod +x "$SCRIPT_PATH"
  sleep 1
  green "  [✨] Success! Launch the suite anytime by typing: tawanassl"
  echo
}

update_script() {
  show_banner
  yellow "  [🔄] Checking for the latest Elite updates..."
  if curl -sL "$RAW_SCRIPT_URL" -o "$SCRIPT_PATH.tmp"; then
    mv "$SCRIPT_PATH.tmp" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    green "  [🏆] TawanaSSL has been upgraded to the latest version!"
  else
    red "  [❌] Update failed. Check your network or repository status."
  fi
  press_enter
}

check_ssl_status() {
  show_banner
  cyan "  [🔍] SCANNING SYSTEM FOR ACTIVE CERTIFICATES..."
  echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  
  local paths=(
    "/var/lib/marzban/certs"
    "/var/lib/marzneshin/certs"
    "/var/lib/pasarguard/certs"
    "/etc/x-ui/certs"
  )

  local found=0
  for p in "${paths[@]}"; do
    if [[ -f "$p/fullchain.pem" ]]; then
      found=1
      local subject=$(openssl x509 -in "$p/fullchain.pem" -noout -subject | sed 's/.*CN = //; s/\/.*//')
      local expiry_date=$(openssl x509 -in "$p/fullchain.pem" -noout -enddate | cut -d= -f2)
      
      # Cross-platform date parsing
      local expiry_seconds=$(date -d "$expiry_date" +%s 2>/dev/null || date -jf "%b %d %T %Y %Z" "$expiry_date" +%s 2>/dev/null)
      local now_seconds=$(date +%s)
      local diff_seconds=$((expiry_seconds - now_seconds))
      local diff_days=$((diff_seconds / 86400))

      # Color coding based on health
      local status_color="\e[32m" # Green
      local status_text="HEALTHY"
      if [ $diff_days -lt 7 ]; then
        status_color="\e[31m" # Red
        status_text="CRITICAL"
      elif [ $diff_days -lt 30 ]; then
        status_color="\e[33m" # Yellow
        status_text="EXPIRING SOON"
      fi

      echo -e "  \e[1;36mDIRECTORY:\e[0m  $p"
      echo -e "  \e[1;36mDOMAIN:   \e[0m  $subject"
      echo -e "  \e[1;36mEXPIRES:  \e[0m  $expiry_date"
      echo -e "  \e[1;36mSTATUS:   \e[0m  ${status_color}${status_text} (${diff_days} Days Remaining)\e[0m"
      echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo
    fi
  done

  if [ $found -eq 0 ]; then
    yellow "  [!] No certificates found in standard panel paths."
  fi
  
  press_enter
}

# ========================
#   DNS Automation Logic
# ========================

get_zone_id() {
  local domain=$1
  local email=$2
  local key=$3
  # Extract apex domain (example.com from sub.example.com)
  local apex_domain=$(echo "$domain" | grep -oP '(?<=\.)[^.]+\.[^.]+$' || echo "$domain")
  
  local zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$apex_domain" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $key" \
    -H "Content-Type: application/json" | grep -oP '(?<="id":")[^"]+' | head -n1)
  
  echo "$zone_id"
}

check_or_create_dns() {
  local domain=$1
  local email=$2
  local key=$3
  
  show_banner
  yellow "  [🛰️] DNS AUTOMATION: Verifying record for $domain..."
  
  local zone_id=$(get_zone_id "$domain" "$email" "$key")
  
  if [[ -z "$zone_id" ]]; then
    red "  [❌] Failed to fetch Cloudflare Zone ID. Please ensure domain is in your account."
    return 1
  fi

  # Check if A record exists
  local record_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$domain" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $key" | grep -oP '(?<="content":")[^"]+' | head -n1)

  local server_ip=$(curl -s https://ipinfo.io/ip)

  if [[ "$record_ip" == "$server_ip" ]]; then
    green "  [✅] DNS record already correctly points to this server IP ($server_ip)."
  else
    if [[ -z "$record_ip" ]]; then
      yellow "  [!] No A record found for $domain."
    else
      yellow "  [!] Existing record points to $record_ip (Current server is $server_ip)."
    fi
    
    read -rp "  [?] Create/Update A record to point to this server? (y/n): " dns_confirm
    if [[ "$dns_confirm" =~ ^[Yy]$ ]]; then
      if [[ -z "$record_ip" ]]; then
        # Create new
        curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
          -H "X-Auth-Email: $email" \
          -H "X-Auth-Key: $key" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"$domain\",\"content\":\"$server_ip\",\"ttl\":1,\"proxied\":false}" > /dev/null
        green "  [🚀] DNS A-record created successfully!"
      else
        # Update existing
        local record_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$domain" \
          -H "X-Auth-Email: $email" \
          -H "X-Auth-Key: $key" | grep -oP '(?<="id":")[^"]+' | head -n1)
          
        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
          -H "X-Auth-Email: $email" \
          -H "X-Auth-Key: $key" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"$domain\",\"content\":\"$server_ip\",\"ttl\":1,\"proxied\":false}" > /dev/null
        green "  [🚀] DNS A-record updated to $server_ip!"
      fi
    fi
  fi
  sleep 2
}

# ========================
#   Core SSL Logic
# ========================

issue_ssl() {
  show_banner
  bold "  Automated Wildcard SSL Professional Suite"
  cyan "  Repo : $REPO_URL"
  echo

  # ---- Step 1: Get Cloudflare credentials ----
  yellow "[Step 1/6] Cloudflare credentials"
  read -rp "  Enter your Cloudflare Email: " CF_Email
  if [[ -z "$CF_Email" ]]; then
    red "  ERROR: Cloudflare Email cannot be empty."
    return 1
  fi

  read -rsp "  Enter your Cloudflare Global API Key: " CF_Key
  echo
  if [[ -z "$CF_Key" ]]; then
    red "  ERROR: Cloudflare Global API Key cannot be empty."
    return 1
  fi
  echo

# ---- Step 2: Get domain & DNS Sync ----
yellow "[Step 2/6] Domain configuration"
read -rp "  Enter your domain (example.com): " DOMAIN

if [[ -z "$DOMAIN" ]]; then
  red "  ERROR: Domain cannot be empty."
  return 1
fi

# DNS Automation Trigger
check_or_create_dns "$DOMAIN" "$CF_Email" "$CF_Key"

show_banner
yellow "[Step 2/6] Domain confirmed: $DOMAIN"
echo
bold "  Important Visibility Note:"
echo "  - This issues a Wildcard SSL (*.domain) for ALL subdomains."
cyan "  - One certificate secures panel.domain, node1.domain, etc."
echo
press_enter

# ---- Step 3: Choose certificate path ----
echo
yellow "[Step 3/6] Software Panel & Path selection"
echo "  [Regional Favorites]"
echo "    1) Marzban      (/var/lib/marzban/certs)"
echo "    2) Marzneshin   (/var/lib/marzneshin/certs)"
echo "    3) Pasargad     (/var/lib/pasarguard/certs)"
echo "  [Global Favorites]"
echo "    4) 3X-UI / X-UI (/etc/x-ui/certs)"
echo "    5) Hiddify      (/opt/hiddify-manager/certs)"
echo "    6) Amnezia VPN  (/opt/amnezia/certs)"
echo "  [Universal]"
echo "    7) Custom Path"
echo

read -rp "  [⚡] Selection >> " PATH_CHOICE
echo

RELOAD_CMD="systemctl reload nginx || true"

  case "$PATH_CHOICE" in
  1)
    TARGET_DIR="/var/lib/marzban/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart marzban || true)"
    ENV_FILE="/opt/marzban/.env"
    ;;
  2)
    TARGET_DIR="/var/lib/marzneshin/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart marzneshin || true)"
    ENV_FILE=""
    ;;
  3)
    TARGET_DIR="/var/lib/pasarguard/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart pasarguard || true)"
    ENV_FILE="/opt/pasarguard/.env"
    ;;
  4)
    TARGET_DIR="/etc/x-ui/certs"
    RELOAD_CMD="$RELOAD_CMD; (x-ui restart || systemctl restart x-ui || true)"
    ENV_FILE=""
    ;;
  5)
    TARGET_DIR="/opt/hiddify-manager/certs"
    RELOAD_CMD="$RELOAD_CMD; (hiddify-api restart || systemctl restart hiddify-manager || true)"
    ENV_FILE=""
    ;;
  6)
    TARGET_DIR="/opt/amnezia/certs"
    RELOAD_CMD="$RELOAD_CMD; (systemctl restart amnezia-vpn || true)"
    ENV_FILE=""
    ;;
  7)
    read -rp "  [?] Enter full certificate directory path: " TARGET_DIR
    ENV_FILE=""
    ;;
  *)
    red "  [❌] ERROR: Invalid choice."
    return 1
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

  # Final Summary
  show_banner
  green "                   [🏆] TawanaSSL Setup Completed! [🏆]"
  bold "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo -e "  \e[1;36mSTATUS:          \e[1;32mSUCCESS ✅\e[0m"
  echo -e "  \e[1;36mDOMAIN:          \e[0m $DOMAIN"
  echo -e "  \e[1;36mWILDCARD:        \e[0m *.$DOMAIN"
  echo -e "  \e[1;36mTARGET PATH:     \e[0m $TARGET_DIR"
  echo
  if [[ -n "$ENV_FILE" ]]; then
    yellow "  [🛠️] CONFIGURATION: $ENV_FILE has been patched with SSL paths."
  fi
  echo
  yellow "  [🧪] VERIFICATION COMMAND:"
  echo "   echo | openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} 2>/dev/null | openssl x509 -noout -dates"
  echo
  green "  [🛡️] Shield is active. Server restarted. Enjoy your freedom."
  echo
  press_enter
}

# ========================
#   Main Application
# ========================

main_menu() {
  while true; do
    show_banner
    echo -e "  \e[1;37mPlease select an action:\e[0m"
    echo -e "  \e[1;32m1)\e[0m Issue / Reinstall Wildcard SSL"
    echo -e "  \e[1;32m2)\e[0m Monitor Certificate Status \e[33m(Updated)\e[0m"
    echo -e "  \e[1;32m3)\e[0m Update TawanaSSL Engine"
    echo -e "  \e[1;31m4)\e[0m Uninstall Global Suite"
    echo -e "  \e[1;37m0) Exit\e[0m"
    echo
    read -rp "  [⚡] Command >> " choice

    case $choice in
      1) issue_ssl ;;
      2) check_ssl_status ;;
      3) update_script ;;
      4) 
        rm -i "$SCRIPT_PATH" && green "  [✔] Global record purged." || red "  [!] Operation canceled."
        exit 0
        ;;
      0) exit 0 ;;
      *) red "  [?] Invalid command." ; sleep 1 ;;
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
