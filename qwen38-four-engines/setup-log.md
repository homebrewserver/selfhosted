# Qwen3.8-27B on four engines, 2026-11-20
GPU: NVIDIA GeForce RTX 3090, 615.78.08; RAM 62 GB
GGUF: unsloth/Qwen3.8-27B-GGUF Qwen3.8-27B-UD-Q4_K_M.gguf (16,564,259,744 bytes), sha256 in checksums.txt
AWQ: cyankiwi/Qwen3.8-27B-AWQ-INT4 revision e3a700906e6a73ba4290b1873dc2ba8198527ab5 (compressed-tensors, 4-bit, group 32)
llama.cpp: ghcr.io/ggml-org/llama.cpp:server-cuda-v1.0.0-b12359-b1b770d
Ollama: ollama/ollama:0.40.15, model created with Modelfile "FROM /gguf/Qwen3.8-27B-UD-Q4_K_M.gguf"
LM Studio: lmstudio/llmster-preview:cpu (sha256:dddeba2f77e3), CUDA 12 runtime 2.79.0 (llama.cpp b12521), lms import -l (symlink)
vLLM: vllm/vllm-openai:v0.33.0 with --language-model-only

## Setup notes (before the run)
- vLLM 32k context does not fit: --gpu-memory-utilization 0.92 default seqs -> OOM in CUDA graph profiling; 0.92 seqs32 -> 0.67 GiB KV (needs 2.3 GiB for 32768); 0.94 -> refused (22.07 GiB free); 0.93 seqs32 capture32 -> 1.03 GiB KV, est. max length 11,760. Run uses --max-model-len 8192.
- Model weights in vLLM: 18.28 GiB.
- llama.cpp defaults auto-fit: 4 slots, n_ctx_slot 97,792, kv_unified, 22,030 MiB. -np 32 -c 49152 --kv-unified: 21,784 MiB.
- Ollama defaults: context 32768, -np 1, 100% GPU, 17 GB.
- LM Studio defaults: context 8192, parallel 4.

=== run start 2026-11-20 11:51:10
running containers: 
VRAM before (desktop): 1166 MiB; GPU apps: [/usr/bin/ptyxis, 63 MiB;]
llama.cpp defaults: ready in 4.000031567 s; VRAM /app/llama-server, 22030 MiB;; args: 
0.03.329.231 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 97792, kv_unified = 'true'
  after llama-def-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22070 MiB;]; containers [bench-llama ]
  after llama-def-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22072 MiB;]; containers [bench-llama ]
  after llama-def-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22074 MiB;]; containers [bench-llama ]
  after llama-def-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22074 MiB;]; containers [bench-llama ]
  after llama-def-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22074 MiB;]; containers [bench-llama ]
  after llama-def-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22074 MiB;]; containers [bench-llama ]
  after llama-def-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22076 MiB;]; containers [bench-llama ]
llama.cpp np32 c49152 kvu: ready in 5.730622227 s; VRAM /app/llama-server, 21784 MiB;; args: -np 32 -c 49152 --kv-unified
0.05.320.667 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 49152, kv_unified = 'true'
  after llama-np32-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 21808 MiB;]; containers [bench-llama ]
=== first pass stopped during llama-np32 (12:3x): -np 32 -c 49152 --kv-unified with default --fit on moved layers to the CPU ("layer 3 is assigned to device CPU"), 11.5 tok/s at k1. llama-np32 rows removed from results.jsonl.
Fit check, -np 32 --kv-unified with fit on: c40960 25.8 tok/s, c36864 29.0, c32768 36.0 (still partly offloaded, no warning). With -ngl all --fit off: c49152 fails to load, c32768 43.4 tok/s, 22,244 MiB. Run restarted from the np32 setup with -c 32768 -ngl all --fit off.
=== run start 2026-11-20 12:19:55
running containers: 
VRAM before (desktop): 1051 MiB; GPU apps: [/usr/bin/ptyxis, 63 MiB;]
llama.cpp np32 c32768 kvu fit-off: ready in 3.687130304 s; VRAM /app/llama-server, 22238 MiB;; args: -np 32 -c 32768 --kv-unified -ngl all --fit off
0.03.211.902 I srv    load_model: initializing, n_slots = 32, n_ctx_slot = 32768, kv_unified = 'true'
  after llama-np32-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22250 MiB;]; containers [bench-llama ]
  after llama-np32-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22252 MiB;]; containers [bench-llama ]
  after llama-np32-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22254 MiB;]; containers [bench-llama ]
  after llama-np32-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22254 MiB;]; containers [bench-llama ]
  after llama-np32-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22256 MiB;]; containers [bench-llama ]
  after llama-np32-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22260 MiB;]; containers [bench-llama ]
  after llama-np32-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 22262 MiB;]; containers [bench-llama ]
