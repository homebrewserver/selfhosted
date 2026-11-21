--- 2026-11-21 21:55:31 sglang defaults: GPU before start 1044 MiB
--- 2026-11-21 23:09:27 sglang defaults: GPU before start 982 MiB
    raise RuntimeError(
RuntimeError: Not enough GPU memory for hybrid (mamba/linear-attention) state cache. Computed max_mamba_cache_size=-17 (total_rest_memory=-4.70 GB, mamba_cache_per_req=146.81 MB). Try: (1) reduce --max-running-requests, (2) increase --mem-fraction-static, (3) reduce --speculative-num-draft-tokens, or (4) use GPUs with more memory.
--- 2026-11-21 23:14:19 sglang lm-only mem0.93 ctx32k req16: GPU before start 982 MiB
    raise ValueError(
ValueError: --language-model-only does not support ['Qwen3_5ForConditionalGeneration']. Supported: ['DeepseekV4ForCausalLM', 'MuseGlimmerForConditionalGeneration', 'Cosmos3ForConditionalGeneration', 'Cosmos3EdgeForConditionalGeneration'].
--- 2026-11-21 23:14:53 sglang language-only mem0.93 ctx32k req16: GPU before start 982 MiB
    raise RuntimeError(
RuntimeError: Hybrid (mamba/linear-attention) state cache is too small to serve any requests. max_mamba_cache_size=4, mamba_ratio=5, resulting max_num_reqs=0. Try: (1) reduce --max-running-requests, (2) increase --mem-fraction-static, or (3) use GPUs with more memory.
--- 2026-11-21 23:15:53 sglang no_buffer mem0.95 ctx32k req8: GPU before start 982 MiB
AssertionError: no_buffer do not support overlap schedule. Try to set disable_overlap_schedule=True.
--- 2026-11-21 23:16:26 sglang no_buffer no-overlap mem0.95 ctx32k req8: GPU before start 982 MiB
[2026-11-21 18:20:06] OutOfMemoryError: CUDA out of memory. Tried to allocate 256.00 MiB. GPU 0 has a total capacity of 23.61 GiB of which 280.50 MiB is free. Including non-PyTorch memory, this process has 22.40 GiB memory in use. Of the allocated memory 21.95 GiB is allocated by PyTorch, and 112.16 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://docs.pytorch.org/docs/stable/notes/cuda.html#optimizing-memory-usage-with-pytorch-cuda-alloc-conf)
torch.OutOfMemoryError: CUDA out of memory. Tried to allocate 256.00 MiB. GPU 0 has a total capacity of 23.61 GiB of which 280.50 MiB is free. Including non-PyTorch memory, this process has 22.40 GiB memory in use. Of the allocated memory 21.95 GiB is allocated by PyTorch, and 112.16 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://docs.pytorch.org/docs/stable/notes/cuda.html#optimizing-memory-usage-with-pytorch-cuda-alloc-conf)
--- 2026-11-21 23:20:28 sglang no_buffer no-overlap ssm-bf16 mem0.93 ctx32k req8 cg8: GPU before start 982 MiB
sglang serve: error: ambiguous option: --cuda-graph-max-bs could match --cuda-graph-max-bs-decode, --cuda-graph-max-bs-prefill
--- 2026-11-21 23:20:57 sglang no_buffer no-overlap ssm-bf16 mem0.93 ctx32k req8 cg8: GPU before start 982 MiB
sglang no_buffer no-overlap ssm-bf16 mem0.93 ctx32k req8 cg8: ready in 83.013268453 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 13928 max_running_requests=3 max_total_num_tokens=13928 mem usage=0.00 GB mem usage=0.04 GB mem usage=0.10 GB mem usage=19.11 GB ; VRAM python3, 302 MiB;sglang::scheduler, 22238 MiB;; args: --mamba-radix-cache-strategy no_buffer --disable-overlap-schedule --mamba-ssm-dtype bfloat16 --mem-fraction-static 0.93 --context-length 32768 --max-running-requests 8 --cuda-graph-max-bs-decode 8 --cuda-graph-max-bs-prefill 8
--- 2026-11-21 23:28:05 sglang 9B defaults: GPU before start 982 MiB
sglang 9B defaults: ready in 82.590474699 s; context_len=262144 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 104133 max_running_requests=11 max_total_num_tokens=104133 mem usage=0.00 GB mem usage=0.06 GB mem usage=1.10 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 16776 MiB;; args: 
=== 9B run start 2026-11-21 23:50:35
--- 2026-11-21 23:50:41 9B vllm defaults cold (empty compile cache): GPU before start 985 MiB
9B vllm defaults cold (empty compile cache): ready in 168.365604957 s; Model loading took 8.36 GiB GPU KV cache size: 315,807 tokens Maximum concurrency for 32,768 tokens per request: 9.64x ; VRAM VLLM::EngineCore, 20854 MiB;; args: --max-model-len 32768 --enable-prompt-tokens-details
--- 2026-11-21 23:53:35 9B vllm defaults warm: GPU before start 984 MiB
9B vllm defaults warm: ready in 77.716044360 s; Model loading took 8.36 GiB GPU KV cache size: 315,332 tokens Maximum concurrency for 32,768 tokens per request: 9.62x ; VRAM VLLM::EngineCore, 20834 MiB;; args: --max-model-len 32768 --enable-prompt-tokens-details
  vllm idle power (10 samples): 24.10 24.40 24.42 23.83 23.56 24.21 24.58 23.94 23.77 24.29  W
  after vllm-k1-short: GPU apps [code (VS Code GPU process), 340 MiB;VLLM::EngineCore, 20836 MiB;]
  after vllm-k1-long: GPU apps [code (VS Code GPU process), 336 MiB;VLLM::EngineCore, 21136 MiB;]
  after vllm-k4-short: GPU apps [code (VS Code GPU process), 336 MiB;VLLM::EngineCore, 21136 MiB;]
  after vllm-k8-short: GPU apps [code (VS Code GPU process), 336 MiB;VLLM::EngineCore, 21136 MiB;]
  after vllm-k16-short: GPU apps [code (VS Code GPU process), 336 MiB;VLLM::EngineCore, 21136 MiB;]
  after vllm-k32-short: GPU apps [code (VS Code GPU process), 336 MiB;VLLM::EngineCore, 21400 MiB;]
  after vllm-k8-long: GPU apps [code (VS Code GPU process), 336 MiB;VLLM::EngineCore, 21400 MiB;]
--- 2026-11-22 00:05:55 9B sglang defaults cold (empty cache): GPU before start 980 MiB
9B sglang defaults cold (empty cache): ready in 261.092135415 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 104503 max_running_requests=11 max_total_num_tokens=104503 mem usage=0.00 GB mem usage=0.06 GB mem usage=1.10 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 16802 MiB;; args: --context-length 32768 --enable-cache-report
--- 2026-11-22 00:10:22 9B sglang defaults warm: GPU before start 980 MiB
9B sglang defaults warm: ready in 59.522500281 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 104501 max_running_requests=11 max_total_num_tokens=104501 mem usage=0.00 GB mem usage=0.06 GB mem usage=1.10 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 16802 MiB;; args: --context-length 32768 --enable-cache-report
  sglang idle power (10 samples): 24.36 24.35 24.52 24.07 23.40 23.59 24.02 23.38 23.07 23.56  W
  after sglang-k1-short: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 16802 MiB;]
  after sglang-k1-long: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 17172 MiB;]
  after sglang-k4-short: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 17172 MiB;]
  after sglang-k8-short: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 17174 MiB;]
  after sglang-k16-short: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 17174 MiB;]
  after sglang-k32-short: GPU apps [code (VS Code GPU process), 372 MiB;python3, 302 MiB;sglang::scheduler, 17174 MiB;]
  after sglang-k8-long: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 17240 MiB;]
