#!/bin/bash
# Usage: start-vllm.sh <label> [extra vllm args...]; env EXTRA_ENV="-e X=Y"
L=$1; shift
docker rm -f bench-vllm >/dev/null 2>&1; sleep 3
t0=$(date +%s.%N)
docker run -d --name bench-vllm --gpus all --ipc=host -p 127.0.0.1:8000:8000 $EXTRA_ENV \
  -v ~/.cache/huggingface:/root/.cache/huggingface -v $PWD/vllm-cache:/root/.cache/vllm \
  vllm/vllm-openai:v0.33.0 --model cyankiwi/Qwen3.5-9B-AWQ-4bit --served-model-name qwen35-9b --max-model-len 32768 "$@" >/dev/null
until curl -sf 127.0.0.1:8000/health >/dev/null; do sleep 0.5; docker ps -q -f name=bench-vllm | grep -q . || { echo "$L: DIED"; docker logs bench-vllm 2>&1 | grep -E 'Error|error' | tail -5; exit 1; }; done
echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc) s; $(docker logs bench-vllm 2>&1 | grep -o -E 'GPU KV cache size: [0-9,]+ tokens|Maximum concurrency for [0-9,]+ tokens per request: [0-9.]+x' | tr '\n' ' '); VRAM $(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep VLLM)" | tee -a setup-log.md
