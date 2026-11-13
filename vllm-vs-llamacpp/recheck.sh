#!/bin/bash
cd ~/homelab-tests/vllm-vs-llamacpp
echo "=== recheck start $(date '+%F %T'); desktop VRAM $(nvidia-smi --query-gpu=memory.used --format=csv,noheader)" | tee -a setup-log.md
./start-llama.sh "llama defaults (recheck)"
python3 bench.py llamacpp --url http://127.0.0.1:8081 --model qwen35-9b --prompt short -n 512 -k 1 --rounds 5 --label llama-def-k1-short-recheck | tail -1
docker rm -f bench-llama >/dev/null
cd ~/homelab-tests/vllm-vs-ollama && ./start-vllm.sh "vllm mem0.6 seqs32 same-day" --gpu-memory-utilization 0.6 --max-num-seqs 32 | tee -a ~/homelab-tests/vllm-vs-llamacpp/setup-log.md
cd ~/homelab-tests/vllm-vs-llamacpp
V() { python3 bench.py vllm --url http://127.0.0.1:8000 --model qwen35-9b "$@" | tail -1; }
V --prompt short -n 512 -k 1 --rounds 5 --label vllm-m06-k1-short
V --prompt long -n 256 -k 1 --rounds 5 --label vllm-m06-k1-long
for k in 4 8 16 32; do V --prompt short -n 256 -k $k --rounds 3 --label vllm-m06-k$k-short; done
V --prompt long -n 256 -k 8 --rounds 3 --label vllm-m06-k8-long
docker rm -f bench-vllm >/dev/null
echo "=== recheck done $(date '+%F %T')" | tee -a setup-log.md
