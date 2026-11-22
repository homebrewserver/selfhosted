#!/bin/bash
# Usage: start-hq.sh <batch|single> <label> [KEY=VAL ...]
# Starts one HyperQwen mode with the repo .env plus the given overrides; logs time to ready, VRAM, KV pool, context.
M=$1; L=$2; shift 2
cd "$(dirname "$0")"/repo
cp ../env.base .env; for kv in "$@"; do echo "$kv" >> .env; done
docker rm -f bench-vllm bench-llama bench-ollama-q38 >/dev/null 2>&1; docker stop bench-lms-q38 >/dev/null 2>&1
docker compose --profile batch --profile single down >/dev/null 2>&1; sleep 5
vram() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -iE "vllm|python" | tr '\n' ';'; }
t0=$(date +%s.%N)
docker compose --profile $M up -d >/dev/null 2>&1
C=$(docker compose --profile $M ps -q $M)
until curl -sf 127.0.0.1:18020/health >/dev/null; do
  sleep 1
  [ "$(docker inspect -f '{{.RestartCount}}' $C 2>/dev/null)" -gt 0 ] 2>/dev/null && { echo "$L: RESTARTED/DIED" | tee -a ../setup-log.md; docker logs $C 2>&1 | grep -iE "error|refus" | tail -5 >> ../setup-log.md; exit 1; }
  [ $(echo "$(date +%s.%N)-$t0 > 1800" | bc) = 1 ] && { echo "$L: not ready after 30 min" | tee -a ../setup-log.md; exit 1; }
done
docker logs $C > ../server-$L.log 2>&1
echo "$L: ready in $(echo "$(date +%s.%N)-$t0" | bc | cut -c1-6) s; $(grep -o -E 'GPU KV cache size: [0-9,]+ tokens|Maximum concurrency for [0-9,]+ tokens per request: [0-9.]+x|Model loading took [0-9.]+ GiB|max_model_len=[0-9]+|max_num_seqs=[0-9]+' ../server-$L.log | sort -u | tr '\n' ' '); VRAM $(vram); total GPU $(nvidia-smi --query-gpu=memory.used --format=csv,noheader); overrides: $*" | tee -a ../setup-log.md
grep -E "^\[start_qwen\]|ignor|SPEC|DFLASH" ../server-$L.log | head -15 >> ../setup-log.md
