#!/bin/bash
# Usage: start-llama.sh <label> [llama-server args...]
L=$1; shift
docker rm -f bench-llama >/dev/null 2>&1; sleep 3
t0=$(date +%s.%N)
docker run -d --name bench-llama --gpus all -p 127.0.0.1:8081:8080 -v $HOME/homelab-tests/ollama-vs-llamacpp/models:/models:ro \
  ghcr.io/ggml-org/llama.cpp:${IMG:-server-cuda-v1.0.0-b12359-b1b770d} -m /models/Qwen3.5-9B-Q4_K_M.gguf --alias qwen35-9b --host 0.0.0.0 --port 8080 "$@" >/dev/null
until curl -sf 127.0.0.1:8081/health >/dev/null; do sleep 0.3; docker ps -q -f name=bench-llama | grep -q . || { echo "$L: DIED"; docker logs bench-llama 2>&1 | tail -5; exit 1; }; done
echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc) s; VRAM $(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -i llama-server | grep -v ollama); args: $*" | tee -a setup-log.md
docker logs bench-llama 2>&1 | grep -E "n_ctx|n_parallel|n_slots|kv_unified|n_ctx_slot|fit" | head -8 >> setup-log.md
