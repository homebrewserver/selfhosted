#!/bin/bash
# Usage: interleave.sh <9b|27b> <rounds>. Rotates three setups, one measured run per prompt per round, GPU cooled to 50 C first.
M=$1; R=$2; cd $HOME/homelab-tests/lmstudio-vs-ollama
if [ $M = 9b ]; then OM=qwen35-9b-hf; LM=qwen3.5-9b; else OM=qwen35-27b-hf; LM=qwen3.5-27b; fi
start() {
  case $1 in
    ollama) docker stop bench-lms >/dev/null 2>&1; docker start bench-ollama >/dev/null
            until curl -sf 127.0.0.1:11435/api/version >/dev/null; do sleep 0.3; done ;;
    lms-*)  docker start bench-lms >/dev/null
            until curl -sf 127.0.0.1:11234/v1/models >/dev/null; do sleep 0.3; done
            docker exec bench-lms lms unload --all >/dev/null 2>&1
            if [ $1 = lms-defaults ]; then flags=""; else flags="-c 32768 --parallel 1"; fi
            t0=$(date +%s.%N); docker exec bench-lms lms load $LM $flags -y >/dev/null 2>&1; t1=$(date +%s.%N)
            echo "$M $1 lms-load-s $(python3 -c "print(round($t1-$t0,2))")" >> loads.log
            docker exec bench-lms lms ps 2>/dev/null | grep -i qwen >> loads.log
            nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader | sort -t, -k2 -n | tail -1 | sed "s/^/$M $1 vram /" >> loads.log ;;
  esac
}
setups=(lms-defaults lms-ctx32k)
for r in $(seq 1 $R); do
  for k in 0 1; do
    s=${setups[$(( (k + r) % 2 ))]}
    start $s
    for p in short long; do
      n=512; [ $p = long ] && n=256
      if [ $s = ollama ]; then python3 bench.py ollama --url http://127.0.0.1:11435 --model $OM --ctx 0 --prompt $p -n $n --runs 1 --cool 50 --label "il-$M-$s" >/dev/null 2>>err.log
      else python3 bench.py lms --url http://127.0.0.1:11234 --model $LM --prompt $p -n $n --runs 1 --cool 50 --label "il-$M-$s" >/dev/null 2>>err.log; fi
    done
    [ $s = ollama ] && nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader | sort -t, -k2 -n | tail -1 | sed "s/^/$M ollama vram /" >> loads.log
    echo "round $r $s done $(date +%T)"
  done
done
docker stop bench-lms >/dev/null 2>&1
