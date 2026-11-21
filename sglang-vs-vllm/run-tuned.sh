#!/bin/bash
# Follow-up runs after run-all.sh (22 Nov 2026), run by hand in this order.
cd ~/homelab-tests/sglang-vs-vllm
export MODEL=cyankiwi/Qwen3.5-9B-AWQ-4bit NAME=qwen35-9b
S=http://127.0.0.1:30000; V=http://127.0.0.1:8000
B() { /usr/bin/python3 bench.py "$@" | tail -1; }

# 1. SGLang at 0.9: the first 4,120-token prompt ran out of memory (reproduces the k8-long failure in run-all.log).
./start.sh sglang "9B sglang mem 0.9 repro of k8-long crash" --context-length 32768 --enable-cache-report --mem-fraction-static 0.9
B sglang --url $S --model $NAME --prompt long -n 256 -k 8 --rounds 3 --label sglang-mem09-k8-long-repro
docker logs bench-sglang 2>&1 | grep -E "OutOfMemoryError|capped"

# 2. SGLang at 0.85: all tests pass.
./start.sh sglang "9B sglang mem 0.85" --context-length 32768 --enable-cache-report --mem-fraction-static 0.85
B sglang --url $S --model $NAME --prompt long -n 256 -k 8 --rounds 3 --label sglang-mem085-k8-long
B sglang --url $S --model $NAME --prompt short -n 256 -k 16 --rounds 3 --label sglang-mem085-k16-short
B sglang --url $S --model $NAME --prompt short -n 256 -k 32 --rounds 3 --label sglang-mem085-k32-short
/usr/bin/python3 prefix.py --url $S --model $NAME --label sglang-mem085-prefix | tail -1

# 3. SGLang at 0.85 with bfloat16 Mamba state (cap 40 requests).
./start.sh sglang "9B sglang mem 0.85 + mamba-ssm-dtype bfloat16" --context-length 32768 --enable-cache-report --mem-fraction-static 0.85 --mamba-ssm-dtype bfloat16
B sglang --url $S --model $NAME --prompt short -n 256 -k 32 --rounds 3 --label sglang-mem085-bf16-k32-short
B sglang --url $S --model $NAME --prompt long -n 256 -k 8 --rounds 3 --label sglang-mem085-bf16-k8-long
B sglang --url $S --model $NAME --prompt short -n 512 -k 1 --rounds 3 --label sglang-mem085-bf16-k1-short

# 4. vLLM with bfloat16 Mamba state, for a fair comparison.
./start.sh vllm "9B vllm + mamba-ssm-cache-dtype bfloat16" --max-model-len 32768 --enable-prompt-tokens-details --mamba-ssm-cache-dtype bfloat16
B vllm --url $V --model $NAME --prompt short -n 256 -k 32 --rounds 3 --label vllm-bf16-k32-short
B vllm --url $V --model $NAME --prompt short -n 256 -k 16 --rounds 3 --label vllm-bf16-k16-short
B vllm --url $V --model $NAME --prompt short -n 512 -k 1 --rounds 3 --label vllm-bf16-k1-short

# 5. SGLang 0.85 + bfloat16: 16 requests and the prefix test.
./start.sh sglang "9B sglang mem 0.85 + bf16 (k16)" --context-length 32768 --enable-cache-report --mem-fraction-static 0.85 --mamba-ssm-dtype bfloat16
B sglang --url $S --model $NAME --prompt short -n 256 -k 16 --rounds 3 --label sglang-mem085-bf16-k16-short
/usr/bin/python3 prefix.py --url $S --model $NAME --label sglang-mem085-bf16-prefix | tail -1
docker rm -f bench-sglang bench-vllm
