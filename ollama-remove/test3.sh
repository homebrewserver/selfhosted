#!/bin/bash
C=ollama-rmtest3; V=ollama-rmtest3; P=11536
x(){ echo; echo "\$ $*"; "$@" 2>&1 | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' | tr '\r' '\n' | grep -v -E '^\s*$|pulling manifest|[0-9]+%|^\s*[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]'; }
date -Is
echo "=== start on the older image (0.30.10), GPU"
x docker run -d --gpus=all --name $C -p 127.0.0.1:$P:11434 -v $V:/root/.ollama ollama/ollama:latest
sleep 5
x docker exec $C ollama --version
x docker exec $C ollama pull qwen3:0.6b
x sh -c "docker exec $C ollama run qwen3:0.6b 'Reply with one word: ok' --think=false --verbose 2>&1 | grep -E 'eval rate'"
x docker exec $C ollama ps
x docker exec -t $C ollama ps
echo "=== update to 0.40.15: pull the new tag, recreate with the same volume"
x docker rm -f $C
x sh -c "time docker run -d --gpus=all --name $C -p 127.0.0.1:$P:11434 -v $V:/root/.ollama ollama/ollama:0.40.15"
sleep 5
x docker exec $C ollama --version
x docker exec $C ollama list
for i in 1 2 3; do x sh -c "docker exec $C ollama run qwen3:0.6b 'Reply with one word: ok' --think=false --verbose 2>&1 | grep -E 'load duration|eval rate'"; done
x docker exec $C ollama ps
x docker exec -t $C ollama ps
x curl -s http://127.0.0.1:$P/api/ps
x nvidia-smi --query-compute-apps=pid,used_memory --format=csv
x sh -c "docker logs $C 2>&1 | grep -i -E 'offload|layers|error|warn' | tail -8 | cut -c1-300"
