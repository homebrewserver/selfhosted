#!/bin/bash
cd $HOME/homelab-tests/lmstudio-vs-ollama
docker start bench-lms >/dev/null; until curl -sf 127.0.0.1:11234/v1/models >/dev/null; do sleep 0.3; done
for M in 9b 27b; do
  LM=qwen3.5-$M
  for P in 4 1; do
    docker exec bench-lms lms unload --all >/dev/null 2>&1
    docker exec bench-lms lms load $LM --parallel $P -y >/dev/null 2>&1
    python3 conc.py lms --url http://127.0.0.1:11234 --model $LM -k 4 -n 256 --rounds 3 --label cc-$M-lms-np$P
    nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader | sort -t, -k2 -n | tail -1 | sed "s/^/cc $M np$P vram /" >> loads.log
  done
done
docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' bench-lms >> loads.log
docker exec bench-lms lms unload --all >/dev/null 2>&1; sleep 3
docker stats --no-stream --format 'idle-no-model {{.Name}} {{.MemUsage}}' bench-lms >> loads.log
nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader | sed 's/^/idle-no-model gpu /' >> loads.log
