#!/bin/bash
# Full SGLang v0.5.23 vs vLLM v0.33.0 run on Qwen3.5 9B AWQ 4-bit, RTX 3090.
cd ~/homelab-tests/sglang-vs-vllm
export MODEL=cyankiwi/Qwen3.5-9B-AWQ-4bit NAME=qwen35-9b
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | tr '\n' ';'; }
B() { /usr/bin/python3 bench.py "$@" | tail -1; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]" >> setup-log.md; }
idle() { sleep 20; echo "  $1 idle power (10 samples): $(for i in $(seq 10); do nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits; sleep 1; done | tr '\n' ' ') W" | tee -a setup-log.md; }
matrix() { # engine url label
  B $1 --url $2 --model $NAME --prompt short -n 512 -k 1 --rounds 5 --label $3-k1-short
  B $1 --url $2 --model $NAME --prompt long -n 256 -k 1 --rounds 5 --label $3-k1-long
  for k in 4 8 16 32; do B $1 --url $2 --model $NAME --prompt short -n 256 -k $k --rounds 3 --label $3-k$k-short; done
  B $1 --url $2 --model $NAME --prompt long -n 256 -k 8 --rounds 3 --label $3-k8-long
}
clear_cache() { docker run --rm --entrypoint sh -v $PWD/$1:/c $2 -c 'rm -rf /c/* /c/.[!.]*'; }
V=http://127.0.0.1:8000; S=http://127.0.0.1:30000

echo "=== 9B run start $(date '+%F %T')" | tee -a setup-log.md
VA="--max-model-len 32768 --enable-prompt-tokens-details"
clear_cache vllm-cache vllm/vllm-openai:v0.33.0
./start.sh vllm "9B vllm defaults cold (empty compile cache)" $VA || exit 1
./start.sh vllm "9B vllm defaults warm" $VA || exit 1
idle vllm
matrix vllm $V vllm
/usr/bin/python3 prefix.py --url $V --model $NAME --label vllm-prefix | tail -1

SA="--context-length 32768 --enable-cache-report"
clear_cache sglang-cache lmsysorg/sglang:v0.5.23
./start.sh sglang "9B sglang defaults cold (empty cache)" $SA || exit 1
./start.sh sglang "9B sglang defaults warm" $SA || exit 1
idle sglang
matrix sglang $S sglang
/usr/bin/python3 prefix.py --url $S --model $NAME --label sglang-prefix | tail -1

./start.sh sglang "9B sglang mem 0.9 (matched to vllm)" $SA --mem-fraction-static 0.9 || exit 1
for k in 16 32; do B sglang --url $S --model $NAME --prompt short -n 256 -k $k --rounds 3 --label sglang-mem09-k$k-short; done
B sglang --url $S --model $NAME --prompt long -n 256 -k 8 --rounds 3 --label sglang-mem09-k8-long
/usr/bin/python3 prefix.py --url $S --model $NAME --label sglang-mem09-prefix | tail -1
docker rm -f bench-sglang bench-vllm >/dev/null 2>&1
echo "=== 9B run done $(date '+%F %T')" | tee -a setup-log.md