NOTE llama-np32-k8-long: 8 x 4.1k-token prompts exceed the 32,768 shared context; llama-server returned 'Context size has been exceeded' and decode() failed, no request produced output in any round (agg 0). Result row kept as a failure, not a speed.
ollama defaults: API up 88.429 s (api 5.457 s), first answer 88.433456356 s, load_duration 32.14 s; VRAM /usr/lib/ollama/llama-server, 17456 MiB;; ps: qwen38-27b:latest    a2a82f1561c9    17 GB    100% GPU     32768      llamacpp    4 minutes from now    ; env: 
llama-server --model /root/.ollama/models/blobs/sha256-1bce504dfecd84153666928a41d8a66706f0158d3a317bc5196b72819d7dc529 --port 39713 --host 127.0.0.1 --no-webui --offline -c 32768 -np 1 --log-verbosity 4 --no-log-prefix --no-log-timestamps --flash-attn auto -b 512 -ub 512 --context-shift --keep 4"
  after ollama-def-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17464 MiB;]; containers [bench-ollama-q38 ]
  after ollama-def-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17468 MiB;]; containers [bench-ollama-q38 ]
  after ollama-def-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17494 MiB;]; containers [bench-ollama-q38 ]
  after ollama-def-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17494 MiB;]; containers [bench-ollama-q38 ]
  after ollama-def-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17494 MiB;]; containers [bench-ollama-q38 ]
  after ollama-def-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17494 MiB;]; containers [bench-ollama-q38 ]
  after ollama-def-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17494 MiB;]; containers [bench-ollama-q38 ]
ollama NUM_PARALLEL=4 CONTEXT_LENGTH=8192: API up 85.683 s (api 3.989 s), first answer 85.687133477 s, load_duration 30.78 s; VRAM /usr/lib/ollama/llama-server, 17882 MiB;; ps: qwen38-27b:latest    a2a82f1561c9    18 GB    100% GPU     8192       llamacpp    4 minutes from now    ; env: -e OLLAMA_NUM_PARALLEL=4 -e OLLAMA_CONTEXT_LENGTH=8192
llama-server --model /root/.ollama/models/blobs/sha256-1bce504dfecd84153666928a41d8a66706f0158d3a317bc5196b72819d7dc529 --port 45819 --host 127.0.0.1 --no-webui --offline -c 32768 -np 4 --log-verbosity 4 --no-log-prefix --no-log-timestamps --flash-attn auto -b 512 -ub 512 --context-shift --keep 4"
  after ollama-np4-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17892 MiB;]; containers [bench-ollama-q38 ]
  after ollama-np4-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17894 MiB;]; containers [bench-ollama-q38 ]
  after ollama-np4-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17896 MiB;]; containers [bench-ollama-q38 ]
  after ollama-np4-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17896 MiB;]; containers [bench-ollama-q38 ]
  after ollama-np4-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17896 MiB;]; containers [bench-ollama-q38 ]
  after ollama-np4-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17896 MiB;]; containers [bench-ollama-q38 ]
  after ollama-np4-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 17898 MiB;]; containers [bench-ollama-q38 ]
lm studio defaults: container+API 3.912 s, lms load 4.351524980 s; VRAM /root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18678 MiB;; args: 
qwen3.8-27b    qwen3.8-27b    IDLE      16.56 GB    8192       4           Local        
  after lms-def-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18718 MiB;]; containers [bench-lms-q38 ]
