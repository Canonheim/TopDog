"""Builds the pitch deck: docs/peak/playtest/design/PITCH.html

    python docs/peak/playtest/design/pitch.py

One self-contained HTML file. A slide for each biome, then a slide for each of its areas,
with a feedback box on every slide (kept in the browser, and saved out as one file).
It is made from the same data as the design pages (build.py), plus data/pitch.py.
"""
import io, os, re, sys, json

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import build as B  # noqa: E402

esc = B.esc


def numbered_items(a):
    out, n = [], 0
    for layer in ("background", "play", "foreground"):
        for it in a.get(layer, []):
            n += 1
            out.append((n, layer, it))
    return out


def biome_map(bid, areas):
    """The whole biome as the course has it, with each area's window outlined and numbered."""
    c = B.course(bid)
    pal = B.META["palettes"].get(c.get("palette", ""), {})
    wins = [a["window"] for a in areas if not a.get("also")] or [a["window"] for a in areas]
    x0 = min(w[0] for w in wins) - 2; y0 = min(w[1] for w in wins) - 2
    x1 = max(w[2] for w in wins) + 2; y1 = max(w[3] for w in wins) + 2
    sk = B.Sketch([x0, y0, x1, y1], maxw=900.0)
    B.draw_all(sk, {"also": []}, c, pal)
    for a in areas:
        w = a["window"]
        sk.out.append('<rect x="%s" y="%s" width="%.1f" height="%.1f" class="win"/>' % (sk.X(w[0]), sk.Y(w[3]), (w[2] - w[0]) * sk.s, (w[3] - w[1]) * sk.s))
    for a in areas:
        w = a["window"]
        cx, cy = sk.X((w[0] + w[2]) / 2), sk.Y((w[1] + w[3]) / 2)
        lab = esc(a["id"])
        sk.out.append('<g class="wl"><rect x="%.1f" y="%.1f" width="%d" height="16" rx="8"/><text x="%.1f" y="%.1f">%s</text></g>' % (cx - 4 * len(lab) - 6, cy - 8, 8 * len(lab) + 12, cx, cy + 4, lab))
    return sk.svg("Map of the biome, with each place outlined")


def first_sentence(t):
    m = re.search(r"(?<=[.!?])\s+", t)
    if not m or m.start() > 260:
        return t, ""
    return t[:m.start()], t[m.end():]


def ul(items, cls=""):
    return "<ul%s>%s</ul>" % (' class="%s"' % cls if cls else "", "".join("<li>%s</li>" % esc(x) for x in items))


def fb_box(sid):
    return ('<div class="fb" data-fb="%s"><div class="fbh"><b>Your feedback on this slide</b>'
            '<span class="verd"><button data-v="Good as it is">Good as it is</button><button data-v="Needs changes">Needs changes</button><button data-v="Rethink it">Rethink it</button></span>'
            '<span class="saved"></span></div><textarea placeholder="Type what you think. It saves as you type."></textarea></div>' % esc(sid))


def layers_html(numbered):
    out = []
    for layer, head in (("background", "Background"), ("play", "Play space"), ("foreground", "Foreground")):
        rows = [(n, it) for n, l, it in numbered if l == layer]
        out.append('<h3 class="l-%s">%s</h3>' % (layer, head))
        if not rows:
            out.append('<p class="sub">Nothing. That is on purpose.</p>' if layer == "foreground" else '<p class="sub">Nothing.</p>')
            continue
        out.append('<ul class="items">%s</ul>' % "".join('<li><span class="num">%d</span><b>%s.</b> %s</li>' % (n, esc(it["name"]).rstrip("."), esc(it.get("text", ""))) for n, it in rows))
    return "".join(out)


