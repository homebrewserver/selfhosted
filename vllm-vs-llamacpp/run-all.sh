#!/bin/bash
cd ~/homelab-tests/vllm-vs-llamacpp
echo "=== start $(date '+%F %T')" | tee -a setup-log.md
echo "baseline VRAM before (desktop): $(nvidia-smi --query-gpu=memory.used --format=csv,noheader)" | tee -a setup-log.md
B() { python3 bench.py llamacpp --url http://127.0.0.1:8081 --model qwen35-9b "$@" | tail -1; }
# 1. llama-server defaults (np auto, unified KV, --fit)
./start-llama.sh "llama defaults"
B --prompt short -n 512 -k 1 --rounds 5 --label llama-def-k1-short
B --prompt long -n 256 -k 1 --rounds 5 --label llama-def-k1-long
for k in 4 8 16 32; do B --prompt short -n 256 -k $k --rounds 3 --label llama-def-k$k-short; done
B --prompt long -n 256 -k 8 --rounds 3 --label llama-def-k8-long
# 2. tuned for concurrency: 32 slots, unified 262k KV pool (vLLM had ~315k)
./start-llama.sh "llama np32 c262144 kvu" -np 32 -c 262144 --kv-unified
B --prompt short -n 512 -k 1 --rounds 5 --label llama-np32-k1-short
B --prompt long -n 256 -k 1 --rounds 5 --label llama-np32-k1-long
for k in 4 8 16 32; do B --prompt short -n 256 -k $k --rounds 3 --label llama-np32-k$k-short; done
B --prompt long -n 256 -k 8 --rounds 3 --label llama-np32-k8-long
# 3. middle setting: 16 slots
./start-llama.sh "llama np16 c131072 kvu" -np 16 -c 131072 --kv-unified
for k in 1 4 8 16 32; do B --prompt short -n 256 -k $k --rounds 3 --label llama-np16-k$k-short; done
docker rm -f bench-llama >/dev/null
# 4. vLLM same-day check (same command as #70)
cd ~/homelab-tests/vllm-vs-ollama && ./start-vllm.sh "vllm same-day check" | tee -a ~/homelab-tests/vllm-vs-llamacpp/setup-log.md
cd ~/homelab-tests/vllm-vs-llamacpp
for k in 1 16; do python3 bench.py vllm --url http://127.0.0.1:8000 --model qwen35-9b --prompt short -n 256 -k $k --rounds 3 --label vllm-recheck-k$k-short | tail -1; done
docker rm -f bench-vllm >/dev/null
echo "=== done $(date '+%F %T')" | tee -a setup-log.md
