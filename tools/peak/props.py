"""List every prop name the course uses, with sizes and counts -> docs/peak/PROPS_USED.md
  python tools/peak/props.py
"""
import glob, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from peaklib import COURSE_DIR, ROOT

used = {}
for path in sorted(glob.glob(os.path.join(COURSE_DIR, "a*.json")) + glob.glob(os.path.join(COURSE_DIR, "st.json"))):
    a = json.load(open(path, encoding="utf-8"))
    for d in a.get("decos", []):
        u = used.setdefault(d["model"], {"n": 0, "areas": set(), "size": d.get("size"), "kind": "prop"})
        u["n"] += 1
        u["areas"].add(a["id"])
        if d.get("size") and not u["size"]:
            u["size"] = d["size"]
    for m in a.get("movers", []) + a.get("bodies", []):
        if m.get("model"):
            u = used.setdefault(m["model"], {"n": 0, "areas": set(), "size": None, "kind": "moving"})
            u["n"] += 1
            u["areas"].add(a["id"])
            u["kind"] = "moving"
kit = os.path.join(ROOT, "kit", "models")
lines = ["# Props the course uses", "", "Rebuilt by `tools/peak/props.py`. `landed` = `kit/models/<name>.glb` exists.", "",
         "| Name | Kind | Used | Areas | Size (w, h, d) | Landed |", "|---|---|---|---|---|---|"]
for name in sorted(used):
    u = used[name]
    size = " x ".join("%g" % v for v in u["size"]) if u["size"] else ""
    landed = "yes" if os.path.exists(os.path.join(kit, name + ".glb")) else ""
    lines.append("| `%s` | %s | %d | %s | %s | %s |" % (name, u["kind"], u["n"], ", ".join(sorted(u["areas"])), size, landed))
open(os.path.join(ROOT, "docs", "peak", "PROPS_USED.md"), "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
print("%d prop names" % len(used))
