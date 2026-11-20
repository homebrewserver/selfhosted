#!/bin/bash
# Qwen3.8-27B on four engines, one RTX 3090, same prompts and request matrix for every setup.
# GGUF engines share one file (unsloth UD-Q4_K_M); vLLM uses cyankiwi AWQ INT4 (GGUF is not a vLLM format).
cd ~/homelab-tests/qwen38-four-engines
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -E 'slack|chrome|code --type|gnome|nautilus|papers|xdg-desktop|gnome-shell|Xwayland' | sed 's/ --.*,/,/' | tr '\n' ';'; }
B() { /usr/bin/python3 bench.py "$@" | tail -1; echo "  after ${@: -1}: GPU apps [$(gpu_apps)]; containers [$(docker ps --format '{{.Names}}' | tr '\n' ' ')]" >> setup-log.md; }
matrix() {  # <engine> <url> <model> <label>
  B $1 --url $2 --model $3 --prompt short -n 512 -k 1 --rounds 5 --label $4-k1-short
  B $1 --url $2 --model $3 --prompt long -n 256 -k 1 --rounds 5 --label $4-k1-long
  for k in 4 8 16 32; do B $1 --url $2 --model $3 --prompt short -n 256 -k $k --rounds 3 --label $4-k$k-short; done
  B $1 --url $2 --model $3 --prompt long -n 256 -k 8 --rounds 3 --label $4-k8-long
}
echo "=== run start $(date '+%F %T')" | tee -a setup-log.md
echo "running containers: $(docker ps --format '{{.Names}}' | tr '\n' ' ')" | tee -a setup-log.md
echo "VRAM before (desktop): $(nvidia-smi --query-gpu=memory.used --format=csv,noheader); GPU apps: [$(gpu_apps)]" | tee -a setup-log.md
LL="http://127.0.0.1:8081"; OL="http://127.0.0.1:11435"; LM="http://127.0.0.1:11234"; VL="http://127.0.0.1:8000"

# llama.cpp defaults ran in the first pass (11:51); kept. Restarted from here at the np32 setup.
# ./start.sh llama "llama.cpp defaults" && matrix llamacpp $LL qwen38-27b llama-def
# -c 49152 with auto-fit put layers on the CPU (11.5 tok/s); --fit off forces all layers on the GPU, 49152 then fails to load, 32768 fits.
./start.sh llama "llama.cpp np32 c32768 kvu fit-off" -np 32 -c 32768 --kv-unified -ngl all --fit off && matrix llamacpp $LL qwen38-27b llama-np32
./start.sh ollama "ollama defaults" && matrix ollama $OL qwen38-27b ollama-def
./start.sh ollama "ollama NUM_PARALLEL=4 CONTEXT_LENGTH=8192" -e OLLAMA_NUM_PARALLEL=4 -e OLLAMA_CONTEXT_LENGTH=8192 && matrix ollama $OL qwen38-27b ollama-np4
./start.sh lms "lm studio defaults" && matrix lms $LM qwen3.8-27b lms-def
./start.sh vllm "vllm cold (empty compile cache)" --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32
./start.sh vllm "vllm warm (compile cache present)" --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32 && matrix vllm $VL qwen38-27b vllm

docker rm -f bench-llama bench-ollama-q38 bench-vllm >/dev/null 2>&1; docker stop bench-lms-q38 >/dev/null 2>&1
echo "=== run done $(date '+%F %T')" | tee -a setup-log.md
