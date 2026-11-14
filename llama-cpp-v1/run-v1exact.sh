#!/bin/bash
# llama.cpp v1.0.0 exactly (release image, build 12359) vs build 12199 (8 Nov 2026).
# Same scripts, prompts, cool-down (50 C) and medians as run-all.sh.
# Adds speculative decoding with Qwen3.5 MTP GGUFs (--spec-type draft-mtp).
D=$HOME/homelab-tests/ollama-vs-llamacpp-v1; cd $D
V1=ghcr.io/ggml-org/llama.cpp:server-cuda-v1.0.0-b12359-b1b770d
OLD=llamacpp-old:b12199
PY=/usr/bin/python3
OUT=results-v1exact.jsonl
log() { echo "$(date +%T) $*" | tee -a run-v1exact.log; }
mem() { sleep 3; echo "$(date +%T) MEM $1 $(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader | tr '\n' ' ')" >> mem-v1exact.log; }
stopall() { docker rm -f bench-llama >/dev/null 2>&1; sleep 2; }
waitllama() { until curl -sf 127.0.0.1:8081/health >/dev/null; do sleep 0.3; done; }
V="-v $HOME/homelab-tests/ollama-vs-llamacpp/models:/models:ro"

# start <image> <model file> [extra args...]
start() {
  stopall
  local img=$1 f=$2; shift 2
  docker run -d --name bench-llama --gpus all -p 127.0.0.1:8081:8080 $V $img -m /models/$f --host 0.0.0.0 --port 8080 "$@" >/dev/null
  waitllama
}
img() { [ $1 = v1 ] && echo $V1 || echo $OLD; }
bench() { $PY bench.py llama --url http://127.0.0.1:8081 --out $OUT "$@" >/dev/null 2>>err-v1exact.log; }

if [ "$1" != spec ]; then
# 1. One request, llama.cpp defaults, interleaved, 5 rounds, short + long prompt
for M in 9B 27B; do
  for r in 1 2 3 4 5; do
    for b in $([ $((r % 2)) = 1 ] && echo "v1 old" || echo "old v1"); do
      start $(img $b) Qwen3.5-$M-Q4_K_M.gguf
      bench --prompt short -n 512 --runs 1 --cool 50 --label "il-$M-$b"
      bench --prompt long -n 256 --runs 1 --cool 50 --label "il-$M-$b"
      [ $r = 1 ] && mem "il-$M-$b"
      log "il $M round $r $b done"
    done
  done
done

# 2. Four requests at once, llama.cpp defaults (4 slots), 3 rounds, two sessions each
for M in 9B 27B; do
  for b in v1 old v1 old; do
    start $(img $b) Qwen3.5-$M-Q4_K_M.gguf
    $PY conc.py llama --url http://127.0.0.1:8081 -k 4 -n 256 --rounds 3 --out $OUT --label "cc-$M-$b" >> conc-v1exact.log 2>>err-v1exact.log
    mem "cc-$M-$b"
    docker logs bench-llama 2>&1 | grep -E "n_ctx_slot" | head -1 | sed "s/^/cc-$M-$b /" >> mem-v1exact.log
    log "cc $M $b done"
  done
done

fi

if [ "$1" != base ]; then
# 3. Speculative decoding with the MTP GGUFs: 32k context, 1 slot, with and without draft-mtp
SPEC="--spec-type draft-mtp --spec-draft-n-max 6"
for M in 9B 27B; do
  setups=(v1-mtp old-mtp v1-nomtp old-nomtp)
  for r in 1 2 3 4 5; do
    for k in 0 1 2 3; do
      s=${setups[$(( (k + r) % 4 ))]}
      b=${s%%-*}
      if [[ $s == *-mtp ]]; then start $(img $b) Qwen3.5-$M-MTP-Q4_K_M.gguf -c 32768 -np 1 $SPEC
      else start $(img $b) Qwen3.5-$M-MTP-Q4_K_M.gguf -c 32768 -np 1; fi
      bench --prompt short -n 512 --runs 1 --cool 50 --label "sp-$M-$s"
      bench --prompt long -n 256 --runs 1 --cool 50 --label "sp-$M-$s"
      docker logs bench-llama 2>&1 | grep -E "draft acceptance" | sed "s/^/sp-$M-$s r$r /" >> accept-v1exact.log
      [ $r = 1 ] && mem "sp-$M-$s"
      log "sp $M round $r $s done"
    done
  done
done

# 4. CPU only, 9B, llama.cpp defaults, no GPU, interleaved, 3 rounds, 128 tokens
for r in 1 2 3; do
  for b in $([ $((r % 2)) = 1 ] && echo "v1 old" || echo "old v1"); do
    stopall
    docker run -d --name bench-llama -p 127.0.0.1:8081:8080 $V $(img $b) -m /models/Qwen3.5-9B-Q4_K_M.gguf --host 0.0.0.0 --port 8080 >/dev/null
    waitllama
    bench --prompt short -n 128 --runs 1 --label "cpu-9B-$b"
    bench --prompt long -n 128 --runs 1 --label "cpu-9B-$b"
    log "cpu round $r $b done"
  done
done
fi
stopall
log "ALL DONE ($1)"
