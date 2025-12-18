# ========================
#   DNS Automation Module
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
    
    # Auto-yes if requested or prompt
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
