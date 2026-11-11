# Local LLMs: Ollama + Open WebUI over Tailscale

| Machine | Hardware | Role |
|---|---|---|
| pcryzen | Ryzen 7 5700X, 32GB DDR4, RTX 4070 Ti Super 16GB | Main Ollama server (GPU) |
| mini | Ryzen 7 7840HS, 32GB DDR5, Radeon 780M iGPU | Second Ollama server (CPU + iGPU) |
| thinkcentre | i5-6500T | Open WebUI (Docker, port 3000) |

## Install Ollama (each server)
    curl -fsSL https://ollama.com/install.sh | sh
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    sudo cp <machine>/override.conf /etc/systemd/system/ollama.service.d/override.conf
    sudo systemctl daemon-reload && sudo systemctl restart ollama
    ss -tlnp | grep 11434   # must show *:11434, not 127.0.0.1

Gotcha: `sudo systemctl edit ollama` saved nothing when the edit area was left empty.
Writing the override file directly is more reliable.

## Radeon 780M (mini) troubleshooting
1. Log: `dropping ROCm device - no rocblas support for gfx target gfx1103`
   -> `HSA_OVERRIDE_GFX_VERSION=11.0.2`
2. Log: `dropping integrated GPU; to enable, set OLLAMA_IGPU_ENABLE=1`
   -> `OLLAMA_IGPU_ENABLE=1`
3. Result: iGPU gets 15.3 GiB; qwen3.6:35b runs 37%/63% CPU/GPU.

Check with: `journalctl -u ollama | grep -iE "inference compute|vram|dropping"` and `ollama ps`.

## Benchmarks (mini, qwen3.6:35b, 2819-token prompt)
| | CPU only | CPU + 780M |
|---|---|---|
| Prompt processing | ~143 tok/s | ~417 tok/s |
| Generation | ~19 tok/s | ~22-29 tok/s |

The iGPU mainly speeds up reading long prompts. Generation is limited by shared DDR5 bandwidth.

## Models
pc: qwen3.6:35b (default), qwen3.8:27b, qwen3-coder:30b, gemma4:12b, qwen3-vl:8b, gpt-oss:20b, qwen3-embedding:4b (RAG)
mini: qwen3.6:35b, gemma4:26b, qwen3.5:4b

## Notes
- Models unload after 5 min idle (OLLAMA_KEEP_ALIVE default). Open WebUI title/tag
  requests reset the timer. `ollama ps` shows time left, `ollama stop <model>` unloads now.
- Same model name on both servers gets merged in Open WebUI -> set a Prefix ID per connection.
- ufw is inactive: Ollama is reachable from the LAN without auth. TODO: allow only tailscale0.