--- 2026-11-22 00:22:45 9B sglang mem 0.9 (matched to vllm): GPU before start 980 MiB
9B sglang mem 0.9 (matched to vllm): ready in 61.721213139 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 200303 max_running_requests=22 max_total_num_tokens=200303 mem usage=0.00 GB mem usage=0.09 GB mem usage=1.10 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 22552 MiB;; args: --context-length 32768 --enable-cache-report --mem-fraction-static 0.9
  after sglang-mem09-k16-short: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 22710 MiB;]
  after sglang-mem09-k32-short: GPU apps [code (VS Code GPU process), 336 MiB;python3, 302 MiB;sglang::scheduler, 22794 MiB;]
  after sglang-mem09-k8-long: GPU apps [code (VS Code GPU process), 135 MiB;python3, 302 MiB;]
=== 9B run done 2026-11-22 00:26:28
--- 2026-11-22 00:26:46 9B sglang mem 0.9 repro of k8-long crash: GPU before start 753 MiB
9B sglang mem 0.9 repro of k8-long crash: ready in 62.948018402 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 203134 max_running_requests=23 max_total_num_tokens=203134 mem usage=0.00 GB mem usage=0.09 GB mem usage=1.11 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 22730 MiB;; args: --context-length 32768 --enable-cache-report --mem-fraction-static 0.9
  -> 0.9: CUDA OOM on the first 4k-token prefill (only ~0.4 GB free after CUDA graphs); short-prompt k16/k32 had passed
