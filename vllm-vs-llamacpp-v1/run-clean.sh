#!/bin/bash
# Clean same-session rerun: all other containers stopped (Ollama off). vLLM with the 9 November settings,
# then llama.cpp v1.0.0 (b12359) defaults and -np 32. GPU apps are logged after every test.
cd ~/homelab-tests/vllm-vs-llamacpp-v1
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -E 'slack|chrome|code --type|gnome|nautilus|papers|xdg-desktop|gnome-shell|Xwayland' | sed 's/ --.*,/,/' | tr '\n' ';'; }
echo "=== clean run start $(date '+%F %T')" | tee -a setup-log.md
echo "running containers: $(docker ps --format '{{.Names}}' | tr '\n' ' ')" | tee -a setup-log.md
echo "VRAM before (desktop): $(nvidia-smi --query-gpu=memory.used --format=csv,noheader); GPU apps: [$(gpu_apps)]" | tee -a setup-log.md
B() { python3 bench.py "$@" | tail -1; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]; containers [$(docker ps --format '{{.Names}}' | tr '\n' ' ')]" >> setup-log.md; }
VLLM_CACHE=~/homelab-tests/vllm-vs-ollama/vllm-cache ./start-vllm.sh "clean vllm m06 seqs32" --gpu-memory-utilization 0.6 --max-num-seqs 32 || exit 1
V="vllm --url http://127.0.0.1:8000 --model qwen35-9b"
B $V --prompt short -n 512 -k 1 --rounds 5 --label clean-vllm-k1-short
B $V --prompt long -n 256 -k 1 --rounds 5 --label clean-vllm-k1-long
for k in 4 8 16 32; do B $V --prompt short -n 256 -k $k --rounds 3 --label clean-vllm-k$k-short; done
B $V --prompt long -n 256 -k 8 --rounds 3 --label clean-vllm-k8-long
docker rm -f bench-vllm >/dev/null; sleep 5
export IMG=server-cuda-v1.0.0-b12359-b1b770d
L="llamacpp --url http://127.0.0.1:8081 --model qwen35-9b"
./start-llama.sh "clean v1 llama defaults" || exit 1
B $L --prompt short -n 512 -k 1 --rounds 5 --label clean-llama-def-k1-short
B $L --prompt long -n 256 -k 1 --rounds 5 --label clean-llama-def-k1-long
for k in 4 8 16 32; do B $L --prompt short -n 256 -k $k --rounds 3 --label clean-llama-def-k$k-short; done
B $L --prompt long -n 256 -k 8 --rounds 3 --label clean-llama-def-k8-long
./start-llama.sh "clean v1 llama np32 c262144 kvu" -np 32 -c 262144 --kv-unified || exit 1
B $L --prompt short -n 512 -k 1 --rounds 5 --label clean-llama-np32-k1-short
B $L --prompt long -n 256 -k 1 --rounds 5 --label clean-llama-np32-k1-long
for k in 4 8 16 32; do B $L --prompt short -n 256 -k $k --rounds 3 --label clean-llama-np32-k$k-short; done
B $L --prompt long -n 256 -k 8 --rounds 3 --label clean-llama-np32-k8-long
docker rm -f bench-llama >/dev/null
echo "=== clean run done $(date '+%F %T')" | tee -a setup-log.md
