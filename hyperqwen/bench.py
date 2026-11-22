#!/usr/bin/env python3
"""Ollama (native /api/chat), LM Studio (native /api/v1/chat), vLLM and llama.cpp (/v1/chat/completions), same prompts, streaming.

Concurrency K: K requests start together. Each request records client-side TTFT
(request start -> first content chunk) and decode speed ((tokens-1)/(last-first chunk)).
Aggregate throughput = all generated tokens / wall time of the batch.
Every prompt starts with a random nonce so no prefix cache can be reused.
"""
import argparse, json, statistics, subprocess, threading, time, urllib.request, uuid

CODE = open("code-source.py").read()
DOC25 = open("doc-24k.txt").read() if __import__("os").path.exists("doc-24k.txt") else ""
SHORT = "Write a long, detailed essay of at least 2000 words about the history of the bicycle, with many sections."
LONG = open("long-context.txt").read() + "\n\nSummarize the text above in five bullet points."

QUOTE = "\n\nRepeat the text above word for word, starting from its first sentence. Output only the text."
EDIT = "\n\nReturn this Python file with one change: rename the function `one` to `run_request` everywhere it appears. Output only the full file, no explanation."
SOURCES = {"short": "", "long": LONG, "quote": open("long-context.txt").read(), "code": CODE, "quote24k": DOC25}

def prompt(kind):
    body = {"short": SHORT, "long": LONG, "quote": SOURCES["quote"] + QUOTE, "code": CODE + EDIT, "quote24k": DOC25 + QUOTE}[kind]
    return f"Request id {uuid.uuid4().hex}.\n" + body

def coverage(ans, doc, W=40, S=20):
    """Share of the answer's 40-character windows found verbatim in the source (HyperQwen bench/verbatim.py rule)."""
    if not ans or not doc:
        return None
    if a_kind == "code":
        doc = doc.replace("def one(", "def run_request(").replace("target=one,", "target=run_request,").replace("one(a, a.prompt, [])", "run_request(a, a.prompt, [])")
    wins = [ans[i:i + W] for i in range(0, max(1, len(ans) - W + 1), S)]
    return round(sum(w in doc for w in wins) / len(wins), 3)

def gpu(q):
    return subprocess.check_output(["nvidia-smi", f"--query-gpu={q}", "--format=csv,noheader,nounits"]).decode().strip()

def one(a, kind, out):
    p = prompt(kind); t0 = time.perf_counter(); first = last = None; ntok = 0; server = {}; text = []
    if a.engine == "ollama":
        body = {"model": a.model, "messages": [{"role": "user", "content": p}], "think": False, "stream": True,
                "options": {"temperature": 0, "seed": 42, "num_predict": a.n}}
        req = urllib.request.Request(a.url + "/api/chat", json.dumps(body).encode(), {"Content-Type": "application/json"})
        for line in urllib.request.urlopen(req, timeout=1800):
            d = json.loads(line)
            if d.get("message", {}).get("content"):
                now = time.perf_counter(); first = first or now; last = now
            if d.get("done"):
                ntok = d["eval_count"]
                server = {"prompt_tokens": d["prompt_eval_count"], "srv_tg_tps": d["eval_count"] / (d["eval_duration"] / 1e9),
                          "srv_pp_tps": d["prompt_eval_count"] / (d["prompt_eval_duration"] / 1e9)}
    elif a.engine == "lms":
        body = {"model": a.model, "input": p, "reasoning": "off", "temperature": 0, "max_output_tokens": a.n,
                "store": False, "stream": True}
        req = urllib.request.Request(a.url + "/api/v1/chat", json.dumps(body).encode(), {"Content-Type": "application/json"})
        for line in urllib.request.urlopen(req, timeout=1800):
            line = line.decode().strip()
            if not line.startswith("data: "):
                continue
            d = json.loads(line[6:])
            if d.get("type") == "message.delta" and d.get("content"):
                now = time.perf_counter(); first = first or now; last = now
            if d.get("type") == "chat.end":
                st = d["result"]["stats"]; ntok = st["total_output_tokens"]
                server = {"prompt_tokens": st["input_tokens"], "srv_tg_tps": st["tokens_per_second"]}
    else:
        body = {"model": a.model, "messages": [{"role": "user", "content": p}], "max_tokens": a.n, "temperature": 0, "seed": 42,
                "stream": True, "stream_options": {"include_usage": True}, "chat_template_kwargs": {"enable_thinking": False}}
        req = urllib.request.Request(a.url + "/v1/chat/completions", json.dumps(body).encode(), {"Content-Type": "application/json"})
        for line in urllib.request.urlopen(req, timeout=1800):
            line = line.decode().strip()
            if not line.startswith("data: ") or line == "data: [DONE]":
                continue
            d = json.loads(line[6:])
            ch = d.get("choices") or []
            if ch and (ch[0].get("delta") or {}).get("content"):
                now = time.perf_counter(); first = first or now; last = now; text.append(ch[0]["delta"]["content"])
            if d.get("usage"):
                ntok = d["usage"]["completion_tokens"]; server = {"prompt_tokens": d["usage"]["prompt_tokens"]}
    end = time.perf_counter()
    out.append({"ttft_s": first - t0, "tg_tps": (ntok - 1) / (last - first) if last > first else 0, "gen_tokens": ntok,
                "wall_s": end - t0, **server, "text": "".join(text)})

