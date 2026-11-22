# Shared helpers for run-hq.sh and run-vllm.sh
gpu_apps() { nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep -v -E 'slack|chrome|code --type|gnome|nautilus|papers|xdg-desktop|Xwayland' | tr '\n' ';'; }
own() {  # their README setup: 256 prompts, 64 at a time, 128 in / 512 out, ignore EOS (vllm bench serve)
  docker run --rm --network host --entrypoint vllm -v $HOME/hyperqwen-models:/m:ro \
    vllm/vllm-openai:v0.33.0 bench serve --host 127.0.0.1 --port ${2:-18020} --model ${3:-$MOD} --tokenizer /m/Qwen3.8-27B-W4A16-AutoRound \
    --dataset-name random --seed $((SEED+=1)) --ignore-eos --random-input-len 128 --random-output-len 512 --num-prompts 256 --max-concurrency 64 > own-$1.log 2>&1
  local tpot=$(awk '/Median TPOT/ {print $4}' own-$1.log)
  echo "OWN $1: e2e $(awk '/Output token throughput/ {print $5}' own-$1.log) tok/s, decode 64*1000/medTPOT $(/usr/bin/python3 -c "print(round(64000/$tpot))" 2>/dev/null), median TPOT $tpot ms, mean TTFT $(awk '/Mean TTFT/ {print $4}' own-$1.log) ms, failed $(awk '/Failed requests/ {print $3}' own-$1.log)" | tee -a setup-log.md
}
gsm() {  # GSM8K 200, thinking off, greedy (their quality_battery.py), against whatever serves on $2
  docker run --rm --network host --entrypoint bash -e VLLM_API=http://127.0.0.1:${2:-18020} -v $PWD/quality-data:/app/bench/quality-data \
    ghcr.io/syv-ai/hyperqwen:sha-3d6c954 -c "cd /app && (venv/bin/python -c 'import pyarrow' 2>/dev/null || venv/bin/pip -q install pyarrow) && venv/bin/python bench/quality_battery.py $1 --gsm-only" > gsm-$1.log 2>&1
  echo "GSM $1: $(grep -iE 'gsm' gsm-$1.log | tail -2 | tr '\n' ' ')" | tee -a setup-log.md
}
