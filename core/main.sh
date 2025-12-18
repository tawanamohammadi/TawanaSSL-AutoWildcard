#!/bin/bash
# TawanaSSL Main Entry Point
# This file is symlinked to /usr/local/bin/tawanassl

# Resolve script directory to source core modules
# When installed globally, this script is symlinked from /usr/local/tawanassl/core/main.sh
# So the directory of the real script is .../tawanassl/core
REAL_SCRIPT_PATH="$(readlink -f "$0")"
CORE_DIR="$(dirname "$REAL_SCRIPT_PATH")"       # /usr/local/tawanassl/core
INSTALL_ROOT="$(dirname "$CORE_DIR")"           # /usr/local/tawanassl

export TAWANA_ROOT="$INSTALL_ROOT"

# Source Core Modules
source "$TAWANA_ROOT/core/ui.sh"
source "$TAWANA_ROOT/core/utils.sh"
source "$TAWANA_ROOT/core/dns.sh"
source "$TAWANA_ROOT/core/ssl.sh"

# ========================
#   Main Logic
# ========================

run_wizard() {
  show_banner
  
  # Step 1: Cloudflare Auth
  yellow "  [🔑] Step 1/6: Cloudflare Credentials"
  read -rp "  Enter your Cloudflare Email: " CF_Email
  [[ -z "$CF_Email" ]] && { red "  [❌] Email is required."; return 1; }
  read -rsp "  Enter your Cloudflare Global API Key: " CF_Key
  echo
  [[ -z "$CF_Key" ]] && { red "  [❌] Key is required."; return 1; }
  echo

  # Step 2: Domain & DNS
  yellow "  [🌐] Step 2/6: Domain Configuration"
  read -rp "  Enter your domain (example.com): " DOMAIN
  [[ -z "$DOMAIN" ]] && { red "  [❌] Domain is required."; return 1; }
  
  check_or_create_dns "$DOMAIN" "$CF_Email" "$CF_Key"
  
  # Step 3: Panel Selection (Parsing Schema - Simple Bash Parser)
  # For simplicity in Bash without jq dependency, we hardcode read but structure is ready for JSON parsing if jq exists
  show_banner
  yellow "  [💿] Step 3/6: Select Your Panel"
  echo "  [Regional Favorites]"
  echo "    1) Marzban"
  echo "    2) Marzneshin"
  echo "    3) Pasargad"
  echo "  [Global Favorites]"
  echo "    4) X-UI / 3X-UI"
  echo "    5) Hiddify"
  echo "    6) Amnezia VPN"
  echo "  [Universal]"
  echo "    7) Custom Path"
  echo
  read -rp "  [⚡] Selection >> " CHOICE
  
  # Default Values
  case "$CHOICE" in
    1) T_PATH="/var/lib/marzban/certs"; T_CMD="systemctl restart marzban || true"; T_ENV="/opt/marzban/.env" ;;
    2) T_PATH="/var/lib/marzneshin/certs"; T_CMD="systemctl restart marzneshin || true"; T_ENV="" ;;
    3) T_PATH="/var/lib/pasarguard/certs"; T_CMD="systemctl restart pasarguard || true"; T_ENV="/opt/pasarguard/.env" ;;
    4) T_PATH="/etc/x-ui/certs"; T_CMD="x-ui restart || systemctl restart x-ui || true"; T_ENV="" ;;
    5) T_PATH="/opt/hiddify-manager/certs"; T_CMD="hiddify-api restart || true"; T_ENV="" ;;
    6) T_PATH="/opt/amnezia/certs"; T_CMD="systemctl restart amnezia-vpn || true"; T_ENV="" ;;
    7) read -rp "  [?] Enter path: " T_PATH; T_CMD="systemctl reload nginx || true"; T_ENV="" ;;
    *) red "  [❌] Invalid choice"; return 1 ;;
  esac
  
  # Step 4 & 5: Issue & Install
  request_wildcard_cert "$DOMAIN" "$CF_Email" "$CF_Key"
  install_cert_to_path "$DOMAIN" "$T_PATH" "$T_CMD"
  
  # Step 6: Env file update
  if [[ -n "$T_ENV" ]]; then
    update_panel_env "$T_ENV" "$T_PATH/fullchain.pem" "$T_PATH/key.pem"
  fi
  
  # Final
  show_banner
  green "  [🏆] TawanaSSL Setup Completed Successfully!"
  echo
  echo "  Domain:   $DOMAIN"
  echo "  Path:     $T_PATH"
  echo
  green "  [🛡️] Your server is now secured."
  press_enter
}

check_status() {
  local paths=(
    "/var/lib/marzban/certs"
    "/var/lib/marzneshin/certs"
    "/var/lib/pasarguard/certs"
    "/etc/x-ui/certs"
    "/opt/hiddify-manager/certs"
    "/opt/amnezia/certs"
  )
  
  show_banner
  cyan "  [🔍] SYSTEM SCAN: Checking Certificates..."
  echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  for p in "${paths[@]}"; do
    if [[ -f "$p/fullchain.pem" ]]; then
      local expiry=$(openssl x509 -in "$p/fullchain.pem" -noout -enddate | cut -d= -f2)
      local subject=$(openssl x509 -in "$p/fullchain.pem" -noout -subject | sed 's/.*CN = //')
      echo -e "  \e[1;32mFOUND\e[0m: $subject"
      echo "  Path:  $p"
      echo "  Exp:   $expiry"
      echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
  done
  press_enter
}

# Main Loop
require_root

while true; do
  show_banner
  echo -e "  \e[1;37mPlease select an action:\e[0m"
  echo -e "  \e[1;32m1)\e[0m Issue / Reinstall Wildcard SSL"
  echo -e "  \e[1;32m2)\e[0m Monitor Certificate Status"
  echo -e "  \e[1;32m3)\e[0m Update TawanaSSL Suite"
  echo -e "  \e[1;31m4)\e[0m Uninstall"
  echo -e "  \e[1;37m0) Exit\e[0m"
  echo
  read -rp "  [⚡] Command >> " m_choice
  
  case $m_choice in
    1) run_wizard ;;
    2) check_status ;;
    3) bash <(curl -sL https://raw.githubusercontent.com/tawanamohammadi/TawanaSSL-AutoWildcard/main/setup_ssl.sh) @ --update ;;
    4) rm -rf "$TAWANA_ROOT" "/usr/local/bin/tawanassl"; green "  [🗑️] Uninstalled."; exit 0 ;;
    0) exit 0 ;;
    *) red "Invalid option" ; sleep 1 ;;
  esac
done
