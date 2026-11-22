# HyperQwen vs stock vLLM 0.33.0, Qwen3.8-27B on one RTX 3090

Scripts and raw results for the homebrewserver.club article "HyperQwen vs vLLM: Qwen3.8-27B on one RTX 3090" (22 November 2026).

- **Hardware:** RTX 3090 24 GB at the default 350 W limit, Ryzen 9 5900X, Fedora 44, Docker. The desktop held about 0.5-0.7 GiB of the GPU.
- **HyperQwen:** https://github.com/syv-ai/HyperQwen at commit `3d6c954`, image `ghcr.io/syv-ai/hyperqwen:sha-3d6c954` (vLLM 0.33.0). Clone it into `repo/` next to these scripts.
- **Stock vLLM:** `vllm/vllm-openai:v0.33.0` with `cyankiwi/Qwen3.8-27B-AWQ-INT4`, `--max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32` (32k for the 24k quote test), the settings of `../qwen38-four-engines`.

## Files

| File | What it is |
|---|---|
| `setup.sh`, `prepare.sh` | pull the image, run HyperQwen's one-time model preparation (the first `prepare` exited 137 and was resumed with `prepare.sh`) |
| `env.base` | the repo's `.env.example` with `MODELS_DIR` set; `start-hq.sh` copies it to `repo/.env` and appends the overrides |
| `start-hq.sh`, `start-vllm.sh` | start one server, log time to ready, cache size and GPU memory to `setup-log.md` |
| `run-hq.sh`, `run-vllm.sh` | the request matrix per setup, HyperQwen's own benchmark (`own`) and GSM8K (`gsm`), see `common.sh` |
| `bench.py` | the client: same prompts and timing as `../qwen38-four-engines/bench.py`, plus the quote, code-edit and 24k-quote prompts and the 40-character copy check |
| `long-context.txt`, `doc-24k.txt`, `code-source.py` | prompt sources |
| `results.jsonl` | one line per test: medians plus every round |
| `results-crashed-batch-094.jsonl` | batch mode at its default `GPU_UTIL=0.94` before it ran out of memory |
| `setup-log.md` | start-up times, cache sizes, GPU memory, failures and the setting changes |
| `own-*.log`, `gsm-*.log`, `server-*.log` | `vllm bench serve` output, GSM8K output, HyperQwen server logs |

## Setting changes from the defaults

- Batch mode: `GPU_UTIL=0.92` (0.94 ran out of GPU memory on the first 4,121-token prompt).
- Single-user with `DFLASH_TOKENS=15`: `KV_MEM=4800000000 MAX_LEN=45056` (the default 5.26 GB cache ran out of GPU memory after the first test; `GPU_UTIL` is ignored in single-user mode).
- Single-user mode: none.

Five stock vLLM results in the article (one long request; 4, 8 and 16 at once; 8 long at once) come from `../qwen38-four-engines/results.jsonl`.
