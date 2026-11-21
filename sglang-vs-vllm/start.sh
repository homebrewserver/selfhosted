#!/bin/bash
# Usage: start.sh <vllm|sglang> <label> [extra engine args]
# Starts one server with the model in $MODEL (default Qwen3.8-27B AWQ INT4), logs time to ready, KV cache and VRAM to setup-log.md.
E=$1; L=$2; shift 2
cd ~/homelab-tests/sglang-vs-vllm
HF="-e HF_HUB_OFFLINE=1 -v $HOME/.cache/huggingface:/root/.cache/huggingface -v /path/to/hf-archive:/path/to/hf-archive:ro"
docker rm -f bench-vllm bench-sglang >/dev/null 2>&1; sleep 5
vram() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -iE "vllm|python|sglang" | tr '\n' ';'; }
desk() { nvidia-smi --query-gpu=memory.used --format=csv,noheader; }
echo "--- $(date '+%F %T') $L: GPU before start $(desk)" >> setup-log.md
t0=$(date +%s.%N)
case $E in
  vllm)
    docker run -d --name bench-vllm --gpus all --ipc=host -p 127.0.0.1:8000:8000 $HF -v $PWD/vllm-cache:/root/.cache/vllm \
      vllm/vllm-openai:v0.33.0 --model ${MODEL:-cyankiwi/Qwen3.8-27B-AWQ-INT4} --served-model-name ${NAME:-qwen38-27b} "$@" >/dev/null
    until curl -sf 127.0.0.1:8000/health >/dev/null; do sleep 0.5; docker ps -q -f name=bench-vllm | grep -q . || { echo "$L: DIED"; docker logs bench-vllm 2>&1 | grep -E 'Error' | tail -3 | tee -a setup-log.md; exit 1; }; done
    echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc) s; $(docker logs bench-vllm 2>&1 | grep -o -E 'GPU KV cache size: [0-9,]+ tokens|Maximum concurrency for [0-9,]+ tokens per request: [0-9.]+x|Model loading took [0-9.]+ GiB' | tr '\n' ' '); VRAM $(vram); args: $*" | tee -a setup-log.md ;;
  sglang)
    docker run -d --name bench-sglang --gpus all --ipc=host --shm-size 16g -p 127.0.0.1:30000:30000 $HF -v $PWD/sglang-cache:/root/.cache \
      lmsysorg/sglang:v0.5.23 python3 -m sglang.launch_server --model-path ${MODEL:-cyankiwi/Qwen3.8-27B-AWQ-INT4} --served-model-name ${NAME:-qwen38-27b} \
      --host 0.0.0.0 --port 30000 "$@" >/dev/null
    until curl -sf 127.0.0.1:30000/health >/dev/null; do sleep 0.5; docker ps -q -f name=bench-sglang | grep -q . || { echo "$L: DIED"; docker logs bench-sglang 2>&1 | grep -iE 'error|out of memory' | tail -5 | tee -a setup-log.md; exit 1; }; done
    echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc) s; $(docker logs bench-sglang 2>&1 | grep -o -iE 'KV Cache is allocated[^,]*, #tokens: [0-9]+|max_total_num_tokens=[0-9]+|max_running_requests=[0-9]+|context_len=[0-9]+|mem usage=[0-9.]+ GB' | sort -u | tr '\n' ' '); VRAM $(vram); args: $*" | tee -a setup-log.md ;;
esac
