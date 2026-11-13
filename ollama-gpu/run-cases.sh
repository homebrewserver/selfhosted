#!/bin/bash
cd ~/homelab-tests/ollama-gpu; echo "=== start $(date '+%F %T')" >> cases.log
./case.sh "1 baseline --gpus=all" "--gpus=all" --
./case.sh "2 no --gpus flag" "" --
./case.sh "3 CUDA_VISIBLE_DEVICES=-1" "--gpus=all" -e CUDA_VISIBLE_DEVICES=-1 --
./case.sh "4 num_gpu 0" "--gpus=all" -- '{"num_gpu":0}'
./case.sh "5 num_gpu 16" "--gpus=all" -- '{"num_gpu":16}'
./case.sh "6 num_ctx 262144" "--gpus=all" -- '{"num_ctx":262144}'
./case.sh "7 OLLAMA_NUM_PARALLEL=16" "--gpus=all" -e OLLAMA_NUM_PARALLEL=16 --
./case.sh "8 OLLAMA_CONTEXT_LENGTH=4096 + NUM_PARALLEL=16" "--gpus=all" -e OLLAMA_NUM_PARALLEL=16 -e OLLAMA_CONTEXT_LENGTH=4096 --
# 9. another program already holds most of the GPU memory
docker run -d --name vramhog --gpus all -v $HOME/homelab-tests/ollama-vs-llamacpp/models:/models:ro ghcr.io/ggml-org/llama.cpp:server-cuda -m /models/Qwen3.5-27B-Q4_K_M.gguf -c 32768 --fit off >/dev/null; sleep 25
echo "vramhog: $(nvidia-smi --query-compute-apps=process_name,used_memory --format=csv,noheader | grep llama-server)" >> cases.log
./case.sh "9 GPU memory held by another server" "--gpus=all" --
docker rm -f vramhog >/dev/null
./case.sh "10 fixed: --gpus=all again" "--gpus=all" --
docker rm -f gputest >/dev/null
echo "=== done $(date '+%F %T')" >> cases.log
