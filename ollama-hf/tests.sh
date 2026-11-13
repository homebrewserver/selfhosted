#!/bin/bash
cd ~/homelab-tests/ollama-hf; L=hf.log
X(){ echo "\$ $*" | tee -a $L; docker exec hftest "$@" 2>&1 | tr '\r' '\n' | grep -v -E '^\s*$|[0-9]+%' | tail -40 | tee -a $L; }
W(){ echo "--- write $1" | tee -a $L; cat > gguf/$1; cat gguf/$1 | tee -a $L; }
GEN(){ curl -s 127.0.0.1:11437/api/generate -d "{\"model\":\"$1\",\"prompt\":\"$2\",\"stream\":false,\"options\":{\"num_predict\":${3:-200}}}" | python3 -c 'import sys,json;d=json.load(sys.stdin);print("ERR",d["error"]) if "error" in d else print("thinking chars:",len(d.get("thinking") or ""),"| tok/s %.1f"%(d["eval_count"]/(d["eval_duration"]/1e9)),"| load %.1f s"%(d["load_duration"]/1e9),"| response:",repr(d["response"][:120]))' | tee -a $L; }
PS(){ docker exec hftest ollama ps | tee -a $L; echo "nvidia-smi: $(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep ollama)" | tee -a $L; }
echo "### $(date '+%F %T') show hf model" >> $L
X ollama show hf.co/unsloth/Qwen3.5-9B-GGUF:Q4_K_M
X ollama show --modelfile hf.co/unsloth/Qwen3.5-9B-GGUF:Q4_K_M
curl -s 127.0.0.1:11437/api/show -d '{"model":"hf.co/unsloth/Qwen3.5-9B-GGUF:Q4_K_M"}' | python3 -c 'import sys,json;d=json.load(sys.stdin);print({k:d[k] for k in d if k not in ("modelfile","template","model_info","tensors","license")}); print("template head:",(d.get("template") or "")[:200])' | tee -a $L
echo "### default run (thinking default?)" >> $L
GEN hf.co/unsloth/Qwen3.5-9B-GGUF:Q4_K_M "What is 17*23?" 400; PS
echo "### local import" >> $L
du -sh ollama-data | tee -a $L
printf 'FROM /gguf/Qwen3.5-9B-Q4_K_M.gguf\n' | W Modelfile.plain
s=$(date +%s.%N); X ollama create qwen35-local -f /gguf/Modelfile.plain; echo "create took $(echo "$(date +%s.%N)-$s"|bc) s" | tee -a $L
du -sh ollama-data | tee -a $L; ls -la ollama-data/models/blobs | awk '{print $5,$9}' | tee -a $L
X ollama show qwen35-local
curl -s 127.0.0.1:11437/api/show -d '{"model":"qwen35-local"}' | python3 -c 'import sys,json;d=json.load(sys.stdin);print({k:d[k] for k in d if k not in ("modelfile","template","model_info","tensors","license")})' | tee -a $L
GEN qwen35-local "What is 17*23?" 400
echo "### full modelfile" >> $L
cat <<'EOF' | W Modelfile.tuned
FROM /gguf/Qwen3.5-9B-Q4_K_M.gguf
PARAMETER num_ctx 65536
PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
PARAMETER presence_penalty 1.5
SYSTEM You are a concise assistant for a home server. Answer in plain sentences.
EOF
X ollama create qwen35-tuned -f /gguf/Modelfile.tuned
X ollama show --modelfile qwen35-tuned
X ollama show qwen35-tuned
GEN qwen35-tuned "What is a reverse proxy? /no_think" 200; PS
echo "### rejected lines" >> $L
for line in "ADAPTER /gguf/none.gguf" "PARAMETER mirostat 1" "PARAMETER num_gpu 20" "PARAMETER typical_p 0.9" "PARAMETER num_thread 8" "PARAMETER repeat_penalty 1.1" "PARAMETER min_p 0.05"; do printf 'FROM qwen35-local\n%s\n' "$line" | W Modelfile.t; X ollama create qwen35-t -f /gguf/Modelfile.t; done
echo "### num_gpu via modelfile effect" >> $L
printf 'FROM qwen35-local\nPARAMETER num_gpu 20\n' | W Modelfile.g; X ollama create qwen35-g -f /gguf/Modelfile.g; GEN qwen35-g "Hi" 50; PS; docker exec hftest ollama stop qwen35-g
X ollama create -q q4_K_M qwen35-q -f /gguf/Modelfile.plain
echo "### num_ctx sweep" >> $L
for c in 4096 8192 32768 65536 131072 262144; do docker exec hftest ollama stop qwen35-local >/dev/null 2>&1; sleep 3; echo "num_ctx $c" | tee -a $L; curl -s 127.0.0.1:11437/api/generate -d "{\"model\":\"qwen35-local\",\"prompt\":\"Write three sentences about bicycles.\",\"stream\":false,\"think\":false,\"options\":{\"num_ctx\":$c,\"num_predict\":128,\"temperature\":0}}" | python3 -c 'import sys,json;d=json.load(sys.stdin);print("tok/s %.1f"%(d["eval_count"]/(d["eval_duration"]/1e9)))' | tee -a $L; PS; done
echo "### remove" >> $L
du -sh ollama-data | tee -a $L
for m in qwen35-t qwen35-g qwen35-tuned qwen35-local; do docker exec hftest ollama rm $m >/dev/null 2>&1; done; du -sh ollama-data | tee -a $L
X ollama rm hf.co/unsloth/Qwen3.5-9B-GGUF:Q4_K_M; du -sh ollama-data | tee -a $L; ls ollama-data/models/blobs | tee -a $L
echo "### done $(date '+%F %T')" >> $L
