memsearch ollama stopped 00:17:48
baseline VRAM (desktop only): 1344 MiB
vllm cold start ready in 173.391330703 s
3200159, VLLM::EngineCore, 21554 MiB
bench-vllm 5.12GiB / 62.72GiB
vllm warm start (compile cache present) ready in 81.554910653 s
(EngineCore pid=185) INFO 11-08 19:33:33 [default_loader.py:506] Loading weights took 1.32 seconds
(EngineCore pid=185) INFO 11-08 19:33:52 [monitor.py:62] [backbone] torch.compile took 0.36 s in total
(EngineCore pid=185) INFO 11-08 19:33:53 [monitor.py:91] [backbone] Initial profiling/warmup run took 0.59 s
(EngineCore pid=185) INFO 11-08 19:34:05 [model_runner.py:1163] Graph capturing finished in 11 secs, took 0.46 GiB
(EngineCore pid=185) INFO 11-08 19:34:20 [model_runner.py:1163] Graph capturing finished in 14 secs, took 0.27 GiB
(EngineCore pid=185) INFO 11-08 19:34:21 [core.py:405] init engine (profile, create kv cache, warmup model) took 46.30 s (compilation: 0.36 s)
warm+offline: ready in 156.856260882 s; GPU KV cache size: 315,332 tokens Maximum concurrency for 32,768 tokens per request: 9.62x ; VRAM VLLM::EngineCore, 20836 MiB
enforce-eager: ready in 107.471448401 s; GPU KV cache size: 330,529 tokens Maximum concurrency for 32,768 tokens per request: 10.09x ; VRAM VLLM::EngineCore, 20752 MiB
gpu-mem-0.5 with 32768: failed: needs 1.11 GiB KV, 0.78 GiB available, est max len 22176
gpu-mem-0.6 default max_num_seqs: failed: max_num_seqs (256) exceeds available Mamba cache blocks (196)
gpu-mem-0.6 max-num-seqs 32: ready in 137.804659162 s; GPU KV cache size: 110,176 tokens Maximum concurrency for 32,768 tokens per request: 3.36x ; VRAM VLLM::EngineCore, 13016 MiB
ollama defaults: API up 5.566556732 s, first answer 74.967801605 s, load_duration_s 34.79; VRAM /usr/lib/ollama/llama-server, 6510 MiB; ps: qwen35-9b-hf:latest    ddea16afe16a    6.5 GB    100% GPU     32768      llamacpp    4 minutes from now    
llama-server --model /root/.ollama/models/blobs/sha256-03b74727a860a56338e042c4420bb3f04b2fec5734175f4cb9fa853daf52b7e8 --port 35825 --host 127.0.0.1 --no-webui --offline -c 32768 -np 1 --log-verbosity 4 --no-log-prefix --no-log-timestamps --flash-attn auto -b 1024 -ub 1024 --context-shift --keep 4"
ollama reload after ollama stop: 2.869644242 s
ollama NUM_PARALLEL=16: API up 4.071311289 s, first answer 71.386881497 s, load_duration_s 32.86; VRAM /usr/lib/ollama/llama-server, 21814 MiB; ps: qwen35-9b-hf:latest    ddea16afe16a    26 GB    13%/87% CPU/GPU    32768      llamacpp    4 minutes from now    
llama-server --model /root/.ollama/models/blobs/sha256-03b74727a860a56338e042c4420bb3f04b2fec5734175f4cb9fa853daf52b7e8 --port 46033 --host 127.0.0.1 --no-webui --offline -c 524288 -np 16 --log-verbosity 4 --no-log-prefix --no-log-timestamps --flash-attn auto -b 512 -ub 512 --context-shift --keep 4"
NAME                   ID              SIZE     PROCESSOR          CONTEXT    RUNNER      UNTIL              
qwen35-9b-hf:latest    ddea16afe16a    26 GB    13%/87% CPU/GPU    32768      llamacpp    4 minutes from now    
vllm default for idle power: ready in 83.580924391 s; GPU KV cache size: 315,807 tokens Maximum concurrency for 32,768 tokens per request: 9.64x ; VRAM VLLM::EngineCore, 20852 MiB
ollama NUM_PARALLEL=16 CONTEXT_LENGTH=4096: API up 3.887741911 s, first answer 69.401862667 s, load_duration_s 30.95; VRAM /usr/lib/ollama/llama-server, 8230 MiB; ps: qwen35-9b-hf:latest    ddea16afe16a    8.3 GB    100% GPU     4096       llamacpp    4 minutes from now    
llama-server --model /root/.ollama/models/blobs/sha256-03b74727a860a56338e042c4420bb3f04b2fec5734175f4cb9fa853daf52b7e8 --port 35231 --host 127.0.0.1 --no-webui --offline -c 65536 -np 16 --log-verbosity 4 --no-log-prefix --no-log-timestamps --flash-attn auto -b 1024 -ub 1024 --context-shift --keep 4
qwen35-9b-hf:latest    ddea16afe16a    8.3 GB    100% GPU     4096       llamacpp    4 minutes from now    
vllm mem0.6 seqs32 same-day: ready in 64.089711427 s; GPU KV cache size: 110,176 tokens Maximum concurrency for 32,768 tokens per request: 3.36x ; VRAM VLLM::EngineCore, 13014 MiB
