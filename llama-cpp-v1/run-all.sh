#!/bin/bash
# Re-run of the 8 Nov 2026 Ollama vs llama.cpp test with llama.cpp v1.0 (build 12375).
# Same scripts, models, prompts, cool-down (50 C) and medians as the original.
# Adds the old build 12199 image as a same-day control.
D=$HOME/homelab-tests/ollama-vs-llamacpp-v1; cd $D
NEW=ghcr.io/ggml-org/llama.cpp:server-cuda   # build 12375 (v1.0.0-dev, commit 9d25e0014)
OLD=llamacpp-old:b12199
PY=/usr/bin/python3
log() { echo "$(date +%T) $*" | tee -a run.log; }
mem() { sleep 3; echo "$(date +%T) MEM $1 $(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader | tr '\n' ' ')" >> mem.log; }

stopall() { docker rm -f bench-llama >/dev/null 2>&1; docker stop bench-ollama bench-ollama-np4 >/dev/null 2>&1; sleep 2; }
waitllama() { until curl -sf 127.0.0.1:8081/health >/dev/null; do sleep 0.3; done; }
waitollama() { until curl -sf 127.0.0.1:11435/api/version >/dev/null; do sleep 0.3; done; }

# start <setup> <model 9b|27b> [cpu]
start() {
  stopall
  local F B G="--gpus all"
  if [ $2 = 9b ]; then F=Qwen3.5-9B-Q4_K_M.gguf; B=1024; else F=Qwen3.5-27B-Q4_K_M.gguf; B=512; fi
  [ "$3" = cpu ] && G=""
  V="-v $HOME/homelab-tests/ollama-vs-llamacpp/models:/models:ro"
  case $1 in
    ollama) docker start bench-ollama >/dev/null; waitollama ;;
    ollama-np4) docker start bench-ollama-np4 >/dev/null; waitollama ;;
    new-ollamaflags) docker run -d --name bench-llama $G -p 127.0.0.1:8081:8080 $V $NEW -m /models/$F --host 0.0.0.0 --port 8080 -c 32768 -np 1 --flash-attn auto -b $B -ub $B --context-shift --keep 4 >/dev/null; waitllama ;;
    old-ollamaflags) docker run -d --name bench-llama $G -p 127.0.0.1:8081:8080 $V $OLD -m /models/$F --host 0.0.0.0 --port 8080 -c 32768 -np 1 --flash-attn auto -b $B -ub $B --context-shift --keep 4 >/dev/null; waitllama ;;
    new-defaults) docker run -d --name bench-llama $G -p 127.0.0.1:8081:8080 $V $NEW -m /models/$F --host 0.0.0.0 --port 8080 >/dev/null; waitllama ;;
    old-defaults) docker run -d --name bench-llama $G -p 127.0.0.1:8081:8080 $V $OLD -m /models/$F --host 0.0.0.0 --port 8080 >/dev/null; waitllama ;;
  esac
}

om() { [ $1 = 9b ] && echo qwen35-9b-hf || echo qwen35-27b-hf; }

# 1. Single-request speed, interleaved, 5 rounds, short + long prompt
for M in 9b 27b; do
  setups=(new-ollamaflags old-ollamaflags new-defaults old-defaults)
  for r in 1 2 3 4 5; do
    for k in 0 1 2 3; do
      s=${setups[$(( (k + r) % 4 ))]}
      start $s $M
      for p in short long; do
        n=512; [ $p = long ] && n=256
        if [[ $s == ollama ]]; then $PY bench.py ollama --url http://127.0.0.1:11435 --model $(om $M) --ctx 0 --prompt $p -n $n --runs 1 --cool 50 --label "il-$M-$s" >/dev/null 2>>err.log
        else $PY bench.py llama --url http://127.0.0.1:8081 --prompt $p -n $n --runs 1 --cool 50 --label "il-$M-$s" >/dev/null 2>>err.log; fi
      done
      [ $r = 1 ] && mem "il-$M-$s"
      log "il $M round $r $s done"
    done
  done
done

# 2. Four requests at once, 3 rounds each
for M in 9b 27b; do
  for s in new-defaults old-defaults new-defaults old-defaults; do
    start $s $M
    if [[ $s == ollama* ]]; then $PY conc.py ollama --url http://127.0.0.1:11435 --model $(om $M) -k 4 -n 256 --rounds 3 --label "cc-$M-$s" >> conc.log 2>>err.log
    else $PY conc.py llama --url http://127.0.0.1:8081 -k 4 -n 256 --rounds 3 --label "cc-$M-$s" >> conc.log 2>>err.log; fi
    mem "cc-$M-$s"
    [[ $s == *defaults ]] && docker logs bench-llama 2>&1 | grep -E "n_ctx_slot|n_slots|n_ctx  " | head -4 >> mem.log
    log "cc $M $s done"
  done
done

# 3. CPU only, 9B, llama.cpp defaults new vs old, 3 runs
for s in new-defaults old-defaults; do
  start $s 9b cpu
  for p in short long; do
    $PY bench.py llama --url http://127.0.0.1:8081 --prompt $p -n 128 --runs 3 --label "cpu-9b-$s" >/dev/null 2>>err.log
  done
  docker logs bench-llama 2>&1 | grep -m2 -E "n_threads|system_info" >> mem.log
  log "cpu $s done"
done
stopall
log ALL DONE
