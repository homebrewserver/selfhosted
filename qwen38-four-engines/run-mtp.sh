#!/bin/bash
# Follow-up after run-all.sh: LM Studio's defaults turned out to include MTP speculative decoding
# (--spec-type draft-mtp --spec-draft-n-max 3). Run llama.cpp with the same flags as LM Studio, with and without MTP,
# so the gap can be split into "MTP" and "engine".
cd ~/homelab-tests/qwen38-four-engines
while pgrep -f run-all.sh >/dev/null; do sleep 20; done
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -E 'slack|chrome|code --type|gnome|nautilus|papers|xdg-desktop|gnome-shell|Xwayland' | sed 's/ --.*,/,/' | tr '\n' ';'; }
B() { /usr/bin/python3 bench.py "$@" | tail -1; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]; containers [$(docker ps --format '{{.Names}}' | tr '\n' ' ')]" >> setup-log.md; }
matrix() {
  B $1 --url $2 --model $3 --prompt short -n 512 -k 1 --rounds 5 --label $4-k1-short
  B $1 --url $2 --model $3 --prompt long -n 256 -k 1 --rounds 5 --label $4-k1-long
  for k in 4 8 16 32; do B $1 --url $2 --model $3 --prompt short -n 256 -k $k --rounds 3 --label $4-k$k-short; done
  B $1 --url $2 --model $3 --prompt long -n 256 -k 8 --rounds 3 --label $4-k8-long
}
echo "=== mtp run start $(date '+%F %T')" | tee -a setup-log.md
LL="http://127.0.0.1:8081"
LMSFLAGS="-c 8192 -np 4 --kv-unified -b 2048 -ub 512 -ngl all --fit off"
./start.sh llama "llama.cpp LM Studio flags + MTP" $LMSFLAGS --spec-type draft-mtp --spec-draft-n-max 3 --spec-draft-n-min 0 --spec-draft-p-min 0 && matrix llamacpp $LL qwen38-27b llama-lmsflags-mtp
docker logs bench-llama 2>&1 | grep "draft acceptance" | tail -3 >> setup-log.md
./start.sh llama "llama.cpp LM Studio flags, no MTP" $LMSFLAGS && matrix llamacpp $LL qwen38-27b llama-lmsflags
docker rm -f bench-llama >/dev/null 2>&1
echo "=== mtp run done $(date '+%F %T')" | tee -a setup-log.md
