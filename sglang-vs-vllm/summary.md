# SGLang v0.5.23 vs vLLM v0.33.0, Qwen3.5 9B AWQ 4-bit, RTX 3090 (run 2026-11-21/22)
Both at 32k context. vLLM: --max-model-len 32768 (gpu util 0.9 default). SGLang: --context-length 32768.

| Test | vLLM | SGLang default (0.651) | SGLang mem 0.85 |
|---|---|---|---|
| Cold start (empty cache) | 168 s | 261 s | - |
| Warm start | 78 s | 60 s | 62 s |
| KV cache tokens | 315,332 | 104,501 | 183,448 |
| Max running requests | 256 (default max-num-seqs) | 11 (Mamba cache) | 20 |
| VRAM | 20,834 MiB | 17,104 MiB | 21,882 MiB |
| Idle power | ~24 W | ~24 W | - |
| k1 short tok/s / TTFT | 114.7 / 74 ms | 121.1 / 71 ms | - |
| k1 long (4.1k) tok/s / TTFT | 112.1 / 1,013 ms | 118.4 / 977 ms | - |
| k4 short total tok/s | 396.2 | 397.2 | - |
| k8 short total tok/s | 766.0 | 792.8 | - |
| k16 short total tok/s (TTFT max) | 1,264.3 (366 ms) | 782.9 (3,093 ms) | 1,300.1 (358 ms) |
| k32 short total tok/s (TTFT max) | 1,726.6 (630 ms) | 975.8 (5,832 ms) | 1,188.2 (4,237 ms) |
| k8 long total tok/s | 191.7 | 196.8 | 196.1 |
| Prefix: cold TTFT | 1,029 ms | 1,009 ms | 1,007 ms |
| Prefix: warm TTFT | 125 ms | 32 ms | 32 ms |
| Prefix: 16 at once, TTFT med | 2,048 ms | 1,122 ms | 1,161 ms |
| Prefix: 16 at once, batch time | 3,115 ms | 1,812 ms | 1,549 ms |
| Cached prompt tokens (of ~4,120) | 3,696 | 4,096 | 4,096 |

SGLang --mem-fraction-static 0.9: k16/k32 short ran (1,301.2 / 1,194.8 tok/s) but the first 4k-token prefill hit CUDA OOM
(~0.4 GB left after CUDA graphs); reproduced twice. vLLM's 0.9 is sized after profiling activations, SGLang's is static.

## Correction and tuned run (same night)
vLLM v0.33.0 default --gpu-memory-utilization is 0.92 (EngineArgs default), not 0.9.
Both engines default to float32 Mamba SSM state (model config mamba_ssm_dtype=float32). bfloat16 halves it.

| Test | vLLM + --mamba-ssm-cache-dtype bfloat16 | SGLang 0.85 + --mamba-ssm-dtype bfloat16 |
|---|---|---|
| Start | 162 s (compile cache rebuilt for new dtype) | 66 s |
| KV tokens / max running | 333,098 / - | 182,578 / 40 |
| VRAM | 20,854 MiB | 21,864 MiB |
| k1 short tok/s / TTFT | 115.3 / 52 ms | 121.7 / 51 ms |
| k16 short total tok/s | 1,381.6 | 1,411.9 |
| k32 short total tok/s (TTFT max) | 1,931.4 (593 ms) | 1,965.7 (597 ms) |
| k8 long total tok/s | - | 198.6 |
| Prefix warm TTFT / conc16 batch | - | 33 ms / 1,474 ms |