def area_slide(a, bid, biome, c, pal, k, total):
    numbered = numbered_items(a)
    side = B.side_sketch(a, c, pal, numbered)
    top = B.top_sketch(a, c, pal, numbered)
    kind = {"challenge": "Challenge", "rest": "A place to rest", "join": "A join between two biomes"}.get(a.get("kind", "challenge"), "Area")
    hook, rest = first_sentence(a.get("place", ""))
    notes = list(a.get("notes", []))
    changes = [n for n in notes if n.lower().startswith("course change")]
    other = [n for n in notes if not n.lower().startswith("course change")]
    pieces = a.get("pieces", [])
    new = [p for p in pieces if not str(p[-1]).lower().startswith(("kit", "in the kit"))]
    t = ['<section class="slide area" data-id="%s" data-title="%s %s" data-group="%s">' % (esc(a["id"]), esc(a["id"]), esc(a["title"]), esc(biome["name"]))]
    t.append('<div class="stage"><div class="views"><div class="view" data-view="side">%s</div><div class="view" data-view="top" hidden>%s</div></div>'
             '<div class="vt"><button data-show="side" class="on">From the side</button><button data-show="top">From above</button>'
             '<span class="kk"><i style="background:#4f6076"></i>background <i style="background:#ffe08a"></i>added to the play space <i style="background:#d05cc4"></i>foreground <i style="border:1px dashed #8a8178"></i>scenery there today</span></div></div>' % (side, top))
    t.append('<div class="talk"><div class="scroll">')
    t.append('<p class="crumb">%s &middot; %s &middot; place %d of %d</p>' % (esc(biome["name"]), kind, k, total))
    t.append("<h1>%s %s</h1>" % (esc(a["id"]), esc(a["title"])))
    t.append('<p class="hook">%s</p>' % esc(hook))
    if rest:
        t.append("<p>%s</p>" % esc(rest))
    t.append("<h2>What you are looking at</h2>" + layers_html(numbered))
    if a.get("explains"):
        t.append('<h2>Why it works</h2><p class="sub">Each thing you touch is the near end of something real behind it.</p><table><tr><th>You touch</th><th>It is</th><th>Behind it</th></tr>%s</table>' %
                 "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % esc(x) for x in row) for row in a["explains"]))
    if a.get("keep"):
        t.append("<h2>What I am not touching</h2>" + ul(a["keep"]))
    t.append("<h2>What it would change in the game</h2>" + (ul(changes) if changes else '<p class="sub">Nothing you touch moves or is added. Looks only.</p>'))
    if pieces:
        t.append('<h2>What it takes to build</h2><p>%d kinds of piece: %d from the biome\'s kit, %d new.</p><details><summary>The list</summary><table><tr><th>Piece</th><th>Size</th><th>How many</th><th>Layer</th><th>Kit or new</th></tr>%s</table></details>' %
                 (len(pieces), len(pieces) - len(new), len(new), "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % esc(x) for x in row) for row in pieces)))
    if a.get("effects"):
        t.append("<h3>Small effects, no models</h3>" + ul(a["effects"]))
    t.append('<h2>Notes</h2>' + (ul(other) if other else '<p class="sub">None.</p>'))
    t.append('<h2>Outstanding questions</h2>' + ('<div class="ask">%s</div>' % ul(a["ask"]) if a.get("ask") else '<p class="sub">None. Nothing here is waiting on you.</p>'))
    t.append("</div>" + fb_box(a["id"]) + "</div></section>")
    return "".join(t)


def biome_slide(bid, Bm, areas, pitch):
    kit = Bm.get("kit", [])
    new = [p for p in kit if not str(p[-1]).lower().startswith(("in the kit", "kit"))]
    asks = sum(len(a.get("ask", [])) for a in areas)
    t = ['<section class="slide biome" data-id="biome %s" data-title="Biome %s: %s" data-group="%s">' % (bid[1:], bid[1:], esc(Bm["name"]), esc(Bm["name"]))]
    t.append('<div class="stage"><div class="views"><div class="view" data-view="side">%s</div></div><div class="vt"><span class="kk">The whole biome as the game has it today. Each outlined box is one of the slides that follow.</span></div></div>' % biome_map(bid, areas))
    t.append('<div class="talk"><div class="scroll">')
    t.append('<p class="crumb">Biome %s of the first seven &middot; %d places &middot; %d open question%s</p>' % (bid[1:], len(areas), asks, "" if asks == 1 else "s"))
    t.append("<h1>%s</h1>" % esc(Bm["name"]))
    t.append('<p class="sub">%s</p>' % esc(Bm.get("line", "")))
    t.append('<p class="hook">%s</p>' % esc(pitch))
    t.append("<h2>What this place is</h2>" + "".join("<p>%s</p>" % esc(p) for p in Bm.get("story", [])))
    t.append("<h2>How it is built</h2>" + ul(Bm.get("built", [])))
    t.append("<h2>Colour and light</h2><p>%s</p>" % esc(Bm.get("light", "")))
    if Bm.get("looks"):
        t.append("<h2>How it tells you what a thing is</h2><table>%s</table>" % "".join("<tr><td><b>%s</b></td><td>%s</td></tr>" % (esc(r[0]), esc(r[1])) for r in Bm["looks"]))
    if Bm.get("layers"):
        t.append("<h2>The three layers here</h2><table>%s</table>" % "".join("<tr><td><b>%s</b></td><td>%s</td></tr>" % (esc(r[0]), esc(r[1])) for r in Bm["layers"]))
    t.append("<h2>How you come in, and how you leave</h2><p><b>In:</b> %s</p><p><b>Out:</b> %s</p>" % (esc(Bm.get("arrive", "")), esc(Bm.get("leave", ""))))
    t.append('<h2>The shared kit</h2><p>%d kinds of piece, reused across the biome: %d are in the game\'s kit today, %d are new.</p><details><summary>The list</summary><table><tr><th>Piece</th><th>Size</th><th>Used for</th><th>Layer</th><th>Today, or new</th></tr>%s</table></details>' %
             (len(kit), len(kit) - len(new), len(new), "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % esc(x) for x in row) for row in kit)))
    if Bm.get("motifs"):
        t.append("<h2>Running through it</h2>" + ul(Bm["motifs"]))
    t.append("<h2>Notes</h2>" + (ul(Bm.get("notes", [])) if Bm.get("notes") else '<p class="sub">None.</p>'))
    t.append('<h2>Outstanding questions</h2>' + ('<div class="ask">%s</div>' % ul(Bm["ask"]) if Bm.get("ask") else '<p class="sub">None on the biome itself.%s</p>' % (" %d on its places: see their slides." % asks if asks else "")))
    t.append('<h2>The places in it</h2><ol class="toc">%s</ol>' % "".join('<li><a href="#" data-go="%s">%s %s</a></li>' % (esc(a["id"]), esc(a["id"]), esc(a["title"])) for a in areas))
    t.append("</div>" + fb_box("biome " + bid[1:]) + "</div></section>")
    return "".join(t)


def text_slide(sid, title, crumb, paras, extra="", feedback=True):
    t = ['<section class="slide text" data-id="%s" data-title="%s" data-group="The pitch"><div class="talk wide"><div class="scroll">' % (esc(sid), esc(title))]
    t.append('<p class="crumb">%s</p><h1>%s</h1>' % (esc(crumb), esc(title)))
    t.append(paras + extra)
    t.append("</div>" + (fb_box(sid) if feedback else "") + "</div></section>")
    return "".join(t)


CSS = r'''
  html, body { height:100%; }
  body { overflow:hidden; }
  .bar { position:fixed; left:0; right:0; top:0; height:46px; display:flex; align-items:center; gap:10px; padding:0 12px; background:var(--card); border-bottom:1px solid var(--line); z-index:5; font-size:14px; }
  .bar b { white-space:nowrap; } .bar select { max-width:38vw; font:inherit; padding:4px 6px; background:var(--bg); color:var(--ink); border:1px solid var(--line); border-radius:6px; }
  .bar .sp { flex:1; } .bar .cnt { color:var(--soft); white-space:nowrap; }
  button { font:inherit; padding:5px 11px; border-radius:6px; border:1px solid var(--line); background:var(--bg); color:var(--ink); cursor:pointer; }
  button:hover { border-color:var(--soft); } button.on, button.pri { background:var(--ink); color:var(--bg); border-color:var(--ink); }
  .prog { position:fixed; left:0; top:46px; height:3px; background:var(--red); z-index:6; transition:width .15s; }
  .nav { position:fixed; left:0; right:0; bottom:0; height:44px; display:flex; align-items:center; justify-content:space-between; padding:0 12px; background:var(--card); border-top:1px solid var(--line); z-index:5; font-size:14px; }
  .nav .where { color:var(--soft); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; padding:0 10px; }
  .slide { position:fixed; left:0; right:0; top:49px; bottom:44px; display:none; }
  .slide.cur { display:flex; }
  .stage { flex:1.15; min-width:0; display:flex; flex-direction:column; background:#17120f; }
  .views { flex:1; min-height:0; padding:10px; }
  .view { width:100%; height:100%; } .view[hidden] { display:none; }
  .view .sk { width:100%; height:100%; border:0; border-radius:0; background:transparent; }
  .vt { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:6px 10px; background:#211d1a; color:#d8cfc3; font-size:12.5px; }
  .vt button { background:#2b2520; color:#f1eadf; border-color:#4a4038; padding:3px 9px; } .vt button.on { background:#f1eadf; color:#1f1a17; }
  .vt .kk i { display:inline-block; width:11px; height:11px; border-radius:2px; vertical-align:-1px; margin:0 4px 0 10px; }
  .talk { flex:1; min-width:0; display:flex; flex-direction:column; border-left:1px solid var(--line); background:var(--bg); }
  .talk.wide { max-width:900px; margin:0 auto; border-left:0; }
  .scroll { flex:1; min-height:0; overflow-y:auto; padding:16px 22px 22px; }
  .crumb { color:var(--soft); font-size:13px; letter-spacing:.03em; margin:0 0 2px; }
  .slide h1 { font-size:27px; margin:0 0 8px; line-height:1.2; }
  .slide h2 { font-size:13px; letter-spacing:.07em; text-transform:uppercase; color:var(--red); margin:22px 0 6px; }
  .slide h3 { font-size:14px; margin:12px 0 2px; }
  .hook { font-size:19px; line-height:1.45; margin:6px 0 10px; }
  h3.l-background::before, h3.l-play::before, h3.l-foreground::before { content:""; display:inline-block; width:11px; height:11px; border-radius:2px; margin-right:7px; vertical-align:-1px; }
  h3.l-background::before { background:#4f6076; } h3.l-play::before { background:#ffe08a; border:1px solid #7a4b00; } h3.l-foreground::before { background:#d05cc4; }
  ul.items { list-style:none; padding-left:0; } ul.items li { margin:5px 0; }
  .toc { columns:2; } .toc a { color:var(--blue); }
  details { margin:6px 0; } summary { cursor:pointer; color:var(--blue); }
  .talk table { font-size:14px; }
  .fb { border-top:2px solid var(--red); background:var(--card); padding:8px 14px 10px; }
  .fbh { display:flex; align-items:center; gap:8px; flex-wrap:wrap; font-size:14px; margin-bottom:6px; }
  .verd button { padding:3px 9px; font-size:13px; } .verd button.on { background:var(--green); border-color:var(--green); color:#fff; }
  .saved { color:var(--soft); font-size:12.5px; margin-left:auto; }
  .fb textarea { width:100%; height:92px; resize:vertical; font:15px/1.45 "Segoe UI", system-ui, sans-serif; padding:8px 10px; border:1px solid var(--line); border-radius:6px; background:var(--bg); color:var(--ink); }
  .win { fill:none; stroke:#ffffff; stroke-width:1.3; opacity:.8; }
  .wl rect { fill:#fffdf8; stroke:#1a1310; } .wl text { fill:#1a1310; font:bold 11px "Segoe UI", sans-serif; text-anchor:middle; }
  .warnbox { border:1px solid var(--red); border-radius:8px; padding:8px 12px; margin:10px 0; }
  .out { width:100%; height:220px; font:13px/1.4 Consolas, monospace; padding:8px; border:1px solid var(--line); border-radius:6px; background:var(--card); color:var(--ink); }
  @media (max-width: 900px) {
    body { overflow:auto; } .slide { position:static; display:none; margin:52px 0 50px; } .slide.cur { display:block; }
    .stage { height:62vh; } .talk { border-left:0; } .scroll { overflow:visible; } .toc { columns:1; } .bar select { max-width:46vw; }
  }
'''

JS = r'''
(function () {
  var KEY = "peak-pitch-feedback-v1";
  var store = {}, canSave = true;
  try { store = JSON.parse(localStorage.getItem(KEY) || "{}"); } catch (e) { canSave = false; }
  var slides = Array.prototype.slice.call(document.querySelectorAll(".slide"));
  var sel = document.getElementById("jump"), cnt = document.getElementById("cnt"), where = document.getElementById("where"), prog = document.getElementById("prog"), fbn = document.getElementById("fbn");
  var cur = 0;
  function has(id) { var f = store[id]; return f && ((f.text && f.text.trim()) || f.verdict); }
  function save() { if (!canSave) return; try { localStorage.setItem(KEY, JSON.stringify(store)); } catch (e) { canSave = false; } }
  function label(i) { var s = slides[i]; return (has(s.dataset.id) ? "✓ " : "   ") + s.dataset.title; }
  function buildMenu() {
    sel.innerHTML = ""; var group = null, og = null;
    slides.forEach(function (s, i) {
      if (s.dataset.group !== group) { group = s.dataset.group; og = document.createElement("optgroup"); og.label = group; sel.appendChild(og); }
      var o = document.createElement("option"); o.value = i; o.textContent = label(i); og.appendChild(o);
    });
    sel.value = cur;
  }
  function count() { var n = slides.filter(function (s) { return has(s.dataset.id); }).length; fbn.textContent = "feedback on " + n + " of " + slides.length + " slides" + (canSave ? "" : " (NOT being saved here)"); }
  function show(i) {
    i = Math.max(0, Math.min(slides.length - 1, i));
    slides[cur].classList.remove("cur"); cur = i; slides[cur].classList.add("cur");
    sel.value = cur; cnt.textContent = (cur + 1) + " / " + slides.length; where.textContent = slides[cur].dataset.group + "  ·  " + slides[cur].dataset.title;
    prog.style.width = (100 * (cur + 1) / slides.length) + "%";
    try { history.replaceState(null, "", "#" + (cur + 1)); } catch (e) {}
    var sc = slides[cur].querySelector(".scroll"); if (sc) sc.scrollTop = 0; window.scrollTo(0, 0);
    if (slides[cur].dataset.id === "the end") fillOut();
  }
  function fillOut() { var o = document.getElementById("out"); if (o) o.value = exportText(); }
  function exportText() {
    var lines = ["# Parker's feedback on the pitch: the first seven biomes of the Peak", "", "Saved " + new Date().toString(), ""], group = null, n = 0;
    slides.forEach(function (s, i) {
      var id = s.dataset.id; if (!has(id)) return; n++;
      if (s.dataset.group !== group) { group = s.dataset.group; lines.push("## " + group, ""); }
      var f = store[id];
      lines.push("### Slide " + (i + 1) + ": " + s.dataset.title, "");
      if (f.verdict) lines.push("Verdict: " + f.verdict, "");
      if (f.text && f.text.trim()) lines.push(f.text.trim(), "");
    });
    var none = slides.filter(function (s) { return !has(s.dataset.id); }).map(function (s) { return s.dataset.title; });
    lines.push("## Slides with no feedback (" + none.length + ")", "", none.join("; "), "");
    return lines.join("\n");
  }
  function download() {
    var b = new Blob([exportText()], { type: "text/markdown" }), a = document.createElement("a");
    a.href = URL.createObjectURL(b); a.download = "peak_pitch_feedback.md"; document.body.appendChild(a); a.click(); a.remove();
  }
  function copyAll(btn) {
    var t = exportText();
    function done() { var old = btn.textContent; btn.textContent = "Copied"; setTimeout(function () { btn.textContent = old; }, 1500); }
    if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(t).then(done, function () { fallback(); }); } else fallback();
    function fallback() { var ta = document.createElement("textarea"); ta.value = t; document.body.appendChild(ta); ta.select(); try { document.execCommand("copy"); done(); } catch (e) {} ta.remove(); }
  }
  // feedback boxes
  Array.prototype.forEach.call(document.querySelectorAll(".fb"), function (box) {
    var id = box.dataset.fb, ta = box.querySelector("textarea"), saved = box.querySelector(".saved"), btns = box.querySelectorAll(".verd button");
    var f = store[id] || {}; ta.value = f.text || "";
    function paint() { var v = (store[id] || {}).verdict; Array.prototype.forEach.call(btns, function (b) { b.classList.toggle("on", b.dataset.v === v); }); }
    function touched() { saved.textContent = canSave ? "saved" : "not saved in this viewer: copy it out before you close"; save(); count(); var o = sel.options[slides.findIndex(function (s) { return s.dataset.id === id; })]; if (o) o.textContent = label(+o.value); }
    ta.addEventListener("input", function () { store[id] = store[id] || {}; store[id].text = ta.value; touched(); });
    Array.prototype.forEach.call(btns, function (b) { b.addEventListener("click", function () { store[id] = store[id] || {}; store[id].verdict = store[id].verdict === b.dataset.v ? "" : b.dataset.v; paint(); touched(); }); });
    paint();
  });
  // side / from above
  Array.prototype.forEach.call(document.querySelectorAll(".vt button[data-show]"), function (b) {
    b.addEventListener("click", function () {
      var st = b.closest(".stage");
      Array.prototype.forEach.call(st.querySelectorAll(".view"), function (v) { v.hidden = v.dataset.view !== b.dataset.show; });
      Array.prototype.forEach.call(st.querySelectorAll(".vt button[data-show]"), function (x) { x.classList.toggle("on", x === b); });
    });
  });
  document.addEventListener("click", function (e) {
    var go = e.target.closest("[data-go]");
    if (go) { e.preventDefault(); var i = slides.findIndex(function (s) { return s.dataset.id === go.dataset.go; }); if (i >= 0) show(i); }
    if (e.target.closest("[data-act=prev]")) show(cur - 1);
    if (e.target.closest("[data-act=next]")) show(cur + 1);
    if (e.target.closest("[data-act=save]")) download();
    var c = e.target.closest("[data-act=copy]"); if (c) copyAll(c);
  });
  sel.addEventListener("change", function () { show(+sel.value); sel.blur(); });
  document.addEventListener("keydown", function (e) {
    var t = e.target.tagName; if (t === "TEXTAREA" || t === "INPUT" || t === "SELECT") return;
    if (e.key === "ArrowRight" || e.key === "PageDown") { show(cur + 1); e.preventDefault(); }
    if (e.key === "ArrowLeft" || e.key === "PageUp") { show(cur - 1); e.preventDefault(); }
    if (e.key === "Home") show(0); if (e.key === "End") show(slides.length - 1);
  });
  window.addEventListener("hashchange", function () { var n = parseInt((location.hash || "").slice(1), 10); if (!isNaN(n) && n - 1 !== cur) show(n - 1); });
  if (!canSave) { var w = document.getElementById("nosave"); if (w) w.hidden = false; }
  buildMenu(); count();
  var h = parseInt((location.hash || "").slice(1), 10); slides[0].classList.add("cur"); show(isNaN(h) ? 0 : h - 1);
})();
'''


def main():
    P = B.load("pitch")
    slides, n_areas = [], 0
    data = []
    for bid in B.BIOMES:
        bm = B.load(bid + "_biome")
        if bm is None:
            continue
        am = B.load(bid + "_areas")
        areas = list(getattr(am, "AREAS", [])) if am else []
        if am and getattr(am, "KIT_MORE", None):
            bm.BIOME["kit"] = list(bm.BIOME.get("kit", [])) + [list(r) for r in am.KIT_MORE]
        data.append((bid, bm.BIOME, areas))
        n_areas += len(areas)

    slides.append(text_slide("opening", P.TITLE, P.SUB, "".join('<p class="hook">%s</p>' % esc(P.OPENING[0]) if i == 0 else "<p>%s</p>" % esc(p) for i, p in enumerate(P.OPENING)),
                             '<div id="nosave" class="warnbox" hidden><b>This viewer cannot save your feedback.</b> Open this file in your own browser (Chrome, Edge or Firefox) so what you type is kept.</div>'
                             "<h2>How to use this</h2>" + ul(P.HOWTO) + "<h2>What you should know before you judge it</h2>" + ul(P.CAVEATS) +
                             '<h2>What is in it</h2><ol class="toc">%s</ol>' % "".join('<li><a href="#" data-go="biome %s">%s</a> (%d places)</li>' % (bid[1:], esc(Bm["name"]), len(ar)) for bid, Bm, ar in data)))
    slides.append(text_slide("the rules", "The ten rules every slide follows", "Before the biomes",
                             '<p class="hook">These hold on the whole mountain. The second one is yours, from 11-13. If you disagree with any of them, say so here and I will change every slide it touches.</p>',
                             "<ol>%s</ol>" % "".join("<li>%s</li>" % esc(r) for r in B.RULES)))
    for bid, Bm, areas in data:
        c = B.course(bid)
        pal = B.META["palettes"].get(c.get("palette", ""), {})
        slides.append(biome_slide(bid, Bm, areas, P.PITCH.get(bid, "")))
        for k, a in enumerate(areas, 1):
            slides.append(area_slide(a, bid, Bm, c, pal, k, len(areas)))
    slides.append(text_slide("the end", "That is the pitch", "The last slide",
                             "".join('<p class="hook">%s</p>' % esc(P.CLOSING[0]) if i == 0 else "<p>%s</p>" % esc(p) for i, p in enumerate(P.CLOSING)),
                             '<h2>Hand your feedback back</h2><p><button class="pri" data-act="save">Save all my feedback as a file</button> <button data-act="copy">Copy all my feedback</button></p>'
                             '<p class="sub">The file is called peak_pitch_feedback.md and goes to your downloads folder. Give me the file, or paste what you copied into our chat. Here is what it holds right now:</p>'
                             '<textarea id="out" class="out" readonly></textarea>', feedback=True))

    body = ('<div class="bar"><b>The Peak: the pitch</b><select id="jump" aria-label="Jump to a slide"></select><span class="cnt" id="cnt"></span><span class="sp"></span>'
            '<span class="cnt" id="fbn"></span><button data-act="copy">Copy feedback</button><button class="pri" data-act="save">Save feedback</button></div><div class="prog" id="prog"></div>'
            + "\n".join(slides) +
            '<div class="nav"><button data-act="prev">&larr; Back</button><span class="where" id="where"></span><button class="pri" data-act="next">Next &rarr;</button></div>')
    html = ('<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n'
            '<title>The Peak: the pitch for the first seven biomes</title>\n<style>%s%s</style>\n</head>\n<body>\n%s\n<script>%s</script>\n</body>\n</html>\n' % (B.CSS, CSS, body, JS))
    out = os.path.join(HERE, "PITCH.html")
    io.open(out, "w", encoding="utf-8", newline="\n").write(html)
    print("wrote", out, "%d slides (%d biomes, %d places), %.1f MB" % (len(slides), len(data), n_areas, len(html.encode("utf-8")) / 1e6))


if __name__ == "__main__":
    main()
