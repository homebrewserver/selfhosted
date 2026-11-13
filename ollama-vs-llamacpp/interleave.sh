#!/bin/bash
# Usage: interleave.sh <9b|27b> <rounds>. Rotates three setups, one measured run each per round, GPU cooled to 50 C first.
M=$1; R=$2; D=$HOME/homelab-tests/ollama-vs-llamacpp; cd $D
if [ $M = 9b ]; then F=Qwen3.5-9B-Q4_K_M.gguf; OM=qwen35-9b-hf; B=1024; else F=Qwen3.5-27B-Q4_K_M.gguf; OM=qwen35-27b-hf; B=512; fi
start() {
  docker rm -f bench-llama >/dev/null 2>&1; docker stop bench-ollama >/dev/null 2>&1
  case $1 in
    ollama) docker start bench-ollama >/dev/null; until curl -sf 127.0.0.1:11435/api/version >/dev/null; do sleep 0.3; done ;;
    llama-ollamaflags) docker run -d --name bench-llama --gpus all -p 127.0.0.1:8081:8080 -v $D/models:/models:ro ghcr.io/ggml-org/llama.cpp:server-cuda -m /models/$F --host 0.0.0.0 --port 8080 -c 32768 -np 1 --flash-attn auto -b $B -ub $B --context-shift --keep 4 >/dev/null ;;
    llama-defaults) docker run -d --name bench-llama --gpus all -p 127.0.0.1:8081:8080 -v $D/models:/models:ro ghcr.io/ggml-org/llama.cpp:server-cuda -m /models/$F --host 0.0.0.0 --port 8080 >/dev/null ;;
  esac
  [ $1 != ollama ] && until curl -sf 127.0.0.1:8081/health >/dev/null; do sleep 0.3; done
}
setups=(ollama llama-ollamaflags llama-defaults)
for r in $(seq 1 $R); do
  for k in 0 1 2; do
    s=${setups[$(( (k + r) % 3 ))]}
    start $s
    for p in short long; do
      n=512; [ $p = long ] && n=256
      if [ $s = ollama ]; then python3 bench.py ollama --url http://127.0.0.1:11435 --model $OM --ctx 0 --prompt $p -n $n --runs 1 --cool 50 --label "il-$M-$s" >/dev/null 2>&1
      else python3 bench.py llama --url http://127.0.0.1:8081 --prompt $p -n $n --runs 1 --cool 50 --label "il-$M-$s" >/dev/null 2>&1; fi
    done
    echo "round $r $s done $(date +%T)"
  done
done
docker rm -f bench-llama >/dev/null 2>&1; docker stop bench-ollama >/dev/null 2>&1
