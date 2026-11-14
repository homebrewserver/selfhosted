# llama.cpp v1.0.0 vs build 12199

Same machine, models, prompts and method as `ollama-vs-llamacpp/` (see the main README).
Both builds are the official `ghcr.io/ggml-org/llama.cpp` CUDA server images:

- old: `server-cuda` as pulled on 8 Nov 2026, `0.9.0-dev (build 12199, commit 372dc5ca1)`
- v1.0: `server-cuda-v1.0.0-b12359-b1b770d`, `1.0.0-dev (build 12359, commit b1b770d90)`

## Files

| File | What it is |
|---|---|
| `run-v1exact.sh` | Main run, v1.0.0 vs build 12199. `base`: one request (5 rounds, interleaved) and 4 requests at once (2 sessions x 3 rounds). `spec`: MTP speculative decoding (`--spec-type draft-mtp --spec-draft-n-max 6`, 32k context, 1 slot) with and without, plus CPU only (3 rounds). |
| `results-v1exact.jsonl`, `conc-v1exact.log`, `mem-v1exact.log`, `accept-v1exact.log`, `run-v1exact.log` | Raw results of that run. `accept-v1exact.log` holds llama-server's draft acceptance lines. |
| `run-all.sh` | Earlier run the same day with `server-cuda` = build 12375 (v1.0.0 plus 16 commits) vs build 12199. Its Ollama setups were not used. |
| `results.jsonl`, `conc.log`, `mem.log`, `run.log` | Raw results of that earlier run. The `trial` rows are single trial runs of speculative decoding with `Qwen3.5-0.8B-Q4_K_M.gguf` as a separate draft model on v1.0.0 (`-md ... --spec-type draft-simple`, `--spec-draft-n-max` 3 and 8 for the 27B model). |
| `bench.py`, `conc.py`, `agg.py`, `long-context.txt` | As in `ollama-vs-llamacpp/`, with an `--out` option added. `python3 agg.py il- results-v1exact.jsonl` prints the medians. |
| `checksums.txt` | SHA-256 of every model file used. |

## Extra models

| File | Source (revision) |
|---|---|
| `Qwen3.5-9B-MTP-Q4_K_M.gguf` | `unsloth/Qwen3.5-9B-MTP-GGUF`, file `Qwen3.5-9B-Q4_K_M.gguf` (`9716a636ee4bddc3fed678220b7a33dd2a4160ae`) |
| `Qwen3.5-27B-MTP-Q4_K_M.gguf` | `unsloth/Qwen3.5-27B-MTP-GGUF`, file `Qwen3.5-27B-Q4_K_M.gguf` (`88fb5663d646bc78e1140648e8d8cb7d3e849908`) |
| `Qwen3.5-0.8B-Q4_K_M.gguf` | `unsloth/Qwen3.5-0.8B-GGUF` (`6ab461498e2023f6e3c1baea90a8f0fe38ab64d0`) |

The MTP files are renamed on download so they don't overwrite the plain GGUFs.
