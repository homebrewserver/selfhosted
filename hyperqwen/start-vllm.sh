#!/bin/bash
# Usage: start.sh <engine> <label> [extra args]
# Starts one server with Qwen3.8-27B, logs time to ready, VRAM and the effective settings to setup-log.md.
# engine: llama | ollama | lms | vllm. All other bench containers are removed first.
E=$1; L=$2; shift 2
cd "$(dirname "$0")"
GGUF_DIR=$HOME/models
GGUF=Qwen3.8-27B-UD-Q4_K_M.gguf
(cd repo && docker compose --profile batch --profile single down) >/dev/null 2>&1; docker rm -f bench-llama bench-ollama-q38 bench-vllm >/dev/null 2>&1; docker stop bench-lms-q38 >/dev/null 2>&1; sleep 5
vram() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -iE "llama|vllm|python" | tr '\n' ';'; }
t0=$(date +%s.%N)
case $E in
  llama)
    docker run -d --name bench-llama --gpus all -p 127.0.0.1:8081:8080 -v $GGUF_DIR:/models:ro \
      ghcr.io/ggml-org/llama.cpp:server-cuda-v1.0.0-b12359-b1b770d -m /models/$GGUF --alias qwen38-27b --host 0.0.0.0 --port 8080 "$@" >/dev/null
    until curl -sf 127.0.0.1:8081/health >/dev/null; do sleep 0.3; docker ps -q -f name=bench-llama | grep -q . || { echo "$L: DIED"; exit 1; }; done
    echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc) s; VRAM $(vram); args: $*" | tee -a setup-log.md
    docker logs bench-llama 2>&1 | grep -E "n_slots" | head -1 >> setup-log.md ;;
  ollama)
    docker run -d --name bench-ollama-q38 --gpus all -p 127.0.0.1:11435:11434 "$@" -v $PWD/ollama-data:/root/.ollama \
      -v $GGUF_DIR:/gguf:ro ollama/ollama:0.40.15 >/dev/null
    until curl -sf 127.0.0.1:11435/api/version >/dev/null; do sleep 0.3; done; t1=$(date +%s.%N)
    ld=$(curl -s 127.0.0.1:11435/api/generate -d '{"model":"'"${OM:-qwen38-27b}"'","prompt":"hi","stream":false,"think":false,"options":{"num_predict":1}}' | /usr/bin/python3 -c 'import sys,json;print(round(json.load(sys.stdin)["load_duration"]/1e9,2))')
    echo "$L: API up $(echo "$(date +%s.%N)-$t0" | bc | cut -c1-6) s (api $(echo "$t1-$t0"|bc|cut -c1-5) s), first answer $(echo "$(date +%s.%N)-$t0" | bc) s, load_duration $ld s; VRAM $(vram); ps: $(docker exec bench-ollama-q38 ollama ps | tail -1); env: $*" | tee -a setup-log.md
    docker logs bench-ollama-q38 2>&1 | grep -o 'llama-server --model.*' | head -1 | cut -c1-300 >> setup-log.md ;;
  lms)
    docker start bench-lms-q38 >/dev/null
    until curl -sf 127.0.0.1:11234/v1/models >/dev/null; do sleep 0.3; done
    docker exec bench-lms-q38 lms unload --all >/dev/null 2>&1; t1=$(date +%s.%N)
    docker exec bench-lms-q38 lms load qwen3.8-27b "$@" -y >/dev/null 2>&1
    echo "$L: container+API $(echo "$t1-$t0"|bc|cut -c1-5) s, lms load $(echo "$(date +%s.%N)-$t1" | bc) s; VRAM $(vram); args: $*" | tee -a setup-log.md
    docker exec bench-lms-q38 lms ps 2>/dev/null | grep -i qwen >> setup-log.md ;;
  vllm)
    docker run -d --name bench-vllm --gpus all --ipc=host -p 127.0.0.1:8000:8000 -e HF_HUB_OFFLINE=1 \
      -v ~/.cache/huggingface:/root/.cache/huggingface -v -v $HOME/vllm-cache:/root/.cache/vllm \
      vllm/vllm-openai:v0.33.0 --model cyankiwi/Qwen3.8-27B-AWQ-INT4 --served-model-name qwen38-27b --language-model-only "$@" >/dev/null
    until curl -sf 127.0.0.1:8000/health >/dev/null; do sleep 0.5; docker ps -q -f name=bench-vllm | grep -q . || { echo "$L: DIED"; docker logs bench-vllm 2>&1 | grep -E 'Error' | tail -3 | tee -a setup-log.md; exit 1; }; done
    echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc) s; $(docker logs bench-vllm 2>&1 | grep -o -E 'GPU KV cache size: [0-9,]+ tokens|Maximum concurrency for [0-9,]+ tokens per request: [0-9.]+x|Model loading took [0-9.]+ GiB' | tr '\n' ' '); VRAM $(vram); args: $*" | tee -a setup-log.md ;;
esac
