import json, statistics, collections, sys
pre = sys.argv[1] if len(sys.argv) > 1 else "il-"
g = collections.defaultdict(list)
for l in open("results.jsonl"):
    d = json.loads(l)
    if d.get("label", "").startswith(pre) and "all" in d and isinstance(d["all"][0], dict):
        for r in d["all"]:
            g[(d["label"], d["prompt"])].append(r)
for (lab, p), rs in sorted(g.items()):
    m = lambda k: statistics.median(r[k] for r in rs)
    print(f"{lab:32} {p:5} n={len(rs)} tg={m('tg_tps'):6.1f} [{min(r['tg_tps'] for r in rs):.1f}-{max(r['tg_tps'] for r in rs):.1f}] pp={m('pp_tps'):7.0f} ttft={m('ttft_s')*1000:5.0f}ms ptok={m('prompt_tokens'):.0f} temp={m('temp_start'):.0f}->{m('temp_end'):.0f}")
