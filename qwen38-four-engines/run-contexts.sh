#!/bin/bash
# One request at fixed contexts per request: 32k, 96k (98,304) and the largest that fits fully on the GPU.
# Each server keeps its default number of requests at a time. Measures: short and long prompt, one request; VRAM after the run.
# Ollama 32k = its defaults (already in results.jsonl as ollama-def / ollama-mtp), vLLM 32k did not fit (setup-log line 11).
eval "$(sed -n '4,12p' run-all.sh)"
LL="http://127.0.0.1:8081"; OL="http://127.0.0.1:11435"; LM="http://127.0.0.1:11234"; VL="http://127.0.0.1:8000"
MTPF="--spec-type draft-mtp --spec-draft-n-max 3 --spec-draft-n-min 0 --spec-draft-p-min 0"
OMTP=qwen3.8:27b-mtp-q4_K_M
log() { echo "CTX $*" | tee -a setup-log.md; }
single() {  # <engine> <url> <model> <label>
  B $1 --url $2 --model $3 --prompt short -n 512 -k 1 --rounds 5 --label $4-k1-short
  B $1 --url $2 --model $3 --prompt long -n 256 -k 1 --rounds 5 --label $4-k1-long
}
ping_chat() { curl -sf -m 120 $1/v1/chat/completions -H 'Content-Type: application/json' -d '{"model":"'$2'","messages":[{"role":"user","content":"hi"}],"max_tokens":4}' >/dev/null; }

# try_<engine> <ctx> [args]: start the server at that context; succeed only if fully on the GPU and answering.
try_llama() { local n=$1; shift; ./start.sh llama "llama.cpp c$n $*" -c $n -ngl all --fit off "$@" >/dev/null 2>&1 && ping_chat $LL qwen38-27b; }
try_llamamtp() { try_llama $1 $MTPF; }
try_ollama() {
  OM=${2:-qwen38-27b} ./start.sh ollama "ollama ${2:-qwen38-27b} ctx $1" -e OLLAMA_CONTEXT_LENGTH=$1 >/dev/null 2>&1
  local ps; ps=$(docker exec bench-ollama-q38 ollama ps | tail -1); echo "  ollama ps: $ps" >> setup-log.md
  echo "$ps" | grep -q '100% GPU' && echo "$ps" | grep -q " $1 "
}
try_ollamamtp() { try_ollama $1 $OMTP; }
try_lms() {
  ./start.sh lms "lm studio c$1 gpu max" --gpu max -c $1 >/dev/null 2>&1
  docker exec bench-lms-q38 lms ps 2>/dev/null | grep -qi qwen && ping_chat $LM qwen3.8-27b
}
try_vllm() { ./start.sh vllm "vllm max-model-len $1" --max-model-len $1 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32 >/dev/null 2>&1; }

# search <name> <try-fn> <hi> <lo> <coarse step>: largest context that fits, to 4,096 tokens. Leaves that server running.
search() {
  local name=$1 fn=$2 hi=$3 lo=$4 step=$5 ok=0 n
  for ((n=hi; n>=lo; n-=step)); do if $fn $n; then ok=$n; break; fi; log "$name: $n does not fit"; done
  [ $ok = 0 ] && { log "$name: nothing fits down to $lo"; return 1; }
  local top=$((ok+step-4096)); [ $top -gt $hi ] && top=$hi
  [ $top -le $ok ] && { log "$name: max $ok"; MAX=$ok; return 0; }
  for ((n=top; n>ok; n-=4096)); do if $fn $n; then log "$name: max $n"; MAX=$n; return 0; fi; log "$name: $n does not fit"; done
  $fn $ok && { log "$name: max $ok"; MAX=$ok; }
}
run() {  # <name> <try-fn> <ctx> <engine> <url> <model> <label>
  if $2 $3; then log "$1 at $3: fits"; single $4 $5 $6 $7; else log "$1 at $3: does not fit"; fi
}

log "=== context runs start $(date '+%F %T'); desktop VRAM $(nvidia-smi --query-gpu=memory.used --format=csv,noheader)"
# 32k
run "llama.cpp" try_llama 32768 llamacpp $LL qwen38-27b llama-c32k
run "llama.cpp MTP" try_llamamtp 32768 llamacpp $LL qwen38-27b llama-mtp-c32k
run "LM Studio" try_lms 32768 lms $LM qwen3.8-27b lms-c32k
# 96k
run "llama.cpp" try_llama 98304 llamacpp $LL qwen38-27b llama-c96k
run "llama.cpp MTP" try_llamamtp 98304 llamacpp $LL qwen38-27b llama-mtp-c96k
run "Ollama" try_ollama 98304 ollama $OL qwen38-27b ollama-c96k
run "Ollama MTP" try_ollamamtp 98304 ollama $OL $OMTP ollama-mtp-c96k
run "LM Studio" try_lms 98304 lms $LM qwen3.8-27b lms-c96k
# max
search "llama.cpp" try_llama 131072 8192 16384 && single llamacpp $LL qwen38-27b llama-cmax
search "llama.cpp MTP" try_llamamtp 131072 8192 16384 && single llamacpp $LL qwen38-27b llama-mtp-cmax
search "Ollama" try_ollama 131072 8192 16384 && single ollama $OL qwen38-27b ollama-cmax
search "Ollama MTP" try_ollamamtp 131072 8192 16384 && single ollama $OL $OMTP ollama-mtp-cmax
search "LM Studio" try_lms 131072 8192 16384 && single lms $LM qwen3.8-27b lms-cmax
search "vLLM" try_vllm 32768 8192 4096 && single vllm $VL qwen38-27b vllm-cmax
docker rm -f bench-llama bench-ollama-q38 bench-vllm >/dev/null 2>&1; docker stop bench-lms-q38 >/dev/null 2>&1
log "=== context runs done $(date '+%F %T')"
