#!/bin/bash
# Same llama.cpp runs as ../vllm-vs-llamacpp/run-all.sh, on the pinned v1.0.0 image (b12359),
# then a same-day check on the b12199 image the article used.
cd ~/homelab-tests/vllm-vs-llamacpp-v1
echo "=== start $(date '+%F %T')" | tee -a setup-log.md
echo "baseline VRAM before (desktop): $(nvidia-smi --query-gpu=memory.used --format=csv,noheader)" | tee -a setup-log.md
echo "ollama loaded: $(docker exec ollama ollama ps 2>&1 | tail -n +2 | wc -l) models" | tee -a setup-log.md
B() { python3 bench.py llamacpp --url http://127.0.0.1:8081 --model qwen35-9b "$@" | tail -1; }
export IMG=server-cuda-v1.0.0-b12359-b1b770d
docker run --rm --entrypoint /app/llama-server ghcr.io/ggml-org/llama.cpp:$IMG --version 2>&1 | tail -2 | tee -a setup-log.md
./start-llama.sh "v1 llama defaults"
B --prompt short -n 512 -k 1 --rounds 5 --label v1-llama-def-k1-short
B --prompt long -n 256 -k 1 --rounds 5 --label v1-llama-def-k1-long
for k in 4 8 16 32; do B --prompt short -n 256 -k $k --rounds 3 --label v1-llama-def-k$k-short; done
B --prompt long -n 256 -k 8 --rounds 3 --label v1-llama-def-k8-long
./start-llama.sh "v1 llama np32 c262144 kvu" -np 32 -c 262144 --kv-unified
B --prompt short -n 512 -k 1 --rounds 5 --label v1-llama-np32-k1-short
B --prompt long -n 256 -k 1 --rounds 5 --label v1-llama-np32-k1-long
for k in 4 8 16 32; do B --prompt short -n 256 -k $k --rounds 3 --label v1-llama-np32-k$k-short; done
B --prompt long -n 256 -k 8 --rounds 3 --label v1-llama-np32-k8-long
./start-llama.sh "v1 llama np16 c131072 kvu" -np 16 -c 131072 --kv-unified
for k in 1 4 8 16 32; do B --prompt short -n 256 -k $k --rounds 3 --label v1-llama-np16-k$k-short; done
# same-day check on the build the article tested
export IMG=server-cuda-b12199
docker pull -q ghcr.io/ggml-org/llama.cpp:$IMG | tee -a setup-log.md
./start-llama.sh "b12199 llama defaults (same day)"
B --prompt short -n 512 -k 1 --rounds 5 --label b12199-llama-def-k1-short
for k in 4 32; do B --prompt short -n 256 -k $k --rounds 3 --label b12199-llama-def-k$k-short; done
./start-llama.sh "b12199 llama np32 (same day)" -np 32 -c 262144 --kv-unified
for k in 8 32; do B --prompt short -n 256 -k $k --rounds 3 --label b12199-llama-np32-k$k-short; done
docker rm -f bench-llama >/dev/null
echo "=== done $(date '+%F %T')" | tee -a setup-log.md