ap = argparse.ArgumentParser()
ap.add_argument("engine", choices=["ollama", "vllm", "llamacpp", "lms"])
ap.add_argument("--url", required=True)
ap.add_argument("--model", required=True)
ap.add_argument("--prompt", choices=["short", "long", "quote", "code", "quote24k"], default="short")
ap.add_argument("--results", default="results.jsonl")
ap.add_argument("-n", type=int, default=512)
ap.add_argument("-k", type=int, default=1, help="concurrent requests")
ap.add_argument("--rounds", type=int, default=3)
ap.add_argument("--cool", type=int, default=50)
ap.add_argument("--label", required=True)
a = ap.parse_args(); a_kind = a.prompt
one(a, a.prompt, [])  # warm-up, not recorded
rounds = []
for r in range(a.rounds):
    while int(gpu("temperature.gpu")) > a.cool:
        time.sleep(2)
    t_start = int(gpu("temperature.gpu")); out = []
    th = [threading.Thread(target=one, args=(a, a.prompt, out)) for _ in range(a.k)]
    t0 = time.perf_counter(); [t.start() for t in th]; [t.join() for t in th]; w = time.perf_counter() - t0
    rd = {"agg_tps": sum(o["gen_tokens"] for o in out) / w, "wall_s": w, "temp": [t_start, int(gpu("temperature.gpu"))],
          "vram_mib": int(gpu("memory.used")), "reqs": out}
    rounds.append(rd)
    print(f"{a.label} round {r+1}: agg {rd['agg_tps']:.1f} tok/s, per-req tg {statistics.median(o['tg_tps'] for o in out):.1f}, "
          f"ttft med {statistics.median(o['ttft_s'] for o in out)*1000:.0f} ms max {max(o['ttft_s'] for o in out)*1000:.0f} ms", flush=True)
allr = [o for rd in rounds for o in rd["reqs"]]
summ = {"label": a.label, "engine": a.engine, "prompt": a.prompt, "n": a.n, "k": a.k, "rounds": a.rounds,
        "agg_tps_med": round(statistics.median(rd["agg_tps"] for rd in rounds), 1),
        "tg_tps_med": round(statistics.median(o["tg_tps"] for o in allr), 1),
        "ttft_ms_med": round(statistics.median(o["ttft_s"] for o in allr) * 1000),
        "ttft_ms_max": round(max(o["ttft_s"] for o in allr) * 1000),
        "gen_tokens_med": statistics.median(o["gen_tokens"] for o in allr),
        "prompt_tokens_med": statistics.median(o.get("prompt_tokens", 0) for o in allr), "data": rounds}
if a.prompt in ("quote", "code", "quote24k"):
    covs = [coverage(o["text"], SOURCES[a.prompt]) for o in allr]
    summ["copy_coverage_min"] = min(covs); summ["copy_coverage_med"] = statistics.median(covs)
summ["sample_text"] = allr[0]["text"][:400]
for rd in rounds:
    for o in rd["reqs"]:
        o.pop("text", None)
print(json.dumps({k: v for k, v in summ.items() if k != "data"}), flush=True)
open(a.results, "a").write(json.dumps(summ) + "\n")
