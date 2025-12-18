# ========================
#   Utilities Module
# ========================

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    red "  [❌] ERROR: This script must be run as root."
    exit 1
  fi
}

update_panel_env() {
  local env_path=$1
  local cert_path=$2
  local key_path=$3
  if [[ -f "$env_path" ]]; then
    yellow "  [⚙️] Updating configuration at $env_path..."
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
    green "  [✅] Environment file updated."
  fi
}
