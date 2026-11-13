#!/bin/bash
# Usage: start-ollama.sh <label> [-e ENV=...]
L=$1; shift
docker rm -f bench-ollama >/dev/null 2>&1; sleep 3
t0=$(date +%s.%N)
docker run -d --name bench-ollama --gpus all -p 127.0.0.1:11435:11434 "$@" -e OLLAMA_DEBUG=1 \
  -v $HOME/homelab-tests/ollama-vs-llamacpp/ollama-data:/root/.ollama ollama/ollama:0.40.15 >/dev/null
until curl -sf 127.0.0.1:11435/api/version >/dev/null; do sleep 0.3; done; t1=$(date +%s.%N)
curl -s 127.0.0.1:11435/api/generate -d '{"model":"qwen35-9b-hf","prompt":"hi","stream":false,"think":false,"options":{"num_predict":1}}' | python3 -c 'import sys,json;d=json.load(sys.stdin);print("load_duration_s",round(d["load_duration"]/1e9,2))' > /tmp/ol.txt; t2=$(date +%s.%N)
echo "$L: API up $(echo "$t1-$t0"|bc) s, first answer $(echo "$t2-$t0"|bc) s, $(cat /tmp/ol.txt); VRAM $(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -i llama); ps: $(docker exec bench-ollama ollama ps | tail -1)" | tee -a setup-log.md
docker logs bench-ollama 2>&1 | grep -o 'llama-server --model.*' | head -1 | cut -c1-300 | tee -a setup-log.md