--- 2026-11-22 00:28:15 9B sglang mem 0.85: GPU before start 753 MiB
9B sglang mem 0.85: ready in 62.254001206 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 183448 max_running_requests=20 max_total_num_tokens=183448 mem usage=0.00 GB mem usage=0.09 GB mem usage=1.11 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 21580 MiB;; args: --context-length 32768 --enable-cache-report --mem-fraction-static 0.85
  -> 0.85: all long/short/prefix tests pass, 0 OOM; use 0.85 as the matched-memory setting
--- 2026-11-22 00:42:27 9B sglang mem 0.85 + mamba-ssm-dtype bfloat16: GPU before start 824 MiB
9B sglang mem 0.85 + mamba-ssm-dtype bfloat16: ready in 66.118757266 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 182578 max_running_requests=40 max_total_num_tokens=182578 mem usage=0.00 GB mem usage=0.12 GB mem usage=1.13 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 21562 MiB;; args: --context-length 32768 --enable-cache-report --mem-fraction-static 0.85 --mamba-ssm-dtype bfloat16
--- 2026-11-22 00:48:02 9B vllm + mamba-ssm-cache-dtype bfloat16: GPU before start 764 MiB
9B vllm + mamba-ssm-cache-dtype bfloat16: ready in 162.352688419 s; Model loading took 8.36 GiB GPU KV cache size: 333,098 tokens Maximum concurrency for 32,768 tokens per request: 10.17x ; VRAM VLLM::EngineCore, 20854 MiB;; args: --max-model-len 32768 --enable-prompt-tokens-details --mamba-ssm-cache-dtype bfloat16
--- 2026-11-22 00:54:39 9B sglang mem 0.85 + bf16 (k16): GPU before start 764 MiB
9B sglang mem 0.85 + bf16 (k16): ready in 65.925490956 s; context_len=32768 KV Cache is allocated. dtype: torch.bfloat16, #tokens: 183397 max_running_requests=40 max_total_num_tokens=183397 mem usage=0.00 GB mem usage=0.12 GB mem usage=1.13 GB mem usage=8.43 GB ; VRAM python3, 302 MiB;sglang::scheduler, 21620 MiB;; args: --context-length 32768 --enable-cache-report --mem-fraction-static 0.85 --mamba-ssm-dtype bfloat16