NOTE LM Studio defaults run llama-server with --spec-type draft-mtp --spec-draft-n-max 3 --spec-draft-n-min 0 --spec-draft-p-min 0 (MTP heads in the same GGUF); log: draft acceptance 0.44-0.47, mean len 2.32-2.42 on the short prompt. Full LM Studio flags: --ctx-size 8192 --parallel 4 --kv-unified --flash-attn on --batch-size 2048 --ubatch-size 512 --cache-type-k/v f16 --ctx-checkpoints 32 --load-mode mmap+mlock.
  after lms-def-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18720 MiB;]; containers [bench-lms-q38 ]
  after lms-def-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18722 MiB;]; containers [bench-lms-q38 ]
  after lms-def-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18722 MiB;]; containers [bench-lms-q38 ]
  after lms-def-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18756 MiB;]; containers [bench-lms-q38 ]
  after lms-def-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18756 MiB;]; containers [bench-lms-q38 ]
  after lms-def-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/root/.lmstudio/extensions/backends/llama.cpp-linux-x86_64-nvidia-cuda12-avx2-2.79.0/llama-server, 18756 MiB;]; containers [bench-lms-q38 ]
NOTE lms-def-k8-long: LM Studio defaults (--ctx-size 8192 shared, --kv-unified, --parallel 4) cannot hold 2+ concurrent 4.1k-token prompts; in each of 3 rounds 6 of 8 requests ended with no content (client thread error) and 2 returned 0 tokens. One long request at a time works (lms-def-k1-long). Failure, not a speed.
ValueError: max_num_seqs (32) exceeds available Mamba cache blocks (21). Each decode sequence requires one Mamba cache block, so CUDA graph capture cannot proceed. Please lower max_num_seqs to at most 21 or increase gpu_memory_utilization.
    raise RuntimeError(
RuntimeError: Engine core initialization failed. See root cause above. Failed core proc(s): {}
NOTE vLLM --max-num-seqs 32 at --max-model-len 8192 / 0.93: "max_num_seqs (32) exceeds available Mamba cache blocks (21)" (one linear-attention state block per running sequence). vLLM rerun after the MTP run with --max-num-seqs 16 --max-cudagraph-capture-size 16 (run-vllm.sh).
vllm warm (compile cache present): ready in 46.381617110 s; Model loading took 18.28 GiB GPU KV cache size: 30,840 tokens Maximum concurrency for 8,192 tokens per request: 3.76x ; VRAM VLLM::EngineCore, 22480 MiB;; args: --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 32 --max-cudagraph-capture-size 32
NOTE correction: the vllm warm start with --max-num-seqs 32 worked (46.4 s, KV 30,840 tokens); only the cold start (empty compile cache) hit the Mamba cache block limit. The queued seqs16 rerun (run-vllm.sh) was cancelled; matrix runs with seqs 32.
  after vllm-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22508 MiB;]; containers [bench-vllm ]
  after vllm-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22978 MiB;]; containers [bench-vllm ]
  after vllm-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22978 MiB;]; containers [bench-vllm ]
  after vllm-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22978 MiB;]; containers [bench-vllm ]
  after vllm-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22978 MiB;]; containers [bench-vllm ]
  after vllm-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22978 MiB;]; containers [bench-vllm ]
  after vllm-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;VLLM::EngineCore, 22916 MiB;]; containers [bench-vllm ]
=== run done 2026-11-20 14:16:41
=== mtp run start 2026-11-20 14:16:56
llama.cpp LM Studio flags + MTP: ready in 8.455450109 s; VRAM /app/llama-server, 18678 MiB;; args: -c 8192 -np 4 --kv-unified -b 2048 -ub 512 -ngl all --fit off --spec-type draft-mtp --spec-draft-n-max 3 --spec-draft-n-min 0 --spec-draft-p-min 0
0.07.580.501 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 8192, kv_unified = 'true'
  after llama-lmsflags-mtp-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 18718 MiB;]; containers [bench-llama ]
  after llama-lmsflags-mtp-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 18720 MiB;]; containers [bench-llama ]
  after llama-lmsflags-mtp-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 18754 MiB;]; containers [bench-llama ]
  after llama-lmsflags-mtp-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 18756 MiB;]; containers [bench-llama ]
  after llama-lmsflags-mtp-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 18756 MiB;]; containers [bench-llama ]
  after llama-lmsflags-mtp-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;]; containers [bench-llama ]
  after llama-lmsflags-mtp-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;]; containers [bench-llama ]
