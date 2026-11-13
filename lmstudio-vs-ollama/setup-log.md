# LM Studio (llmster) on an NVIDIA GPU in Docker — what was run, 8 Nov 2026

Official image: lmstudio/llmster-preview:cpu (Docker Hub, "Technical Preview", "CPU-only support on x86").
Image facts (docker image inspect / history):
- Entrypoint /app/daemon-run.sh; ENV EXTS=llm-llama-cpu; NVIDIA_DRIVER_CAPABILITIES=compute,utility; NVIDIA_DISABLE_REQUIRE=1
- daemon-run.sh adds `--docker-compatible-platforms cuda` when EXTS contains "cuda", then runs `lms server start --port 1234`
- Healthcheck: curl http://localhost:1234/lmstudio-greeting
- Base Ubuntu 22.04; compressed size 0.43 GB

Steps:
1. docker run -d --name bench-lms --gpus all -e EXTS=llm-llama-cuda -e LMS_SERVER_HOST=0.0.0.0 \
     -p 127.0.0.1:11234:1234 -v $PWD/lms-home:/root/.lmstudio -v <models>:/models:ro lmstudio/llmster-preview:cpu
   - first try without LMS_SERVER_HOST: API answered inside container but not via published port (server bound to 127.0.0.1)
   - API ready 4.7 s after docker run (second start)
2. docker exec bench-lms lms runtime survey  -> "No GPUs detected" with the bundled CPU runtime (llama.cpp-linux-x86_64-avx2@2.41.0); nvidia-smi -L inside shows the RTX 3090
3. lms runtime get --list -> no CUDA runtime offered; with --allow-incompatible: llama.cpp-linux-x86_64-nvidia-cuda12-avx2 2.71.0 (also cuda, cuda13, vulkan, rocm)
4. lms runtime get llama.cpp-linux-x86_64-nvidia-cuda12-avx2 --allow-incompatible -y  (750.27 MB download)
5. lms runtime select llama.cpp-linux-x86_64-nvidia-cuda12-avx2@2.71.0
6. lms runtime survey -> NVIDIA GeForce RTX 3090 (CUDA, Discrete) 23.61 GiB
7. lms import /models/Qwen3.5-9B-Q4_K_M.gguf -l --user-repo unsloth/Qwen3.5-9B-GGUF -y   (symlink; same for 27B)
8. lms load qwen3.5-9b -y -> "Model loaded successfully in 2.36s" (5.29 GiB); lms ps: CONTEXT 8192, PARALLEL 4
   JIT via API: model_load_time_seconds 2.165
Runtime: llama-server child process, llama.cpp b12177 (display-data.json), version string 0.9.0-dev commit 6c01da6, CUDA libs in extensions/backends/vendor/linux-llama-cuda12-vendor-v1
Default flags: --ctx-size 8192 --n-gpu-layers 999999 --batch-size 2048 --ubatch-size 512 --threads 9 --parallel 4 --cache-type-k f16 --cache-type-v f16 --flash-attn on --kv-offload --kv-unified --load-mode mmap+mlock --jinja --ctx-checkpoints 32
lms-home size after setup: 1.5 GB (extensions 1.1 GB, bin 105 MB); files owned by root
- After docker rm + new docker run with the same lms-home mount, lms runtime ls still showed the CUDA runtime selected (runtime lives in the mounted folder).

## Removal (run 8 Nov 2026, after tests)
- docker rm -f bench-lms
- rm -rf lms-home as normal user -> "Permission denied" (files created by root in the container)
- docker run --rm --entrypoint sh -v $PWD/lms-home:/lmshome lmstudio/llmster-preview:cpu -c 'rm -rf /lmshome/* /lmshome/.[!.]*'  then rmdir lms-home -> removed (sudo rm -rf works too)
- docker rmi lmstudio/llmster-preview:cpu -> Deleted
- GGUF files in the models folder untouched (symlinks only were deleted); ~/.lmstudio on host never existed
## Concurrency (conc.py, 4 requests x 256 tokens, 3 rounds, median)
9B np4 ~239 tok/s (5744 MiB), np1 ~106 (5604 MiB); 27B np4 ~90 (16858 MiB), np1 ~38.7 (16432 MiB)
Container RAM with 27B loaded 4.796 GiB; idle no model 472.3 MiB RAM, 219 MiB GPU
