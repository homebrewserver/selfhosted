# Qwen3.8-27B on four engines, RTX 3090 24 GB, 20 Nov 2026 (medians from results.jsonl)

tok/s for 1 request = per-request generation speed; 4/8/16/32 req = total tok/s across all requests (short prompt, 256 tokens out).
TTFT in ms. GGUF engines: unsloth UD-Q4_K_M (same file). vLLM: cyankiwi AWQ INT4.

| Setup | 1 req tok/s | 1 req TTFT | long 1 req tok/s | long TTFT | 4 req | 8 req | 16 req | 32 req | 32 req TTFT med | 8 long |
|---|---|---|---|---|---|---|---|---|---|---|
| llama.cpp v1.0 defaults (4 slots, 97.8k ctx) | 43.8 | 269 | 43.0 | 3018 | 122.1 | 121.4 | 119.8 | 117.9 | 30844 | 48.3 |
| llama.cpp v1.0 -np 32 -c 32768 --kv-unified --fit off | 43.7 | 278 | 42.9 | 3034 | 121.4 | 194.8 | 264.2 | 295.4 | 6586 | failed |
| llama.cpp v1.0 with LM Studio flags, no MTP | 43.7 | 260 | 43.0 | 3020 | 122.5 | 120.5 | 120.0 | 118.2 | 30858 | failed |
| llama.cpp v1.0 with LM Studio flags + MTP | 70.9 | 270 | 78.1 | 3102 | 164.7 | 164.4 | 162.2 | 160.1 | 19764 | crash |
| Ollama 0.40.15 defaults (1 slot, 32k) | 43.5 | 392 | 42.8 | 3261 | 41.0 | 40.6 | 39.7 | 38.1 | 100565 | 26.6 |
| Ollama NUM_PARALLEL=4, CONTEXT_LENGTH=8192 | 43.5 | 381 | 42.8 | 3247 | 100.6 | 100.3 | 98.4 | 96.3 | 37638 | 41.3 |
| Ollama 0.40.15, library qwen3.8:27b-mtp-q4_K_M (own Q4_K_M file, draft-mtp n_max 4, 1 slot, 32k) | 57.1 | 429 | 65.0 | 3626 | 53.2 | 51.9 | 51.3 | 49.3 | 79379 | 31.6 |
| LM Studio defaults (8k shared, 4 slots, MTP on) | 65.8 | 267 | 76.6 | 3790 | 143.2 | 143.0 | 142.5 | 138.9 | 26381 | failed |
| vLLM 0.33.0 AWQ, 8k, 32 seqs | 43.5 | 115 | 42.7 | 3349 | 150.6 | 287.9 | 282.8 | 345.8 | 9276 | 47.5 |

Start-up: llama.cpp ready 3.7-5.7 s; LM Studio lms load 4.4 s; Ollama first answer 86-88 s (load_duration 31-32 s), MTP download 60.5 s (load 31.45 s); vLLM warm 46.4 s, cold (empty compile cache, seqs 16) 155.1 s.
VRAM (server process): llama.cpp defaults 22,030 MiB; np32 22,238; LMS flags 16,342 (18,678 with MTP); Ollama 17,456 / 17,882 / 20,010 (MTP download); LM Studio 18,678; vLLM 22,480.
Not run / failed: vLLM 32k context (KV max ~11.7k tokens); vLLM MTP (draft model OOM, 2.37 GiB more needed); llama.cpp MTP crash (common.cpp:1634) on slot reuse after the 32-request test. Details in setup-log.md.

Ollama MTP download: draft acceptance 41% over the run (36,026 of 86,860 drafted tokens), mean accepted length 2.65; longest first-token wait at 32 requests 162.2 s.
