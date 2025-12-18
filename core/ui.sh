# ========================
#   UI & Visuals Module
# ========================

# Colors
red()   { echo -e "\e[31m$*\e[0m"; }
green() { echo -e "\e[32m$*\e[0m"; }
yellow(){ echo -e "\e[33m$*\e[0m"; }
blue()  { echo -e "\e[34m$*\e[0m"; }
cyan()  { echo -e "\e[36m$*\e[0m"; }
bold()  { echo -e "\e[1m$*\e[0m"; }

# Banner
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
  bold "             TawanaSSL Elite v3.0 | Modular Core       "
  bold "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
}

press_enter() {
  echo
  read -rp "  [⏎] Press Enter to return to menu..."
}
