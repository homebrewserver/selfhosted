#!/bin/bash
# Stock vLLM 0.33.0 (PR #140 settings) on the tests PR #140 did not run: 64 at a time, quoting, their own setup, GSM8K.
# 8k context, 0.93, 32 seqs; quote24k at 32k context (the largest that fit in PR #140).
cd "$(dirname "$0")"
source ./common.sh
URL=http://127.0.0.1:8000; MOD=qwen38-27b
B() { /usr/bin/python3 bench.py vllm --url $URL --model $MOD "$@" | tail -1 | cut -c1-600; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]" >> setup-log.md; }
SEED=3000
echo "=== stock vllm run start $(date '+%F %T')" | tee -a setup-log.md
A="--gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32"
if ./start-vllm.sh vllm "stock vllm 8k seqs32" --max-model-len 8192 $A; then
  B --prompt short -n 512 -k 1 --rounds 5 --label vllm-k1-short
  B --prompt short -n 256 -k 32 --rounds 3 --label vllm-k32-short
  B --prompt short -n 256 -k 64 --rounds 3 --label vllm-k64-short
  B --prompt quote -n 512 -k 1 --rounds 3 --label vllm-k1-quote
  B --prompt code -n 512 -k 1 --rounds 3 --label vllm-k1-code
  B --prompt quote -n 512 -k 4 --rounds 3 --label vllm-k4-quote
  own vllm 8000 qwen38-27b
  gsm vllm 8000
fi
if ./start-vllm.sh vllm "stock vllm 32k seqs32" --max-model-len 32768 $A; then
  B --prompt quote24k -n 512 -k 1 --rounds 3 --label vllm-c32k-k1-quote24k
fi
docker rm -f bench-vllm >/dev/null 2>&1
echo "=== stock vllm run done $(date '+%F %T')" | tee -a setup-log.md
