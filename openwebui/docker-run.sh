#!/usr/bin/env bash
# Open WebUI on the ThinkCentre, http://thinkcentre:3000
# Ollama backends are added in Admin Panel -> Settings -> Connections:
#   http://100.83.82.14:11434   (pcryzen, prefix "pc")
#   http://100.98.113.116:11434 (mini, prefix "mini")
# Tailscale IPs are used because MagicDNS names don't always resolve inside containers.
docker run -d --name open-webui --restart always \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://100.83.82.14:11434 \
  -v open-webui:/app/backend/data \
  ghcr.io/open-webui/open-webui:main
