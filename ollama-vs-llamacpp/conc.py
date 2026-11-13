#!/usr/bin/env python3
"""Send K identical-length requests at once and report aggregate generation throughput."""
import argparse, json, statistics, subprocess, threading, time, urllib.request, uuid

ap = argparse.ArgumentParser()
ap.add_argument("engine", choices=["ollama", "llama"])
ap.add_argument("--url", required=True)
ap.add_argument("--model", default="")
ap.add_argument("-k", type=int, default=4)
ap.add_argument("-n", type=int, default=256)
ap.add_argument("--rounds", type=int, default=3)
ap.add_argument("--label", default="")
a = ap.parse_args()
P = "Write a long, detailed essay of at least 2000 words about the history of the bicycle, with many sections."


def one(out):
    p = f"Request id {uuid.uuid4().hex}.\n" + P
    if a.engine == "ollama":
        body = {"model": a.model, "messages": [{"role": "user", "content": p}], "think": False, "stream": False,
                "options": {"temperature": 0, "seed": 42, "num_predict": a.n}}
        req = urllib.request.Request(a.url + "/api/chat", json.dumps(body).encode(), {"Content-Type": "application/json"})
        d = json.load(urllib.request.urlopen(req, timeout=900))
        out.append(d["eval_count"])
    else:
        body = {"messages": [{"role": "user", "content": p}], "max_tokens": a.n, "temperature": 0, "seed": 42,
                "chat_template_kwargs": {"enable_thinking": False}}
        req = urllib.request.Request(a.url + "/v1/chat/completions", json.dumps(body).encode(), {"Content-Type": "application/json"})
        d = json.load(urllib.request.urlopen(req, timeout=900))
        out.append(d["timings"]["predicted_n"])


one([])  # warm-up
agg = []
for r in range(a.rounds):
    while int(subprocess.check_output(["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader"]).decode().strip()) > 50:
        time.sleep(2)
    out = []; th = [threading.Thread(target=one, args=(out,)) for _ in range(a.k)]
    t0 = time.perf_counter(); [t.start() for t in th]; [t.join() for t in th]; w = time.perf_counter() - t0
    agg.append(sum(out) / w)
    print(f"round {r+1}: {sum(out)} tokens in {w:.2f}s = {sum(out)/w:.1f} tok/s")
res = {"label": a.label, "engine": a.engine, "k": a.k, "n": a.n, "median_agg_tps": round(statistics.median(agg), 1), "all": agg}
print(json.dumps(res))
open("results.jsonl", "a").write(json.dumps(res) + "\n")