14.16.380.309 I slot print_timing: id  2 | task 6624 | draft acceptance = 0.43636 (  144 accepted /   330 generated), mean len =  2.31
14.21.549.573 I slot print_timing: id  0 | task 6626 | draft acceptance = 0.43636 (  144 accepted /   330 generated), mean len =  2.31
14.21.808.758 I slot print_timing: id  3 | task 6625 | draft acceptance = 0.41840 (  141 accepted /   337 generated), mean len =  2.25
NOTE llama-lmsflags-mtp: llama-server (v1.0 b12359, draft-mtp) disappeared from the GPU after the k32-short test finished (row recorded); k8-long got 'Connection reset by peer' on the warm-up request, no row. Container was removed by the next start.sh before the crash log was read. To repeat at the end with logs kept.
llama.cpp LM Studio flags, no MTP: ready in 43.999665678 s; VRAM /app/llama-server, 16342 MiB;; args: -c 8192 -np 4 --kv-unified -b 2048 -ub 512 -ngl all --fit off
0.04.473.083 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 8192, kv_unified = 'true'
  after llama-lmsflags-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16354 MiB;]; containers [bench-llama ]
  after llama-lmsflags-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16358 MiB;]; containers [bench-llama ]
  after llama-lmsflags-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16358 MiB;]; containers [bench-llama ]
  after llama-lmsflags-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16358 MiB;]; containers [bench-llama ]
  after llama-lmsflags-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16358 MiB;]; containers [bench-llama ]
  after llama-lmsflags-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16358 MiB;]; containers [bench-llama ]
  after llama-lmsflags-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/app/llama-server, 16360 MiB;]; containers [bench-llama ]
