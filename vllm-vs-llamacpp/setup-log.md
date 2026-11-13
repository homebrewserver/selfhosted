=== start 2026-11-09 06:22:32
baseline VRAM before (desktop): 2751 MiB
llama defaults: ready in 6.653596414 s; VRAM /app/llama-server, 13920 MiB; args: 
0.05.642.007 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 262144, kv_unified = 'true'
llama np32 c262144 kvu: ready in 2.733791339 s; VRAM /app/llama-server, 15452 MiB; args: -np 32 -c 262144 --kv-unified
0.01.944.419 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 262144, kv_unified = 'true'
llama np16 c131072 kvu: ready in 2.328440969 s; VRAM /app/llama-server, 10334 MiB; args: -np 16 -c 131072 --kv-unified
0.01.687.573 I srv    load_model: initializing, n_slots = 16, n_ctx_slot = 131072, kv_unified = 'true'
vllm same-day check: DIED
(EngineCore pid=186) ERROR 11-09 01:59:13 [core.py:1584] ValueError: Free memory on device cuda:0 (21.58/23.61 GiB) on startup is less than desired GPU memory utilization (0.92, 21.72 GiB). Decrease GPU memory utilization or reduce GPU memory used by other processes.
    raise ValueError(
ValueError: Free memory on device cuda:0 (21.58/23.61 GiB) on startup is less than desired GPU memory utilization (0.92, 21.72 GiB). Decrease GPU memory utilization or reduce GPU memory used by other processes.
    raise RuntimeError(
RuntimeError: Engine core initialization failed. See root cause above. Failed core proc(s): {'EngineCore': 1}
=== done 2026-11-09 06:59:21
=== recheck start 2026-11-09 06:59:53; desktop VRAM 1754 MiB
llama defaults (recheck): ready in 2.461312415 s; VRAM /app/llama-server, 13920 MiB; args: 
0.01.882.932 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 262144, kv_unified = 'true'
vllm mem0.6 seqs32 same-day: ready in 64.089711427 s; GPU KV cache size: 110,176 tokens Maximum concurrency for 32,768 tokens per request: 3.36x ; VRAM VLLM::EngineCore, 13014 MiB
=== recheck done 2026-11-09 07:14:58
