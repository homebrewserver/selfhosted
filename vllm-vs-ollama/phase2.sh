#!/bin/bash
cd ~/homelab-tests/vllm-vs-ollama
while pgrep -f 'run-engine.sh ollama' >/dev/null; do sleep 5; done
echo "=== phase2 start $(date +%T)"
./idle-power.sh ollama-default-loaded
./start-ollama.sh "ollama NUM_PARALLEL=16" -e OLLAMA_NUM_PARALLEL=16
for k in 1 4 8 16 32; do python3 bench.py ollama --url http://127.0.0.1:11435 --model qwen35-9b-hf --prompt short -n 256 -k $k --rounds 3 --label ollama-np16-k$k-short | tail -1; done
docker exec bench-ollama ollama ps | tee -a setup-log.md
docker rm -f bench-ollama >/dev/null; sleep 5
echo "no server idle: $(nvidia-smi --query-gpu=power.draw,clocks.sm,temperature.gpu,memory.used --format=csv,noheader)" | tee -a idle-power.log
./start-vllm.sh "vllm default for idle power"
python3 bench.py vllm --url http://127.0.0.1:8000 --model qwen35-9b -n 256 -k 1 --rounds 1 --label vllm-idlewarm >/dev/null
./idle-power.sh vllm-default-loaded
echo "=== phase2 done $(date +%T)"
