#!/bin/bash
# Ollama 0.40.15 with the library tag qwen3.8:27b-mtp-q4_K_M (Ollama's own Q4_K_M file + MTP, draft-mtp n_max 4). Same matrix as run-all.sh.
cd ~/homelab-tests/qwen38-four-engines
eval "$(sed -n '5,12p' run-all.sh)"
M=qwen3.8:27b-mtp-q4_K_M; OL="http://127.0.0.1:11435"
echo "=== ollama mtp run start $(date '+%F %T')" | tee -a setup-log.md
OM=$M ./start.sh ollama "ollama defaults, $M" && matrix ollama $OL $M ollama-mtp
docker logs bench-ollama-q38 2>&1 | grep 'draft acceptance' | tail -3 >> setup-log.md
docker logs bench-ollama-q38 2>&1 | grep -E 'statistics +draft-mtp' | tail -1 >> setup-log.md
docker rm -f bench-ollama-q38 >/dev/null
echo "=== ollama mtp run done $(date '+%F %T')" | tee -a setup-log.md
