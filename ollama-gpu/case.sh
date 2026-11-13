#!/bin/bash
# Usage: case.sh <label> <docker-gpu-args> [-e ENV ...] -- [api options json]
# Starts ollama 0.40.15 with the given args, loads qwen3.5:9b with a 128-token answer, records evidence.
L=$1; shift; GPU=$1; shift
ENVS=(); while [ "$1" != "--" ] && [ -n "$1" ]; do ENVS+=("$1"); shift; done; shift
OPTS=${1:-'{}'}
D=$HOME/homelab-tests/ollama-gpu
docker rm -f gputest >/dev/null 2>&1; sleep 2
echo "===== $L" | tee -a $D/cases.log
echo "docker run $GPU ${ENVS[*]}  options=$OPTS" | tee -a $D/cases.log
docker run -d --name gputest $GPU "${ENVS[@]}" -p 127.0.0.1:11436:11434 -v $D/ollama-data:/root/.ollama ollama/ollama:0.40.15 >/dev/null 2>>$D/cases.log || { echo "docker run failed" | tee -a $D/cases.log; exit 0; }
until curl -sf 127.0.0.1:11436/api/version >/dev/null; do sleep 0.3; done
R=$(curl -s 127.0.0.1:11436/api/generate -d "{\"model\":\"qwen3.5:9b\",\"prompt\":\"Write three sentences about bicycles.\",\"stream\":false,\"think\":false,\"options\":$(echo $OPTS | python3 -c 'import sys,json;o=json.load(sys.stdin);o.update({"num_predict":128,"temperature":0,"seed":1});print(json.dumps(o))')}")
echo "$R" | python3 -c 'import sys,json;d=json.load(sys.stdin);print("error:",d["error"]) if "error" in d else print("eval tok/s %.1f, load %.1f s, tokens %d"%(d["eval_count"]/(d["eval_duration"]/1e9),d["load_duration"]/1e9,d["eval_count"]))' | tee -a $D/cases.log
docker exec gputest ollama ps | tee -a $D/cases.log
curl -s 127.0.0.1:11436/api/ps | python3 -c 'import sys,json;[print("api/ps size",m["size"],"size_vram",m["size_vram"],"context",m.get("context_length")) for m in json.load(sys.stdin)["models"]]' | tee -a $D/cases.log
echo "nvidia-smi: $(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -iE 'chrome|code|slack' | tr '\n' ';')" | tee -a $D/cases.log
docker exec gputest nvidia-smi -L 2>&1 | head -2 | sed 's/^/in container: /' | tee -a $D/cases.log
docker logs gputest 2>&1 | grep -E 'inference compute|offloaded|default_num_ctx|vram-based|no compatible GPUs|unable to load|user overrode|not correctly discovered|library=|llama-server --model' | cut -c1-400 | tee -a $D/cases.log
docker logs gputest > $D/logs/$(echo $L | tr ' /=' '___').log 2>&1