=== mtp run done 2026-11-20 14:52:05
=== vllm cold + mtp run start 2026-11-20 14:52:19
vllm seqs16 cold (empty compile cache): ready in 155.114478560 s; Model loading took 18.28 GiB GPU KV cache size: 10,601 tokens Maximum concurrency for 8,192 tokens per request: 1.29x ; VRAM VLLM::EngineCore, 20352 MiB;; args: --max-model-len 8192 --gpu-memory-utilization 0.93 --max-num-seqs 16 --max-cudagraph-capture-size 16
torch.OutOfMemoryError: CUDA out of memory. Tried to allocate 2.37 GiB. GPU 0 has a total capacity of 23.61 GiB of which 805.50 MiB is free. Including non-PyTorch memory, this process has 21.85 GiB memory in use. Of the allocated memory 21.46 GiB is allocated by PyTorch, and 54.43 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://docs.pytorch.org/docs/stable/notes/cuda.html#optimizing-memory-usage-with-pytorch-cuda-alloc-conf)
    raise RuntimeError(
RuntimeError: Engine core initialization failed. See root cause above. Failed core proc(s): {}
torch.OutOfMemoryError: CUDA out of memory. Tried to allocate 2.37 GiB. GPU 0 has a total capacity of 23.61 GiB of which 779.94 MiB is free. Including non-PyTorch memory, this process has 21.85 GiB memory in use. Of the allocated memory 21.46 GiB is allocated by PyTorch, and 54.43 MiB is reserved by PyTorch but unallocated. If reserved but unallocated memory is large try setting PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True to avoid fragmentation.  See documentation for Memory Management  (https://docs.pytorch.org/docs/stable/notes/cuda.html#optimizing-memory-usage-with-pytorch-cuda-alloc-conf)
    raise RuntimeError(
RuntimeError: Engine core initialization failed. See root cause above. Failed core proc(s): {}
NOTE vLLM MTP (--speculative-config {"method":"mtp","num_speculative_tokens":3}) does not fit: after the 18.28 GiB target weights, building the draft model (qwen3_5_mtp.py:238, speculator load_draft_model) tries to allocate 2.37 GiB with ~0.8 GiB free -> OOM, same at seqs 32 both tries. Independent of max-num-seqs (fails at model construction), so seqs16/8 retries stopped. Log: vllm-mtp-oom.log. === stopped 14:56:44
Error response from daemon: No such container: bench-vllm
=== llama MTP crash repeat start 2026-11-20 14:56:52
llama.cpp LM Studio flags + MTP (crash repeat): ready in 3.663093476 s; VRAM /app/llama-server, 18678 MiB;; args: -c 8192 -np 4 --kv-unified -b 2048 -ub 512 -ngl all --fit off --spec-type draft-mtp --spec-draft-n-max 3 --spec-draft-n-min 0 --spec-draft-p-min 0
0.03.049.432 I srv    load_model: initializing, n_slots = 4, n_ctx_slot = 8192, kv_unified = 'true'
NOTE crash reproduced 15:00:53: llama.cpp v1.0 b12359 with --spec-type draft-mtp aborts at the first request after the k32 test: '/app/common/common.cpp:1634: failed to remove sequence 0 with p0=76, p1=-1' right after 'making room for prompt cache entry' on slot reuse (log: llama-mtp-repeat.log). k32 repeat row: 159.6 tok/s (first run 160.1). k8-long with MTP got no result (server down). LM Studio runtime 2.79.0 (b12521) with the same flags did not crash in the same sequence. === all runs done
=== Ollama MTP check 2026-11-20 17:24:58
ollama defaults, qwen3.8:27b-mtp-q4_K_M: API up 60.480 s (api 5.238 s), first answer 60.492024400 s, load_duration 31.45 s; VRAM /usr/lib/ollama/llama-server, 20010 MiB;; ps: qwen3.8:27b-mtp-q4_K_M    22130167c4c2    17 GB    100% GPU     32768      llamacpp    4 minutes from now    ; env: 
llama-server --model /root/.ollama/models/blobs/sha256-f5f1dd8920d417aac2718b0bda3403da274301efdd6760b4f0f4b864ff2ad57d --port 36581 --host 127.0.0.1 --no-webui --offline -c 32768 -np 1 --log-verbosity 4 --no-log-prefix --no-log-timestamps --no-jinja --chat-template chatml --mmproj /root/.ollama/mod
=== ollama mtp run start 2026-11-20 17:26:17
ollama defaults, qwen3.8:27b-mtp-q4_K_M: API up 58.986 s (api 4.027 s), first answer 58.990287154 s, load_duration 31.46 s; VRAM /usr/lib/ollama/llama-server, 20010 MiB;; ps: qwen3.8:27b-mtp-q4_K_M    22130167c4c2    17 GB    100% GPU     32768      llamacpp    4 minutes from now    ; env: 
llama-server --model /root/.ollama/models/blobs/sha256-f5f1dd8920d417aac2718b0bda3403da274301efdd6760b4f0f4b864ff2ad57d --port 35029 --host 127.0.0.1 --no-webui --offline -c 32768 -np 1 --log-verbosity 4 --no-log-prefix --no-log-timestamps --no-jinja --chat-template chatml --mmproj /root/.ollama/mod
  after ollama-mtp-k1-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
  after ollama-mtp-k1-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
  after ollama-mtp-k4-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
  after ollama-mtp-k8-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
  after ollama-mtp-k16-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
  after ollama-mtp-k32-short: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
  after ollama-mtp-k8-long: GPU apps [/usr/bin/ptyxis, 63 MiB;/usr/lib/ollama/llama-server, 20070 MiB;]; containers [bench-ollama-q38 ]
slot print_timing: id  0 | task 22488 | draft acceptance = 0.45429 (  164 accepted /   361 generated), mean len =  2.80
slot print_timing: id  0 | task 22590 | draft acceptance = 0.50445 (  170 accepted /   337 generated), mean len =  3.00
slot print_timing: id  0 | task 22686 | draft acceptance = 0.52744 (  173 accepted /   328 generated), mean len =  3.11
spec common_specu: statistics        draft-mtp: #calls(b,g,a) =  222  21793  21793, #gen drafts =  21793, #acc drafts = 16878, #gen tokens =  86860, #acc tokens = 36026, #mean acc len = 2.65, #acc rate/pos = (0.774, 0.453, 0.276, 0.150), dur(b,g,a) = 0.869, 160847.026, 17.031 ms
=== ollama mtp run done 2026-11-20 17:57:58
