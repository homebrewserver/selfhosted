=== start 2026-11-16 14:48:01
baseline VRAM before (desktop): 2913 MiB
ollama loaded: 0 models
version: 1.0.0-dev (build 12359, commit b1b770d90)
built with GNU 14.2.0 for Linux x86_64
v1 llama defaults: ready in 5.204111728 s; VRAM /app/llama-server, 13920 MiB; args: 
0.04.248.595 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 262144, kv_unified = 'true'
v1 llama np32 c262144 kvu: ready in 2.861570818 s; VRAM /app/llama-server, 15452 MiB; args: -np 32 -c 262144 --kv-unified
0.01.817.668 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 262144, kv_unified = 'true'
v1 llama np16 c131072 kvu: ready in 2.916377834 s; VRAM /app/llama-server, 10334 MiB; args: -np 16 -c 131072 --kv-unified
0.02.172.016 I srv    load_model: initializing, n_slots = 16, n_ctx_slot = 131072, kv_unified = 'true'
ghcr.io/ggml-org/llama.cpp:server-cuda-b12199
b12199 llama defaults (same day): ready in 2.677929259 s; VRAM /app/llama-server, 13920 MiB; args: 
0.01.988.770 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 262144, kv_unified = 'true'
b12199 llama np32 (same day): ready in 2.585079101 s; VRAM /app/llama-server, 15452 MiB; args: -np 32 -c 262144 --kv-unified
0.01.756.314 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 262144, kv_unified = 'true'
=== done 2026-11-16 15:31:25
=== vllm start 2026-11-16 16:09:12
GPU free at 16:15:58; VRAM before (desktop): 3995 MiB
vllm m06 seqs32: ready in 82.348025366 s; GPU KV cache size: 116,825 tokens Maximum concurrency for 32,768 tokens per request: 3.57x ; VRAM VLLM::EngineCore, 13246 MiB
  ollama loaded after: [qwen3-embedding:4b ]
  ollama loaded after: []
  ollama loaded after: [qwen3-embedding:4b ]
  ollama loaded after: [qwen3-embedding:4b ]
  ollama loaded after: [qwen3-embedding:4b ]
  ollama loaded after: [qwen3-embedding:4b ]
  ollama loaded after: [qwen3-embedding:4b ]
v1 llama defaults (after vllm): ready in 12.071659892 s; VRAM /app/llama-server, 13812 MiB; args: 
0.10.669.608 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 258816, kv_unified = 'true'
  ollama loaded after: [qwen3-embedding:4b ]
  ollama loaded after: [qwen3-embedding:4b ]
v1 llama np32 (after vllm): ready in 10.805423491 s; VRAM /app/llama-server, 13666 MiB; args: -np 32 -c 262144 --kv-unified
0.09.784.362 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 262144, kv_unified = 'true'
=== stopped 16:48:03: Ollama (qwen3-embedding:4b) was loaded by another client during this run, so the v1day-* results are not used. All other containers were stopped before the next run.
=== clean run start 2026-11-16 18:49:10
VRAM before (desktop): 2540 MiB; GPU apps: []
clean vllm m06 seqs32: ready in 71.610431645 s; GPU KV cache size: 110,176 tokens Maximum concurrency for 32,768 tokens per request: 3.36x ; VRAM VLLM::EngineCore, 13014 MiB
  after clean-vllm-k1-short: GPU apps [VLLM::EngineCore, 13040 MiB;]
  after clean-vllm-k1-long: GPU apps [VLLM::EngineCore, 13320 MiB;]
  after clean-vllm-k4-short: GPU apps [VLLM::EngineCore, 13320 MiB;]
  after clean-vllm-k8-short: GPU apps [VLLM::EngineCore, 13320 MiB;]
  after clean-vllm-k16-short: GPU apps [VLLM::EngineCore, 13320 MiB;]
  after clean-vllm-k32-short: GPU apps [VLLM::EngineCore, 13678 MiB;]
  after clean-vllm-k8-long: GPU apps [VLLM::EngineCore, 13678 MiB;]
clean v1 llama defaults: ready in 4.627814692 s; VRAM /app/llama-server, 13920 MiB; args: 
0.03.551.678 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 262144, kv_unified = 'true'
  after clean-llama-def-k1-short: GPU apps [/app/llama-server, 13930 MiB;]
  after clean-llama-def-k1-long: GPU apps [/app/llama-server, 13932 MiB;]
  after clean-llama-def-k4-short: GPU apps [/app/llama-server, 13932 MiB;]
  after clean-llama-def-k8-short: GPU apps [/app/llama-server, 13932 MiB;]
  after clean-llama-def-k16-short: GPU apps [/app/llama-server, 13932 MiB;]
  after clean-llama-def-k32-short: GPU apps [/app/llama-server, 13932 MiB;]
  after clean-llama-def-k8-long: GPU apps [/app/llama-server, 13934 MiB;]
clean v1 llama np32 c262144 kvu: ready in 2.336138482 s; VRAM /app/llama-server, 15452 MiB; args: -np 32 -c 262144 --kv-unified
0.01.931.526 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 262144, kv_unified = 'true'
  after clean-llama-np32-k1-short: GPU apps [/app/llama-server, 15476 MiB;]
  after clean-llama-np32-k1-long: GPU apps [/app/llama-server, 15476 MiB;]
  after clean-llama-np32-k4-short: GPU apps [/app/llama-server, 15478 MiB;]
  after clean-llama-np32-k8-short: GPU apps [/app/llama-server, 15478 MiB;]
  after clean-llama-np32-k16-short: GPU apps [/app/llama-server, 15478 MiB;]
  after clean-llama-np32-k32-short: GPU apps [/app/llama-server, 15480 MiB;]
  after clean-llama-np32-k8-long: GPU apps [/app/llama-server, 15480 MiB;]
=== clean run done 2026-11-16 19:25:41
clean v1 llama np16 c131072 kvu: ready in 2.473012109 s; VRAM /app/llama-server, 10334 MiB; args: -np 16 -c 131072 --kv-unified
0.01.862.974 I srv    load_model: initializing, n_slots = 16, n_ctx_slot = 131072, kv_unified = 'true'
  after clean-llama-np16-k1-short: GPU apps [/app/llama-server, 10356 MiB;]
=== reboot during the np16 run (only clean-llama-np16-k1 had finished; dropped). Containers restarted by the reboot were stopped again. np16 rerun:
clean v1 llama np16 c131072 kvu: ready in 4.787767190 s; VRAM /app/llama-server, 10334 MiB; args: -np 16 -c 131072 --kv-unified
0.03.762.663 I srv    load_model: initializing, n_slots = 16, n_ctx_slot = 131072, kv_unified = 'true'
  after clean-llama-np16-k1-short: GPU apps [/app/llama-server, 10346 MiB;]
  after clean-llama-np16-k4-short: GPU apps [/app/llama-server, 10348 MiB;]
  after clean-llama-np16-k8-short: GPU apps [/app/llama-server, 10348 MiB;]
  after clean-llama-np16-k16-short: GPU apps [/app/llama-server, 10348 MiB;]
  after clean-llama-np16-k32-short: GPU apps [/app/llama-server, 10348 MiB;]
=== clean np16 done 2026-11-16 19:40:38
