# selfhosted

Test scripts, raw results and setup notes for a series of local LLM runner tests
(Ollama, llama.cpp, LM Studio, vLLM, OpenClaw) on one consumer GPU.

The code here is exactly as it was run. Model files, caches, VM images and
credentials are not included.

## Hardware and software

- GPU: NVIDIA RTX 3090 24 GB, driver 615.78.08
- CPU: AMD Ryzen 9 5900X
- OS: Fedora 44, Docker 29.9.2
- Ollama: `ollama/ollama:0.40.15` (bundles llama.cpp b12111)
- llama.cpp: `ghcr.io/ggml-org/llama.cpp:server-cuda`, build 12199 (CUDA 12.8.1) at test time
- vLLM: `vllm/vllm-openai:v0.33.0`
- LM Studio: `lmstudio/llmster-preview:cpu` with the CUDA 12 runtime 2.71.0 (llama.cpp b12177)

## Models

| File | Source | SHA-256 |
|---|---|---|
| `Qwen3.5-9B-Q4_K_M.gguf` | `unsloth/Qwen3.5-9B-GGUF` | `03b74727a860a56338e042c4420bb3f04b2fec5734175f4cb9fa853daf52b7e8` |
| `Qwen3.5-27B-Q4_K_M.gguf` | `unsloth/Qwen3.5-27B-GGUF` | `84b5f7f112156d63836a01a69dc3f11a6ba63b10a23b8ca7a7efaf52d5a2d806` |
| Qwen3.5 9B AWQ 4-bit (vLLM) | `cyankiwi/Qwen3.5-9B-AWQ-4bit` | not pinned |

The GGUF files go in `ollama-vs-llamacpp/models/`; the other tests mount them from there.

## Folders

| Folder | Test |
|---|---|
| `ollama-vs-llamacpp/` | Ollama vs llama.cpp: single-request speed, long prompt, 4 parallel requests, GPU memory |
| `llama-cpp-v1/` | llama.cpp v1.0.0 vs build 12199: one request, 4 parallel requests, MTP speculative decoding, CPU only |
| `lmstudio-vs-ollama/` | LM Studio vs Ollama, same models and prompts |
| `vllm-vs-ollama/` | vLLM vs Ollama: speed, time to first token, 1–32 concurrent requests, start-up time, idle power |
| `vllm-vs-llamacpp/` | vLLM vs llama.cpp `llama-server` at the same concurrency levels |
| `vllm-vs-llamacpp-v1/` | The llama.cpp runs from `vllm-vs-llamacpp/` repeated on v1.0.0 (`server-cuda-v1.0.0-b12359-b1b770d`), plus a same-day check on `server-cuda-b12199` |
| `qwen38-four-engines/` | Ollama 0.40.15, llama.cpp v1.0.0, LM Studio (runtime 2.79.0) and vLLM 0.33.0 with Qwen3.8-27B: 1 to 32 requests, 8 long prompts at once, MTP speculative decoding, GPU memory, start-up. Results summary in `summary.md` |
| `ollama-gpu/` | Ollama "not using GPU" cases: missing `--gpus`, `num_gpu`, large `num_ctx`, memory held by another server |
| `ollama-hf/` | Running Hugging Face GGUF models in Ollama, with and without a Modelfile |
| `ollama-remove/` | Uninstalling Ollama and deleting models |
| `lmstudio-install/` | Installing LM Studio as a headless server, on the host and in a cloud-init VM (uses LM Studio's official installer, not included) |
| `openclaw-notes/` | OpenClaw in Docker with Ollama and a Discord bot: setup log |
| `openclaw-lifecycle/` | OpenClaw setup, start-up and lifecycle tests in Docker and in a native Ubuntu VM |

Each benchmark folder has its own `bench.py` (and `conc.py` where used), the runner
script, the long prompt (`long-context.txt`), the raw `results.jsonl` and a setup log.

## Method

- Every prompt starts with a random request id, so no server can reuse a cached prompt.
- One warm-up request before measuring; it is not recorded.
- Temperature 0, seed 42, thinking off.
- Short prompt: about 70 tokens in, 512 out. Long prompt: about 4,100 tokens in, 256 out.
- Generation speed comes from each server's own timing fields; time to first token is
  measured by the client.
- The GPU cools to 50 °C before each measured run, and setups are rotated round by round
  (`interleave.sh`), so heat and order do not favour one tool.
- Reported numbers are medians over the runs in `results.jsonl`.

## Running

Clone this repo to `~/homelab-tests`; the shell scripts use that path:

```bash
git clone https://github.com/homebrewserver/selfhosted.git ~/homelab-tests
```

Then, for example, Ollama vs llama.cpp:

```bash
cd ~/homelab-tests/ollama-vs-llamacpp
# put the GGUF files in models/, check them with: sha256sum -c checksums.txt
./interleave.sh 9b 5
```

The `bench-ollama` container, the Ollama models (`ollama create` from the `Modelfile.*`)
and other one-off setup steps are described in each folder's setup log rather than scripted.

## Known gaps

- The llama.cpp image tag is not pinned in the older scripts; use build 12199 to match.
  `llama-cpp-v1/` and `vllm-vs-llamacpp-v1/` pin their tags.
- The vLLM AWQ model has no pinned revision.
- Paths assume `~/homelab-tests`.
- `bench.py` differs slightly between folders.

## License

MIT, see `LICENSE`.
