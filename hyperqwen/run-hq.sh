#!/bin/bash
# HyperQwen (vLLM 0.33.0 fork) on the RTX 3090, Qwen3.8-27B. Same harness and prompts as qwen38-four-engines (PR #140),
# plus 64 at a time, two prompt-quoting tests, their own 64 x 128-in/512-out run, and GSM8K (200 questions).
cd "$(dirname "$0")"
URL=http://127.0.0.1:18020; MOD=qwen3.8-27b
source ./common.sh
B() { /usr/bin/python3 bench.py vllm --url $URL --model $MOD "$@" | tail -1 | cut -c1-600; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]" >> setup-log.md; }
matrix() {  # <label prefix>
  B --prompt short -n 512 -k 1 --rounds 5 --label $1-k1-short
  B --prompt long -n 256 -k 1 --rounds 5 --label $1-k1-long
  for k in 4 8 16 32 64; do B --prompt short -n 256 -k $k --rounds 3 --label $1-k$k-short; done
  B --prompt long -n 256 -k 8 --rounds 3 --label $1-k8-long
  B --prompt quote -n 512 -k 1 --rounds 3 --label $1-k1-quote
  B --prompt code -n 512 -k 1 --rounds 3 --label $1-k1-code
  B --prompt quote -n 512 -k 4 --rounds 3 --label $1-k4-quote
}
SEED=2000
echo "=== run start $(date '+%F %T'); power limit $(nvidia-smi --query-gpu=power.limit --format=csv,noheader)" | tee -a setup-log.md
for step in ${STEPS:-batch single-b single-c}; do
  case $step in
    batch)    ./start-hq.sh batch hq-batch GPU_UTIL=0.92 && { matrix hq-batch; own hq-batch; gsm hq-batch; } ;;
    single-b) ./start-hq.sh single hq-single-b && { matrix hq-single-b; B --prompt quote24k -n 512 -k 1 --rounds 3 --label hq-single-b-k1-quote24k; own hq-single-b; gsm hq-single-b; } ;;
    single-c) ./start-hq.sh single hq-single-c DFLASH_TOKENS=15 KV_MEM=4800000000 MAX_LEN=45056 && { matrix hq-single-c; B --prompt quote24k -n 512 -k 1 --rounds 3 --label hq-single-c-k1-quote24k; own hq-single-c; gsm hq-single-c; } ;;
  esac
done
(cd repo && docker compose --profile batch --profile single down >/dev/null 2>&1)
echo "=== run done $(date '+%F %T')" | tee -a setup-log.md
