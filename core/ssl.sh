# ========================
#   SSL Logic Module
# ========================

ensure_acme_installed() {
  local ACME_SH="/root/.acme.sh/acme.sh"
  
  if [[ ! -x "$ACME_SH" ]]; then
    yellow "  [📦] Installing acme.sh..."
    curl https://get.acme.sh | sh
    if [[ ! -x "$ACME_SH" ]]; then
      red "  [❌] acme.sh installation failed."
      exit 1
    fi
    green "  [✅] acme.sh installed."
  fi
  
  "$ACME_SH" --set-default-ca --server letsencrypt >/dev/null 2>&1
}

request_wildcard_cert() {
  local domain=$1
  local email=$2
  local key=$3
  local ACME_SH="/root/.acme.sh/acme.sh"
  
  ensure_acme_installed

  export CF_Email="$email"
  export CF_Key="$key"

  yellow "  [🔐] Requesting Wildcard SSL for *.$domain ..."
  
  if ! "$ACME_SH" --issue --dns dns_cf -d "$domain" -d "*.$domain" --keylength ec-256; then
    red "  [❌] Failed to issue wildcard certificate."
    return 1
  fi
  
  green "  [✅] Certificate issued successfully."
}

install_cert_to_path() {
  local domain=$1
  local target_dir=$2
  local reload_cmd=$3
  local ACME_SH="/root/.acme.sh/acme.sh"
  local TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")

  yellow "  [📂] Installing to: $target_dir"
  mkdir -p "$target_dir"

  # Backup
  [[ -f "$target_dir/fullchain.pem" ]] && cp "$target_dir/fullchain.pem" "$target_dir/fullchain.pem.bak-$TIMESTAMP"
  [[ -f "$target_dir/key.pem" ]] && cp "$target_dir/key.pem" "$target_dir/key.pem.bak-$TIMESTAMP"

  if ! "$ACME_SH" --install-cert -d "$domain" --ecc \
    --key-file "$target_dir/key.pem" \
    --fullchain-file "$target_dir/fullchain.pem" \
    --reloadcmd "$reload_cmd"; then
    red "  [❌] Failed to install certificate."
    return 1
  fi
  
  green "  [✅] Certificate installed and service reloaded."
}
