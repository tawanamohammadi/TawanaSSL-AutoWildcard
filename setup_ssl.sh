# ========================
#   Global Variables
# ========================
LANG="en" # Default
HAS_PYTHON_BIDI=false

# ========================
#   Helper Functions
# ========================

red()   { echo -e "\e[31m$*\e[0m"; }
green() { echo -e "\e[32m$*\e[0m"; }
yellow(){ echo -e "\e[33m$*\e[0m"; }
blue()  { echo -e "\e[34m$*\e[0m"; }
cyan()  { echo -e "\e[36m$*\e[0m"; }
bold()  { echo -e "\e[1m$*\e[0m"; }

# Multi-language print function
msg() {
  local en_msg=$1
  local fa_msg=$2
  local color=${3:-""}
  
  if [[ "$LANG" == "fa" ]]; then
    # Use python for shaping if available, else fribidi, else raw
    if [[ "$HAS_PYTHON_BIDI" == true ]]; then
      python3 -c "import arabic_reshaper; from bidi.algorithm import get_display; print(get_display(arabic_reshaper.reshape('$fa_msg')))" 2>/dev/null || echo "$fa_msg" | fribidi --charset UTF-8
    elif command -v fribidi >/dev/null 2>&1; then
      echo -e "$color" "$(echo "$fa_msg" | fribidi --charset UTF-8)" "\e[0m"
    else
      echo -e "$color$fa_msg\e[0m"
    fi
  else
    echo -e "$color$en_msg\e[0m"
  fi
}

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    red "ERROR: This script must be run as root."
    exit 1
  fi
}

press_enter() {
  if [[ "$LANG" == "fa" ]]; then
    read -rp "$(msg "Press Enter to continue..." "برای ادامه اینتر بزنید...") "
  else
    read -rp "Press Enter to continue..."
  fi
}

install_fa_deps() {
  yellow "Checking Persian display dependencies..."
  apt-get update -qq
  apt-get install -y libfribidi-bin python3-pip -qq
  pip3 install arabic-reshaper python-bidi --quiet 2>/dev/null || true
  if python3 -c "import arabic_reshaper, bidi" >/dev/null 2>&1; then
    HAS_PYTHON_BIDI=true
  fi
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

# ========================
#      Script Start
# ========================

require_root

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
bold "                   TawanaSSL Auto Wildcard Elite Installer"
bold "  =============================================================================="
echo

# Language Selection
echo "  Select Language / انتخاب زبان:"
echo "  1) English"
echo "  2) فارسی (Persian)"
echo
read -rp "  Choice (1/2): " LANG_CHOICE
if [[ "$LANG_CHOICE" == "2" ]]; then
  LANG="fa"
  install_fa_deps
fi

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
msg "  Automated Wildcard SSL for Marzban / Marzneshin / Pasargad / X-UI" "صدور خودکار گواهینامه وایلدکارد برای مرزبان، مرزنشین، پاسارگاد و ایکس-یوآی" "\e[1m"
msg "  Using: acme.sh + Cloudflare + Let's Encrypt" "با استفاده از: acme.sh + کلودفلر + لتس انکریپت"
msg "  Repo : https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard" "گیت‌هاب: https://github.com/tawanamohammadi/TawanaSSL-AutoWildcard"
bold "  =============================================================================="
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
msg "[Step 2/6] Domain configuration" "[مرحله ۲/۶] تنظیم دامنه" "\e[33m"
read -rp "$(msg "Enter your main domain (example: panbehpanel.ir): " "دامنه اصلی خود را وارد کنید (مثال: example.com): ") " DOMAIN

if [[ -z "$DOMAIN" ]]; then
  msg "ERROR: Domain cannot be empty." "خطا: دامنه نمی‌تواند خالی باشد." "\e[31m"
  exit 1
fi

echo
msg "Important:" "نکات حیاتی:" "\e[1;33m"
msg "  - The domain MUST exist in your Cloudflare account." "  - دامنه حتما باید در اکانت کلودفلر شما ثبت شده باشد."
msg "  - The domain's nameservers MUST point to Cloudflare." "  - نیم‌سرورهای دامنه باید به کلودفلر متصل باشند."
msg "  - Ensure you have an A record pointing your domain to this server." "  - حتما یک رکورد A برای اتصال دامنه به آی‌پی این سرور بسازید."
msg "  - Magic: This issues a Wildcard SSL (*.domain) for ALL subdomains!" "  - جادو: این اسکریپت تمام ساب‌دامین‌های شما را یکجا امن می‌کند!"
echo
press_enter

# ---- Step 3: Choose certificate path & reload behavior ----
echo
msg "[Step 3/6] Certificate install path & service reload" "[مرحله ۳/۶] مسیر نصب و بازنشانی سرویس‌ها" "\e[33m"
msg "Select certificate installation path:" "مسیر نصب گواهینامه را انتخاب کنید:"
echo "  1) Marzban      (/var/lib/marzban/certs)"
echo "  2) Marzneshin   (/var/lib/marzneshin/certs)"
echo "  3) Pasargad     (/var/lib/pasarguard/certs)"
echo "  4) 3X-UI / X-UI (/etc/x-ui/certs)"
msg "  5) Custom Path" "  ۵) مسیر سفارشی"
echo

read -rp "$(msg "Choose (1/2/3/4/5): " "انتخاب کنید (۱/۲/۳/۴/۵): ") " PATH_CHOICE
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
    read -rp "$(msg "Enter full certificate directory path: " "مسیر کامل دایرکتوری گواهینامه را وارد کنید: ") " TARGET_DIR
    ENV_FILE=""
    ;;
  *)
    msg "ERROR: Invalid choice." "خطا: انتخاب نامعتبر." "\e[31m"
    exit 1
    ;;
