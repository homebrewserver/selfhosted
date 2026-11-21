#!/usr/bin/env python3
"""Prefix caching test: the same long document as system prompt, different questions.

Each round starts the document with a fresh nonce, so nothing from an earlier round is cached.
  seq:  8 requests one after another. Request 1 is cold (whole prompt prefilled); 2..8 can reuse the cached prefix.
  conc: K requests start together on a fresh prefix (does the engine share the prefix between requests in flight?).
Both engines are called on /v1/chat/completions with streaming; TTFT is client side.
"""
import argparse, json, statistics, threading, time, urllib.request, uuid

DOC = open("long-context.txt").read()
QS = ["Summarize the text in five bullet points.", "List every person or organization named in the text.",
      "What is the main argument of the text?", "Write a one-sentence title for the text.",
      "Which numbers or dates appear in the text?", "What questions does the text leave open?",
      "Explain the text to a 12-year-old in three sentences.", "Name three weaknesses of the argument in the text.",
      "What would be a good follow-up article to the text?", "Translate the first sentence of the text into French.",
      "Which section of the text is the most technical?", "Give the text a rating from 1 to 10 and say why.",
      "Write two quiz questions about the text.", "What is the tone of the text?",
      "List the key terms in the text with a short definition each.", "Rewrite the last paragraph of the text more simply."]

def one(a, system, q, out, idx):
    body = {"model": a.model, "messages": [{"role": "system", "content": system}, {"role": "user", "content": q}],
            "max_tokens": a.n, "temperature": 0, "stream": True, "stream_options": {"include_usage": True},
            "chat_template_kwargs": {"enable_thinking": False}}
    req = urllib.request.Request(a.url + "/v1/chat/completions", json.dumps(body).encode(), {"Content-Type": "application/json"})
    t0 = time.perf_counter(); first = None; usage = {}
    for line in urllib.request.urlopen(req, timeout=1800):
        line = line.decode().strip()
        if not line.startswith("data: ") or line == "data: [DONE]":
            continue
        d = json.loads(line[6:]); ch = d.get("choices") or []
        if ch and (ch[0].get("delta") or {}).get("content") and first is None:
            first = time.perf_counter()
        if d.get("usage"):
            usage = d["usage"]
    out.append({"i": idx, "ttft_ms": round((first - t0) * 1000), "wall_ms": round((time.perf_counter() - t0) * 1000),
                "prompt_tokens": usage.get("prompt_tokens"),
                "cached_tokens": (usage.get("prompt_tokens_details") or {}).get("cached_tokens")})

ap = argparse.ArgumentParser()
ap.add_argument("--url", required=True); ap.add_argument("--model", required=True); ap.add_argument("--label", required=True)
ap.add_argument("-n", type=int, default=32); ap.add_argument("-k", type=int, default=16); ap.add_argument("--rounds", type=int, default=3)
a = ap.parse_args()
fresh = lambda: f"Document id {uuid.uuid4().hex}.\n" + DOC
one(a, fresh(), QS[0], [], 0)  # warm-up
res = {"label": a.label, "seq": [], "conc": []}
for r in range(a.rounds):
    s = fresh(); out = []
    for i in range(8):
        one(a, s, QS[i], out, i)
    res["seq"].append(out)
    print(f"{a.label} seq round {r+1}: cold {out[0]['ttft_ms']} ms, warm med {statistics.median(o['ttft_ms'] for o in out[1:])} ms, "
          f"cached {[o['cached_tokens'] for o in out]}", flush=True)
for r in range(a.rounds):
    s = fresh(); out = []
    th = [threading.Thread(target=one, args=(a, s, QS[i % len(QS)], out, i)) for i in range(a.k)]
    t0 = time.perf_counter(); [t.start() for t in th]; [t.join() for t in th]
    res["conc"].append({"wall_ms": round((time.perf_counter() - t0) * 1000), "reqs": out})
    print(f"{a.label} conc k{a.k} round {r+1}: ttft med {statistics.median(o['ttft_ms'] for o in out)} ms, "
          f"max {max(o['ttft_ms'] for o in out)} ms, batch {res['conc'][-1]['wall_ms']} ms", flush=True)
cold = [rd[0]["ttft_ms"] for rd in res["seq"]]; warm = [o["ttft_ms"] for rd in res["seq"] for o in rd[1:]]
cm = [o["ttft_ms"] for rd in res["conc"] for o in rd["reqs"]]
summ = {"label": a.label, "prompt_tokens": res["seq"][0][0]["prompt_tokens"], "cold_ttft_ms_med": statistics.median(cold),
        "warm_ttft_ms_med": statistics.median(warm), f"conc{a.k}_ttft_ms_med": statistics.median(cm),
        f"conc{a.k}_ttft_ms_max": max(cm), f"conc{a.k}_batch_ms_med": statistics.median(rd["wall_ms"] for rd in res["conc"])}
print(json.dumps(summ), flush=True)
open("prefix-results.jsonl", "a").write(json.dumps({**summ, "data": res}) + "\n")
