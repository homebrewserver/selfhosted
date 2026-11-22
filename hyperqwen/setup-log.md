## setup 2026-11-22 00:41:18, repo commit 3d6c954
- image pull: 1483 s; size 16.75 GB
- prepare (download + requantize): 3171 s, exit 137; models dir 11G
- prepare rerun (resume download + requantize): 3502 s, exit 0; models dir 26G
hq-batch-smoke: RESTARTED/DIED
(EngineCore pid=1145) ERROR 11-21 21:59:47 [core.py:1664] ValueError: Free memory on device cuda:0 (0.97/23.61 GiB) on startup is less than desired GPU memory utilization (0.94, 22.19 GiB). Decrease GPU memory utilization or reduce GPU memory used by other processes.
    raise ValueError(
ValueError: Free memory on device cuda:0 (0.97/23.61 GiB) on startup is less than desired GPU memory utilization (0.94, 22.19 GiB). Decrease GPU memory utilization or reduce GPU memory used by other processes.
    raise RuntimeError(
RuntimeError: Engine core initialization failed. See root cause above. Failed core proc(s): {}
=== run start 2026-11-22 04:18:10; power limit 350.00 W
hq-batch: ready in 381.93 s; GPU KV cache size: 215,482 tokens Maximum concurrency for 150,000 tokens per request: 1.44x max_num_seqs=64 Model loading took 14.17 GiB ; VRAM VLLM::EngineCore, 23318 MiB;; total GPU 23857 MiB; overrides: 
  PASS  kvarn-v2-runner-0.33.0.patch applied (SPEC=dflash2 + CTX=huge available)
== single-user DFlash2 drafter (optional, SPEC=dflash2)
resolve_config: WARNING: SPEC=dflash2 is set but batch mode ignores it (SPEC is a single-user control)
  after hq-batch-k1-short: GPU apps [VLLM::EngineCore, 23326 MiB;]
  after hq-batch-k1-long: GPU apps [VLLM::EngineCore, 23538 MiB;]
  after hq-batch-k4-short: GPU apps [VLLM::EngineCore, 23538 MiB;]
  after hq-batch-k8-short: GPU apps []
  after hq-batch-k16-short: GPU apps []
  after hq-batch-k32-short: GPU apps []
  after hq-batch-k64-short: GPU apps []
  after hq-batch-k8-long: GPU apps []
  after hq-batch-k1-quote: GPU apps []
  after hq-batch-k1-code: GPU apps []
  after hq-batch-k4-quote: GPU apps []
OWN hq-batch: e2e 0.00 tok/s, decode 64*1000/medTPOT , median TPOT 0.00 ms, mean TTFT 0.00 ms, failed during
256
GSM hq-batch:     with ThreadPoolExecutor(32) as ex: res = list(ex.map(gsm_one, rows))   File "/app/bench/quality_battery.py", line 121, in gsm_one 
- hq-batch at its default GPU_UTIL 0.94 ran out of GPU memory on the first 4,121-token prompt (marlin_gemm, 142 MiB free); rerun with GPU_UTIL=0.92. Crashed results kept in results-crashed-batch-094.jsonl
=== run start 2026-11-22 04:28:53; power limit 350.00 W
hq-single-b: ready in 133.42 s; ; VRAM VLLM::EngineCore, 22816 MiB;; total GPU 23311 MiB; overrides: 
hq-batch: ready in 91.525 s; GPU KV cache size: 204,060 tokens Maximum concurrency for 150,000 tokens per request: 1.36x max_num_seqs=64 Model loading took 14.17 GiB ; VRAM VLLM::EngineCore, 22816 MiB;; total GPU 23311 MiB; overrides: GPU_UTIL=0.92
  PASS  kvarn-v2-runner-0.33.0.patch applied (SPEC=dflash2 + CTX=huge available)
== single-user DFlash2 drafter (optional, SPEC=dflash2)
resolve_config: WARNING: SPEC=dflash2 is set but batch mode ignores it (SPEC is a single-user control)
  after hq-batch-k1-short: GPU apps [VLLM::EngineCore, 22844 MiB;]
  after hq-batch-k1-long: GPU apps [VLLM::EngineCore, 23204 MiB;]
  after hq-batch-k4-short: GPU apps [VLLM::EngineCore, 23204 MiB;]
  after hq-batch-k8-short: GPU apps [VLLM::EngineCore, 23204 MiB;]
  after hq-batch-k16-short: GPU apps [VLLM::EngineCore, 23204 MiB;]
  after hq-batch-k32-short: GPU apps [VLLM::EngineCore, 23364 MiB;]
  after hq-batch-k64-short: GPU apps [VLLM::EngineCore, 23364 MiB;]
  after hq-batch-k8-long: GPU apps [VLLM::EngineCore, 23364 MiB;]
  after hq-batch-k1-quote: GPU apps [VLLM::EngineCore, 23364 MiB;]
  after hq-batch-k1-code: GPU apps [VLLM::EngineCore, 23364 MiB;]
  after hq-batch-k4-quote: GPU apps [VLLM::EngineCore, 23364 MiB;]
OWN hq-batch: e2e 1010.42 tok/s, decode 64*1000/medTPOT 1098, median TPOT 58.31 ms, mean TTFT 2654.18 ms, failed 0
GSM hq-batch: hq-batch GSM8K n=200 acc=0.950 mean_tokens=383 101s 
hq-single-b: ready in 208.31 s; GPU KV cache size: 67,312 tokens Maximum concurrency for 65,536 tokens per request: 1.03x max_num_seqs=8 Model loading took 14.93 GiB ; VRAM VLLM::EngineCore, 22756 MiB;; total GPU 23251 MiB; overrides: 
  PASS  kvarn-v2-runner-0.33.0.patch applied (SPEC=dflash2 + CTX=huge available)
== single-user DFlash2 drafter (optional, SPEC=dflash2)
[effective-config] CTX=fast SPEC=dflash2 FA2_FP8KV=0 (default)
[start_qwen] note: the pool holds about 5 to 6 resident requests on ~1k-token prompts and 1 at MAX_LEN=65536 -- 380 pages of 448 tokens, and each request reserves 60 of them for recurrent state at DFLASH_TOKENS=7 before any context. MAX_SEQS=8 admits more than that and the rest queue.
  after hq-single-b-k1-short: GPU apps [VLLM::EngineCore, 22766 MiB;]
  after hq-single-b-k1-long: GPU apps [VLLM::EngineCore, 23246 MiB;]
  after hq-single-b-k4-short: GPU apps [VLLM::EngineCore, 23246 MiB;]
  after hq-single-b-k8-short: GPU apps [VLLM::EngineCore, 23246 MiB;]
  after hq-single-b-k16-short: GPU apps [VLLM::EngineCore, 23246 MiB;]
  after hq-single-b-k32-short: GPU apps [VLLM::EngineCore, 23246 MiB;]
  after hq-single-b-k64-short: GPU apps [VLLM::EngineCore, 23250 MiB;]
  after hq-single-b-k8-long: GPU apps [VLLM::EngineCore, 23310 MiB;]
  after hq-single-b-k1-quote: GPU apps [VLLM::EngineCore, 23310 MiB;]
  after hq-single-b-k1-code: GPU apps [VLLM::EngineCore, 23310 MiB;]
  after hq-single-b-k4-quote: GPU apps [VLLM::EngineCore, 23310 MiB;]
  after hq-single-b-k1-quote24k: GPU apps [VLLM::EngineCore, 23310 MiB;]
OWN hq-single-b: e2e 309.42 tok/s, decode 64*1000/medTPOT 3096, median TPOT 20.67 ms, mean TTFT 82581.62 ms, failed 0
GSM hq-single-b: hq-single-b GSM8K n=200 acc=0.960 mean_tokens=379 170s 
hq-single-c: ready in 214.51 s; GPU KV cache size: 57,506 tokens Maximum concurrency for 57,344 tokens per request: 1.00x max_num_seqs=4 Model loading took 14.93 GiB ; VRAM VLLM::EngineCore, 23230 MiB;; total GPU 23725 MiB; overrides: DFLASH_TOKENS=15
  PASS  kvarn-v2-runner-0.33.0.patch applied (SPEC=dflash2 + CTX=huge available)
== single-user DFlash2 drafter (optional, SPEC=dflash2)
[effective-config] CTX=fast SPEC=dflash2 FA2_FP8KV=0 (default)
[start_qwen] note: the pool holds about 3 resident requests on ~1k-token prompts and 1 at MAX_LEN=57344 -- 354 pages of 480 tokens, and each request reserves 102 of them for recurrent state at DFLASH_TOKENS=15 before any context. MAX_SEQS=4 admits more than that and the rest queue.
  after hq-single-c-k1-short: GPU apps [VLLM::EngineCore, 23240 MiB;]
  after hq-single-c-k1-long: GPU apps [VLLM::EngineCore, 23652 MiB;]
  after hq-single-c-k4-short: GPU apps [VLLM::EngineCore, 23652 MiB;]
  after hq-single-c-k8-short: GPU apps [VLLM::EngineCore, 23652 MiB;]
  after hq-single-c-k16-short: GPU apps []
  after hq-single-c-k32-short: GPU apps []
  after hq-single-c-k64-short: GPU apps []
  after hq-single-c-k8-long: GPU apps []
  after hq-single-c-k1-quote: GPU apps []
  after hq-single-c-k1-code: GPU apps []
  after hq-single-c-k4-quote: GPU apps []
  after hq-single-c-k1-quote24k: GPU apps []
OWN hq-single-c: e2e 0.00 tok/s, decode 64*1000/medTPOT , median TPOT 0.00 ms, mean TTFT 0.00 ms, failed during
256
GSM hq-single-c:     with ThreadPoolExecutor(32) as ex: res = list(ex.map(gsm_one, rows))   File "/app/bench/quality_battery.py", line 121, in gsm_one 
- hq-single-c (DFLASH_TOKENS=15) at default GPU_UTIL 0.93 ran out of GPU memory after the first test (28 MiB free); its results before the rerun are discarded; rerun with GPU_UTIL=0.91 after stock vLLM
=== run done 2026-11-22 05:41:59
=== stock vllm run start 2026-11-22 05:41:59
stock vllm 8k seqs32: ready in 219.031477073 s; Model loading took 18.28 GiB GPU KV cache size: 30,840 tokens Maximum concurrency for 8,192 tokens per request: 3.76x ; VRAM VLLM::EngineCore, 22480 MiB;; args: --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32
  after vllm-k1-short: GPU apps [VLLM::EngineCore, 22508 MiB;]
  after vllm-k32-short: GPU apps [VLLM::EngineCore, 22822 MiB;]
  after vllm-k64-short: GPU apps [VLLM::EngineCore, 22822 MiB;]
  after vllm-k1-quote: GPU apps [VLLM::EngineCore, 22982 MiB;]
  after vllm-k1-code: GPU apps [VLLM::EngineCore, 22982 MiB;]
  after vllm-k4-quote: GPU apps [VLLM::EngineCore, 23102 MiB;]
OWN vllm: e2e 417.97 tok/s, decode 64*1000/medTPOT 2036, median TPOT 31.44 ms, mean TTFT 52254.64 ms, failed 0
GSM vllm: vllm GSM8K n=200 acc=0.960 mean_tokens=374 182s 
stock vllm 32k seqs32: ready in 41.327541498 s; Model loading took 18.28 GiB GPU KV cache size: 43,690 tokens Maximum concurrency for 32,768 tokens per request: 1.33x ; VRAM VLLM::EngineCore, 22480 MiB;; args: --max-model-len 32768 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32
  after vllm-c32k-k1-quote24k: GPU apps [VLLM::EngineCore, 22994 MiB;]
=== stock vllm run done 2026-11-22 06:13:54
=== run start 2026-11-22 06:14:07; power limit 350.00 W
hq-single-c: ready in 175.70 s; GPU KV cache size: 57,506 tokens Maximum concurrency for 57,344 tokens per request: 1.00x max_num_seqs=4 Model loading took 14.93 GiB ; VRAM VLLM::EngineCore, 23228 MiB;; total GPU 23721 MiB; overrides: DFLASH_TOKENS=15 GPU_UTIL=0.91
  PASS  kvarn-v2-runner-0.33.0.patch applied (SPEC=dflash2 + CTX=huge available)
== single-user DFlash2 drafter (optional, SPEC=dflash2)
[effective-config] CTX=fast SPEC=dflash2 FA2_FP8KV=0 (default)
[start_qwen] note: the pool holds about 3 resident requests on ~1k-token prompts and 1 at MAX_LEN=57344 -- 354 pages of 480 tokens, and each request reserves 102 of them for recurrent state at DFLASH_TOKENS=15 before any context. MAX_SEQS=4 admits more than that and the rest queue.
- hq-single-c: GPU_UTIL is ignored in single-user mode (the KV pool is pinned at KV_MEM=5261334938 bytes); rerun with KV_MEM=4800000000 and MAX_LEN=49152, as the launcher suggests when something else uses the card
=== run start 2026-11-22 06:17:32; power limit 350.00 W
hq-single-c: RESTARTED/DIED
(EngineCore pid=1030) ERROR 11-22 01:21:55 [core.py:1664] ValueError: To serve at least one request with the model's max seq len (49152), (4.66 GiB KV cache is needed, which is larger than the available KV cache memory (4.46 GiB). Based on the available memory, the estimated maximum model length is 46080. Try increasing `gpu_memory_utilization` (which also controls CPU memory on the CPU backend) or decreasing `max_model_len` when initializing the engine. See https://docs.vllm.ai/en/latest/configuration/conserving_memory/ for more details.
    raise ValueError(
ValueError: To serve at least one request with the model's max seq len (49152), (4.66 GiB KV cache is needed, which is larger than the available KV cache memory (4.46 GiB). Based on the available memory, the estimated maximum model length is 46080. Try increasing `gpu_memory_utilization` (which also controls CPU memory on the CPU backend) or decreasing `max_model_len` when initializing the engine. See https://docs.vllm.ai/en/latest/configuration/conserving_memory/ for more details.
    raise RuntimeError(
RuntimeError: Engine core initialization failed. See root cause above. Failed core proc(s): {}
=== run done 2026-11-22 06:22:31
- 49152 needs 4.66 GiB of KV, 4.8e9 bytes gives 4.46 GiB (max 46080); rerun at MAX_LEN=45056
=== run start 2026-11-22 06:22:32; power limit 350.00 W
hq-single-c: ready in 214.52 s; GPU KV cache size: 45,656 tokens Maximum concurrency for 45,056 tokens per request: 1.01x max_num_seqs=4 Model loading took 14.93 GiB ; VRAM VLLM::EngineCore, 22490 MiB;; total GPU 22983 MiB; overrides: DFLASH_TOKENS=15 KV_MEM=4800000000 MAX_LEN=45056
  PASS  kvarn-v2-runner-0.33.0.patch applied (SPEC=dflash2 + CTX=huge available)
== single-user DFlash2 drafter (optional, SPEC=dflash2)
[effective-config] CTX=fast SPEC=dflash2 FA2_FP8KV=0 (default)
[start_qwen] note: the pool holds about 2 resident requests on ~1k-token prompts and 1 at MAX_LEN=45056 -- 305 pages of 480 tokens, and each request reserves 102 of them for recurrent state at DFLASH_TOKENS=15 before any context. MAX_SEQS=4 admits more than that and the rest queue.
  after hq-single-c-k1-short: GPU apps [VLLM::EngineCore, 22500 MiB;]
  after hq-single-c-k1-long: GPU apps [VLLM::EngineCore, 23020 MiB;]
  after hq-single-c-k4-short: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k8-short: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k16-short: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k32-short: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k64-short: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k8-long: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k1-quote: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k1-code: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k4-quote: GPU apps [VLLM::EngineCore, 23022 MiB;]
  after hq-single-c-k1-quote24k: GPU apps [VLLM::EngineCore, 23022 MiB;]
OWN hq-single-c: e2e 201.75 tok/s, decode 64*1000/medTPOT 4575, median TPOT 13.99 ms, mean TTFT 134937.05 ms, failed 0
GSM hq-single-c: hq-single-c GSM8K n=200 acc=0.960 mean_tokens=381 232s 
=== run done 2026-11-22 07:08:31
