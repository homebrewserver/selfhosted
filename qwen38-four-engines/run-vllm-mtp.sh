#!/bin/bash
# After run-mtp.sh: (1) vLLM cold-start time with an empty compile cache (seqs 32 failed cold, so seqs 16 for this timing);
# (2) vLLM with MTP speculative decoding (3 draft tokens, as LM Studio's default), full matrix.
cd ~/homelab-tests/qwen38-four-engines
while pgrep -f "run-all.sh|run-mtp.sh" >/dev/null; do sleep 20; done
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -E 'slack|chrome|code --type|gnome|nautilus|papers|xdg-desktop|gnome-shell|Xwayland' | sed 's/ --.*,/,/' | tr '\n' ';'; }
B() { /usr/bin/python3 bench.py "$@" | tail -1; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]; containers [$(docker ps --format '{{.Names}}' | tr '\n' ' ')]" >> setup-log.md; }
matrix() {
  B $1 --url $2 --model $3 --prompt short -n 512 -k 1 --rounds 5 --label $4-k1-short
  B $1 --url $2 --model $3 --prompt long -n 256 -k 1 --rounds 5 --label $4-k1-long
  for k in 4 8 16 32; do B $1 --url $2 --model $3 --prompt short -n 256 -k $k --rounds 3 --label $4-k$k-short; done
  B $1 --url $2 --model $3 --prompt long -n 256 -k 8 --rounds 3 --label $4-k8-long
}
echo "=== vllm cold + mtp run start $(date '+%F %T')" | tee -a setup-log.md
docker run --rm --entrypoint sh -v $PWD/vllm-cache:/c vllm/vllm-openai:v0.33.0 -c 'rm -rf /c/* /c/.[!.]*'
./start.sh vllm "vllm seqs16 cold (empty compile cache)" --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 16 --max-cudagraph-capture-size 16
SPEC='{"method":"mtp","num_speculative_tokens":3}'
for s in 32 16 8; do
  ./start.sh vllm "vllm MTP3 seqs$s (try 1)" --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs $s --max-cudagraph-capture-size $s --speculative-config "$SPEC" \
   || ./start.sh vllm "vllm MTP3 seqs$s (try 2, compile cache present)" --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs $s --max-cudagraph-capture-size $s --speculative-config "$SPEC" \
   && { matrix vllm http://127.0.0.1:8000 qwen38-27b vllm-mtp-s$s; docker logs bench-vllm 2>&1 | grep -iE "acceptance|SpecDecoding" | tail -3 >> setup-log.md; break; }
done
docker rm -f bench-vllm >/dev/null 2>&1
echo "=== vllm cold + mtp run done $(date '+%F %T')" | tee -a setup-log.md
