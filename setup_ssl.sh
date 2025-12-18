#!/bin/bash
# ==========================================
# TawanaSSL Elite Installer / Bootstrapper
# ==========================================
# This script installs the TawanaSSL Modular Suite from GitHub.
# It sets up the directory structure, downloads core files, and creates the global command.

REPO_RAW="https://raw.githubusercontent.com/tawanamohammadi/TawanaSSL-AutoWildcard/main"
INSTALL_DIR="/usr/local/tawanassl"
BIN_PATH="/usr/local/bin/tawanassl"

# Colors
red()   { echo -e "\e[31m$*\e[0m"; }
green() { echo -e "\e[32m$*\e[0m"; }
cyan()  { echo -e "\e[36m$*\e[0m"; }

if [[ "$EUID" -ne 0 ]]; then
  red "ERROR: Run as root."
  exit 1
fi

cyan "  [⬇️] Installing TawanaSSL Elite Suite..."

# 1. Create Directories
mkdir -p "$INSTALL_DIR/core"
mkdir -p "$INSTALL_DIR/schemas"
mkdir -p "$INSTALL_DIR/config"

# 2. Download Core Modules (Simulated loop for simplicity)
curl -sL "$REPO_RAW/core/ui.sh" -o "$INSTALL_DIR/core/ui.sh"
curl -sL "$REPO_RAW/core/utils.sh" -o "$INSTALL_DIR/core/utils.sh"
curl -sL "$REPO_RAW/core/dns.sh" -o "$INSTALL_DIR/core/dns.sh"
curl -sL "$REPO_RAW/core/ssl.sh" -o "$INSTALL_DIR/core/ssl.sh"
curl -sL "$REPO_RAW/core/main.sh" -o "$INSTALL_DIR/core/main.sh"
curl -sL "$REPO_RAW/schemas/panels.json" -o "$INSTALL_DIR/schemas/panels.json"

chmod +x "$INSTALL_DIR/core/main.sh"

# 3. Create Symlink
rm -f "$BIN_PATH"
ln -s "$INSTALL_DIR/core/main.sh" "$BIN_PATH"
chmod +x "$BIN_PATH"

green "  [✅] Installed successfully to $INSTALL_DIR"
green "  [✨] You can now use the command: tawanassl"

# 4. Auto-launch if requested
if [[ "$1" == "@" && "$2" == "--install" ]]; then
  "$BIN_PATH"
elif [[ "$1" == "@" && "$2" == "--update" ]]; then
   green "  [🏆] Update complete."
   sleep 1
   "$BIN_PATH"
else
   # If run manually not via one-liner hook
   "$BIN_PATH"
fi