esac

if [[ -z "$TARGET_DIR" ]]; then
  msg "ERROR: Target directory cannot be empty." "خطا: مسیر هدف نمی‌تواند خالی باشد." "\e[31m"
  exit 1
fi

msg "Selected certificate directory: $TARGET_DIR" "مسیر انتخاب شده: $TARGET_DIR" "\e[33m"
mkdir -p "$TARGET_DIR"

if [[ -n "$ENV_FILE" ]]; then
  update_panel_env "$ENV_FILE" "$TARGET_DIR/fullchain.pem" "$TARGET_DIR/key.pem"
fi

echo
msg "Service reload command will be:" "دستور بازنشانی سرویس‌ها:" "\e[33m"
echo "  $RELOAD_CMD"
echo
press_enter

# ========================
#   Step 4: Install acme.sh
# ========================

echo
msg "[Step 4/6] Checking acme.sh installation" "[مرحله ۴/۶] بررسی نصب acme.sh" "\e[33m"

ACME_SH="/root/.acme.sh/acme.sh"

if [[ ! -x "$ACME_SH" ]]; then
  msg "acme.sh not found. Installing..." "ابزار acme.sh یافت نشد. در حال نصب..." "\e[33m"
  curl https://get.acme.sh | sh
  ACME_SH="/root/.acme.sh/acme.sh"
  if [[ ! -x "$ACME_SH" ]]; then
    msg "ERROR: acme.sh installation failed." "خطا: نصب acme.sh با شکست مواجه شد." "\e[31m"
    exit 1
  fi
  msg "acme.sh installed successfully." "نصب acme.sh با موفقیت انجام شد." "\e[32m"
else
  msg "acme.sh is already installed." "ابزار acme.sh قبلاً نصب شده است." "\e[32m"
fi

msg "Setting Let's Encrypt as default CA..." "تنظیم Let's Encrypt به عنوان مرجع صدور..." "\e[33m"
"$ACME_SH" --set-default-ca --server letsencrypt
msg "Default CA set to Let's Encrypt." "مرجع صدور با موفقیت تنظیم شد." "\e[32m"
echo

# Set Cloudflare env vars
export CF_Email
export CF_Key

# ========================
#   Step 5: Issue wildcard cert
# ========================

msg "[Step 5/6] Requesting wildcard SSL certificate" "[مرحله ۵/۶] درخواست گواهینامه SSL" "\e[33m"
msg "Requesting wildcard SSL for:" "در حال درخواست گواهینامه برای:" "\e[33m"
echo "  - $DOMAIN"
echo "  - *.$DOMAIN"
echo

if ! "$ACME_SH" --issue \
  --dns dns_cf \
  -d "$DOMAIN" \
  -d "*.$DOMAIN" \
  --keylength ec-256; then

  msg "ERROR: Failed to issue wildcard certificate." "خطا: صدور گواهینامه با شکست مواجه شد." "\e[31m"
  exit 1
fi

msg "Wildcard certificate successfully issued." "گواهینامه با موفقیت صادر شد." "\e[32m"
echo

# ========================
#   Step 6: Install cert
# ========================

msg "[Step 6/6] Installing certificate to target directory" "[مرحله ۶/۶] نصب گواهینامه در مسیر هدف" "\e[33m"

TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")

# Backup old certs if they exist
if [[ -f "$TARGET_DIR/fullchain.pem" ]]; then
  cp "$TARGET_DIR/fullchain.pem" "$TARGET_DIR/fullchain.pem.bak-$TIMESTAMP"
fi

if [[ -f "$TARGET_DIR/key.pem" ]]; then
  cp "$TARGET_DIR/key.pem" "$TARGET_DIR/key.pem.bak-$TIMESTAMP"
fi

msg "Installing new certificate and key..." "در حال نصب گواهینامه و کلید جدید..." "\e[33m"
if ! "$ACME_SH" --install-cert -d "$DOMAIN" --ecc \
  --key-file "$TARGET_DIR/key.pem" \
  --fullchain-file "$TARGET_DIR/fullchain.pem" \
  --reloadcmd "$RELOAD_CMD"; then

  msg "ERROR: Failed to install certificate." "خطا: نصب گواهینامه با شکست مواجه شد." "\e[31m"
  exit 1
fi

msg "Certificate installed and services reload command executed." "گواهینامه نصب و سرویس‌ها ری‌استارت شدند." "\e[32m"
echo

# ========================
#   Final Summary
# ========================

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
msg "                   TawanaSSL Setup Completed! ✅" "عملیات با موفقیت به پایان رسید! ✅" "\e[1;32m"
bold "  =============================================================================="
echo
msg " Status:           SUCCESS ✅" " وضعیت:           موفقیت‌آمیز ✅"
echo
msg " Domain:           $DOMAIN" " دامنه:           $DOMAIN"
msg " Wildcard:         *.$DOMAIN" " وایلدکارد:         *.$DOMAIN"
msg " Certificate path: $TARGET_DIR" " مسیر گواهینامه: $TARGET_DIR"
echo
if [[ -n "$ENV_FILE" ]]; then
  msg " Configuration:    Updated $ENV_FILE" " تنظیمات:    فایل $ENV_FILE بروزرسانی شد"
fi
echo
msg " Useful test command:" " دستور تست پیشنهادی:" "\e[33m"
echo "   echo | openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} 2>/dev/null | openssl x509 -noout -dates"
echo
msg " acme.sh auto-renew is active. Enjoy your secure server!" " تمدید خودکار فعال است. از سرور امن خود لذت ببرید!" "\e[1;32m"
msg " Done. Have a secure day. 🔐" " تمام. روز امنی داشته باشید. 🔐"
echo
```
