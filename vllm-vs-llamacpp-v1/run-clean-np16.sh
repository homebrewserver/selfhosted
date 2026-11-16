#!/bin/bash
cd ~/homelab-tests/vllm-vs-llamacpp-v1
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -E 'slack|chrome|code --type|gnome|nautilus|papers|xdg-desktop|gnome-shell|Xwayland' | sed 's/ --.*,/,/' | tr '\n' ';'; }
B() { python3 bench.py "$@" | tail -1; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]; containers [$(docker ps --format '{{.Names}}' | tr '\n' ' ')]" >> setup-log.md; }
export IMG=server-cuda-v1.0.0-b12359-b1b770d
L="llamacpp --url http://127.0.0.1:8081 --model qwen35-9b"
./start-llama.sh "clean v1 llama np16 c131072 kvu" -np 16 -c 131072 --kv-unified || exit 1
for k in 1 4 8 16 32; do B $L --prompt short -n 256 -k $k --rounds 3 --label clean-llama-np16-k$k-short; done
docker rm -f bench-llama >/dev/null
echo "=== clean np16 done $(date '+%F %T')" | tee -a setup-log.md
