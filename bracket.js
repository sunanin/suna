/*
 * 砂 Suna Dienstplan – Turnierbaum (nur für Administratoren)
 *
 * Einfaches K.-o.-System: 1v1 bis 10v10. Bei 1v1 treten Einzelspieler an, ab 2v2
 * werden Teams mit Mitgliedern angelegt. Der Sieger eines Kampfes wird bestätigt
 * und kommt in die nächste Runde. Bei ungeraden Teilnehmerzahlen gibt es Freilose.
 *
 * Gespeichert wird über die Datenbankfunktion suna_bracket() (supabase_bracket.sql),
 * die nur angemeldete Administratoren durchlässt.
 */
(function () {
  "use strict";

  /* ======================= Logik (ohne Oberfläche) ======================= */
  const MAX_ENTRANTS = 32;
  const MAX_SIZE = 10;
  const clampN = (n, a, b) => Math.min(b, Math.max(a, n));
  const S = (v, n) => (typeof v === "string" ? v : v == null ? "" : String(v)).slice(0, n);
  const fold = (v) => String(v || "").trim().replace(/\s+/g, " ").toLowerCase().normalize("NFD").replace(/\p{M}/gu, "");
  const pow2 = (n) => { let p = 1; while (p < n) p *= 2; return p; };
  const log2 = (p) => Math.round(Math.log2(p));
  const bitrev = (i, bits) => { let r = 0; for (let k = 0; k < bits; k++) r = (r << 1) | ((i >> k) & 1); return r; };

  const roundName = (R, r) => {
    const d = R - 1 - r;
    return d === 0 ? "Finale" : d === 1 ? "Halbfinale" : d === 2 ? "Viertelfinale" : d === 3 ? "Achtelfinale" : "Runde " + (r + 1);
  };

  function newId(t) {
    let max = 0;
    t.entrants.forEach((e) => { const m = /^e(\d+)/.exec(e.id); if (m) max = Math.max(max, +m[1]); });
    return "e" + (max + 1);
  }
  function emptyEntrant(t) {
    return { id: newId(t), name: "", members: t.size > 1 ? Array(t.size).fill("") : [] };
  }
  function create(name, size) {
    const t = { v: 1, name: S(name, 60), size: clampN(parseInt(size, 10) || 1, 1, MAX_SIZE), entrants: [], rounds: null, created: new Date().toISOString() };
    for (let i = 0; i < 4; i++) t.entrants.push(emptyEntrant(t));
    return t;
  }

  // Prüft und bereinigt gespeicherte Daten (ungültige Turnierbäume werden verworfen)
  function norm(d) {
    d = d && typeof d === "object" ? d : {};
    const size = clampN(parseInt(d.size, 10) || 1, 1, MAX_SIZE);
    const seen = new Set();
    const ents = [];
    (Array.isArray(d.entrants) ? d.entrants : []).slice(0, MAX_ENTRANTS).forEach((e, i) => {
      e = e && typeof e === "object" ? e : {};
      let id = S(e.id, 12) || "e" + (i + 1);
      while (seen.has(id)) id += "x";
      seen.add(id);
      const mem = size > 1 ? (Array.isArray(e.members) ? e.members : []).slice(0, size).map((x) => S(x, 40)) : [];
      while (size > 1 && mem.length < size) mem.push("");
      ents.push({ id, name: S(e.name, 40), members: mem });
    });
    const t = { v: 1, name: S(d.name, 60), size, entrants: ents, rounds: null, created: S(d.created, 40) };
    if (Array.isArray(d.rounds) && ents.length >= 2) {
      const P = pow2(ents.length), R = log2(P);
      const okId = (x) => x === null || (typeof x === "string" && seen.has(x));
      let good = d.rounds.length === R;
      for (let r = 0; good && r < R; r++) {
        const row = d.rounds[r];
        good = Array.isArray(row) && row.length === P >> (r + 1) && row.every((m) => m && okId(m.a) && okId(m.b) && okId(m.w));
      }
      if (good) {
        t.rounds = d.rounds.map((row) => row.map((m) => ({ a: m.a, b: m.b, w: m.w === m.a || m.w === m.b ? m.w : null })));
      }
    }
    return t;
  }

  const entMap = (t) => { const o = {}; t.entrants.forEach((e) => { o[e.id] = e; }); return o; };
  const isBye = (t, r, m) => { const mt = t.rounds[r][m]; return r === 0 && (mt.a == null || mt.b == null); };
  const place = (rounds, r, m, id) => { if (r + 1 < rounds.length) rounds[r + 1][m >> 1][m & 1 ? "b" : "a"] = id; };

  // Erzeugt die Runden aus der Teilnehmerliste. Die Liste wird der Reihe nach gepaart (1 gegen 2, 3 gegen 4 …).
  // Freilose werden auf die erste Runde verteilt (oben und unten abwechselnd), nie zwei Freilose in einem Kampf.
  function build(t) {
    const n = t.entrants.length;
    const P = pow2(n), half = P / 2, R = log2(P);
    const bits = log2(half);
    const byes = new Set();
    for (let i = 0; i < P - n; i++) byes.add(bitrev(i, bits));
    const r0 = [];
    let idx = 0;
    for (let m = 0; m < half; m++) {
      if (byes.has(m)) { const e = t.entrants[idx++]; r0.push({ a: e.id, b: null, w: e.id }); }
      else { const a = t.entrants[idx++], b = t.entrants[idx++]; r0.push({ a: a.id, b: b.id, w: null }); }
    }
    const rounds = [r0];
    for (let r = 1; r < R; r++) rounds.push(Array.from({ length: P >> (r + 1) }, () => ({ a: null, b: null, w: null })));
    r0.forEach((mt, m) => { if (mt.w) place(rounds, 0, m, mt.w); });
    t.rounds = rounds;
    return t;
  }

  // Sieger bestätigen. Wer schon einen anderen Sieger hatte, setzt alles Spätere zurück.
  function setWinner(t, r, m, id) {
    const mt = t.rounds && t.rounds[r] && t.rounds[r][m];
    if (!mt || !mt.a || !mt.b || (id !== mt.a && id !== mt.b)) return false;
    if (mt.w === id) return true;
    if (mt.w) clearWinner(t, r, m);
    mt.w = id;
    place(t.rounds, r, m, id);
    return true;
  }
  // Ergebnis zurücknehmen; Kämpfe in späteren Runden, die davon abhängen, werden ebenfalls zurückgesetzt.
  function clearWinner(t, r, m) {
    const mt = t.rounds[r][m];
    if (!mt.w || isBye(t, r, m)) return;
    mt.w = null;
    if (r + 1 < t.rounds.length) {
      const nx = t.rounds[r + 1][m >> 1];
      nx[m & 1 ? "b" : "a"] = null;
      clearWinner(t, r + 1, m >> 1);
    }
  }
  const downstreamDecided = (t, r, m) => r + 1 < t.rounds.length && !!t.rounds[r + 1][m >> 1].w;
  function champion(t) {
    if (!t.rounds) return null;
    const f = t.rounds[t.rounds.length - 1][0];
    return f && f.w ? entMap(t)[f.w] || null : null;
  }
  function progress(t) {
    let done = 0, total = 0;
    if (t.rounds) t.rounds.forEach((row, r) => row.forEach((mt, m) => { if (!isBye(t, r, m)) { total++; if (mt.w) done++; } }));
    return { done, total };
  }
  const stateOf = (t) => (!t.rounds ? "setup" : champion(t) ? "done" : "run");
  const entLabel = (t, e, i) => e.name.trim() || (t.size > 1 ? "Team " + (i + 1) : "");

  function shuffle(list, rnd) {
    rnd = rnd || Math.random;
    for (let i = list.length - 1; i > 0; i--) { const j = Math.floor(rnd() * (i + 1)); const x = list[i]; list[i] = list[j]; list[j] = x; }
    return list;
  }

  // Vor dem Start: Fehler (blockieren) und Hinweise
  function check(t) {
    const errors = [], warnings = [];
    const n = t.entrants.length;
    if (n < 2) errors.push("Für einen Turnierbaum braucht es mindestens 2 " + (t.size > 1 ? "Teams" : "Teilnehmer") + ".");
    const names = new Map();
    const people = new Map();
    t.entrants.forEach((e, i) => {
      const lab = entLabel(t, e, i);
      if (!lab) { errors.push("Teilnehmer " + (i + 1) + " hat noch keinen Namen."); return; }
      const k = fold(lab);
      if (names.has(k)) errors.push("„" + lab + "“ kommt doppelt vor.");
      names.set(k, true);
      if (t.size > 1) {
        const filled = e.members.map((x) => x.trim()).filter(Boolean);
        if (!filled.length) errors.push("„" + lab + "“ hat noch kein Mitglied.");
        else if (filled.length < t.size) warnings.push("„" + lab + "“ hat nur " + filled.length + " von " + t.size + " Mitgliedern.");
        const inTeam = new Set();
        filled.forEach((p) => {
          const pk = fold(p);
          if (inTeam.has(pk)) errors.push("„" + p + "“ steht zweimal in „" + lab + "“.");
          inTeam.add(pk);
          if (people.has(pk) && people.get(pk) !== lab) errors.push("„" + p + "“ steht in „" + people.get(pk) + "“ und in „" + lab + "“.");
          else people.set(pk, lab);
        });
      } else if (people.has(k)) { /* schon als doppelter Name gemeldet */ }
    });
    return { errors, warnings };
  }
  // Leere Teamnamen mit "Team N" füllen
  function fillNames(t) { t.entrants.forEach((e, i) => { if (!e.name.trim() && t.size > 1) e.name = "Team " + (i + 1); e.name = e.name.trim(); e.members = e.members.map((x) => x.trim()); }); }

  const L = { MAX_ENTRANTS, MAX_SIZE, pow2, log2, roundName, create, norm, build, setWinner, clearWinner, downstreamDecided, champion, progress, stateOf, isBye, entMap, emptyEntrant, shuffle, check, fillNames, fold, entLabel };

  if (typeof window === "undefined" || !window.document) {
    if (typeof module !== "undefined") module.exports = L;
    return;
  }

  /* ======================= Oberfläche ======================= */
  const A = () => window.SUNA_APP;
  const esc = (s) => String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const root = () => document.getElementById("bt-root");
  const St = { items: null, loading: false, error: "", open: null, who: null, err: "", sl: 0 };

  const CSS = `
.bt{display:grid;gap:16px}
.bt > *{min-width:0}
.bt-top{display:flex;flex-wrap:wrap;align-items:center;gap:8px 12px}
.bt-state{font-size:13px;color:var(--ink-soft)}
.bt-state.err{color:var(--danger);font-weight:500}
.bt-list{display:grid;gap:10px;margin:0;padding:0;list-style:none}
.bt-item{display:flex;flex-wrap:wrap;align-items:center;gap:8px 14px;padding:12px 14px;background:var(--paper);border:1px solid var(--line);border-radius:8px;box-shadow:var(--shadow)}
.bt-it{flex:1 1 220px;min-width:0}
.bt-it b{display:block;font-family:var(--f-display);font-weight:800;font-size:17px;overflow:hidden;text-overflow:ellipsis}
.bt-it small{display:block;font-size:13px;color:var(--ink-soft)}
.bt-badge{display:inline-block;padding:2px 10px;border-radius:99px;font-size:12px;font-weight:700;white-space:nowrap;border:1px solid var(--line);color:var(--ink)}
.bt-badge.run{background:var(--clay);border-color:var(--clay);color:var(--clay-ink)}
.bt-badge.done{background:var(--band);border-color:var(--band);color:var(--band-ink)}
.bt-fmt{font-family:var(--f-display);font-weight:800;letter-spacing:.06em}
.bt-ents{display:grid;gap:12px;grid-template-columns:repeat(auto-fill,minmax(250px,1fr))}
.bt-body{display:grid;gap:8px;padding:12px}
.bt-solo{display:grid;grid-template-columns:30px minmax(0,1fr) 36px;align-items:center;gap:8px}
.bt-solo .no{font-weight:700;font-variant-numeric:tabular-nums;color:var(--ink-soft);text-align:center}
.bt-body .m-input{min-width:0}
.bt-ent .head-btn:disabled{opacity:.35;cursor:not-allowed}
.bt-actions{display:flex;flex-wrap:wrap;gap:8px}
.bt-info{margin:0;font-size:13px;color:var(--ink-soft)}
.bt-champ{display:flex;flex-wrap:wrap;align-items:center;gap:6px 14px;padding:14px 18px;border-radius:8px;border:1px solid var(--clay);background:var(--clay);color:var(--clay-ink);box-shadow:var(--shadow)}
.bt-champ .st{font-size:26px;line-height:1}
.bt-champ small{display:block;font-size:12px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;opacity:.85}
.bt-champ b{display:block;font-family:var(--f-display);font-weight:800;font-size:21px;letter-spacing:.03em}
.bt-champ span.m{font-size:13px;opacity:.9}
.bt-card .scroll{padding:18px 16px}
.bt-tree{display:inline-block;min-width:min-content}
.bt-node{display:flex;align-items:center;position:relative}
.bt-kids{display:flex;flex-direction:column}
.bt-self{position:relative;padding:6px 0}
.bt-self.has-par{padding-right:24px}
.bt-self.has-kids{padding-left:24px}
.bt-self.has-par::after{content:"";position:absolute;right:0;top:50%;width:24px;border-top:2px solid var(--line)}
.bt-self.has-kids::before{content:"";position:absolute;left:0;top:50%;width:24px;border-top:2px solid var(--line)}
.bt-kids > .bt-node:first-child::after{content:"";position:absolute;right:0;top:50%;bottom:0;border-right:2px solid var(--line)}
.bt-kids > .bt-node:last-child::after{content:"";position:absolute;right:0;top:0;bottom:50%;border-right:2px solid var(--line)}
.bt-m{width:238px;background:var(--paper);border:1px solid var(--line);border-radius:6px;box-shadow:var(--shadow);overflow:hidden}
.bt-mh{display:flex;align-items:center;justify-content:space-between;gap:6px;min-height:22px;padding:2px 8px;font-size:11px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;background:var(--band);color:var(--band-ink)}
.bt-x{padding:0 6px;font:inherit;font-size:11px;font-weight:700;letter-spacing:.04em;text-transform:none;color:var(--band-ink);background:transparent;border:1px solid color-mix(in srgb,var(--band-ink) 35%,transparent);border-radius:4px;cursor:pointer}
.bt-x:hover{background:color-mix(in srgb,var(--band-ink) 14%,transparent)}
.bt-s{display:flex;align-items:center;gap:8px;height:var(--bt-sh,38px);padding:0 8px 0 10px;border-top:1px solid var(--line)}
.bt-s .bt-n{flex:1;min-width:0;line-height:1.25}
.bt-s .bt-n b{display:block;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bt-s .bt-n small{display:block;font-size:12px;color:var(--ink-soft);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bt-s.empty .bt-n{font-style:italic;color:var(--ink-soft);font-size:13px}
.bt-s.win{background:var(--tf);color:var(--tf-ink)}
.bt-s.win .bt-n small{color:inherit;opacity:.8}
.bt-s.lose{opacity:.55}
.bt-ck{color:var(--star);font-size:16px}
.bt-pick{padding:4px 10px;font-size:12px;font-weight:700}
.bt-m.bye .bt-s{background:transparent}
.bt-m.bye{box-shadow:none;border-style:dashed}
.bt-tag{font-size:11px;font-weight:700;letter-spacing:.05em;text-transform:uppercase;color:var(--ink-soft)}
@media (max-width:560px){.bt-ents{grid-template-columns:1fr}.bt-m{width:210px}}
`;
  function injectCss() {
    if (document.getElementById("bt-style")) return;
    const st = document.createElement("style");
    st.id = "bt-style";
    st.textContent = CSS;
    document.head.appendChild(st);
  }

  /* ---------- Server ---------- */
  async function call(a, body) {
    const app = A();
    const sb = app.sb;
    if (!sb.ready) return { status: 0, body: { message: "Die Seite ist noch nicht mit Supabase verbunden." } };
    try {
      const res = await fetch(sb.url + "/rest/v1/rpc/suna_bracket", {
        method: "POST", cache: "no-store",
        headers: { "Content-Type": "application/json", apikey: sb.key },
        body: JSON.stringify({ a, body: body || {}, tok: app.getTok() || null })
      });
      let data = null;
      try { data = await res.json(); } catch (e) {}
      if (!res.ok || !data || typeof data.status !== "number") {
        const miss = res.status === 404 || (data && /find the function|suna_bracket/i.test(String(data.message || "")));
        return { status: res.status || 0, body: { message: miss ? "Die Datenbank-Erweiterung fehlt noch. Führe supabase_bracket.sql im Supabase SQL-Editor aus." : (data && data.message) || "Serverfehler" } };
      }
      return { status: data.status, body: data.body && typeof data.body === "object" ? data.body : {} };
    } catch (e) {
      return { status: 0, body: { message: "Keine Verbindung zum Server." } };
    }
  }

  async function load() {
    St.loading = true; St.error = "";
    render();
    const r = await call("list");
    St.loading = false;
    if (r.status === 200) St.items = (r.body.items || []).map((i) => ({ id: i.id, t: norm(i.data), updated: i.updated, state: "saved", saving: false, again: false, timer: 0, err: "" }));
    else {
      St.items = [];
      St.error = r.body.message || "Die Turniere konnten nicht geladen werden.";
      if (r.status === 401) A().sessionLost();
    }
    render();
  }

  const cur = () => (St.items || []).find((x) => x.id === St.open) || null;

  function paintState() {
    const el = document.getElementById("bt-state");
    const it = cur();
    if (!el || !it) return;
    el.className = "bt-state" + (it.state === "error" ? " err" : "");
    el.textContent = it.state === "saving" ? "Speichert …" : it.state === "dirty" ? "Ungespeicherte Änderungen …" : it.state === "error" ? "Nicht gespeichert: " + (it.err || "Fehler") : "Gespeichert";
  }
  function queueSave(it, delay) {
    clearTimeout(it.timer);
    it.state = "dirty";
    paintState();
    it.timer = setTimeout(() => flush(it), delay);
  }
  async function flush(it) {
    if (it.saving) { it.again = true; return; }
    it.saving = true; it.state = "saving"; paintState();
    const r = await call("save", { id: it.id, data: it.t });
    it.saving = false;
    if (r.status === 200) { it.state = it.again ? "dirty" : "saved"; it.err = ""; }
    else { it.state = "error"; it.err = r.body.message || "Fehler"; if (r.status === 401) A().sessionLost(); }
    paintState();
    if (it.again) { it.again = false; flush(it); }
  }

  /* ---------- Bestätigungsfenster im Stil der Seite ---------- */
  function closeDlg() { const d = document.getElementById("bt-dlg"); if (d) d.remove(); }
  function dlg(o) {
    closeDlg();
    const el = document.createElement("div");
    el.id = "bt-dlg";
    el.className = "modal-back";
    el.innerHTML = `<div class="modal" role="dialog" aria-modal="true" aria-labelledby="bt-dlg-t"><h3 id="bt-dlg-t">${esc(o.title)}</h3><p>${esc(o.text)}</p>${o.extra ? `<p>${esc(o.extra)}</p>` : ""}<div class="modal-btns"><button class="btn" type="button" data-bd="no">Abbrechen</button><button class="btn ${o.danger ? "danger-solid" : "primary"}" type="button" data-bd="ok">${esc(o.ok)}</button></div></div>`;
    document.body.appendChild(el);
    el.addEventListener("click", (e) => {
      const b = e.target.closest("[data-bd]");
      if (e.target === el || (b && b.dataset.bd === "no")) return closeDlg();
      if (b && b.dataset.bd === "ok") { closeDlg(); o.run(); }
    });
    const ok = el.querySelector('[data-bd="ok"]');
    if (ok) ok.focus();
  }

  /* ---------- Darstellung ---------- */
  const fmtLabel = (t) => t.size + "v" + t.size;
  const unit = (t, n) => (t.size > 1 ? (n === 1 ? "Team" : "Teams") : n === 1 ? "Teilnehmer" : "Teilnehmer");

  function stateBadge(t) {
    const s = stateOf(t);
    if (s === "done") return '<span class="bt-badge done">Beendet</span>';
    if (s === "run") return '<span class="bt-badge run">Läuft</span>';
    return '<span class="bt-badge">Einrichtung</span>';
  }

  function listHtml() {
    const opts = Array.from({ length: MAX_SIZE }, (_, i) => `<option value="${i + 1}"${i === 0 ? " selected" : ""}>${i + 1}v${i + 1}${i === 0 ? " (Einzelkampf)" : " (Teams)"}</option>`).join("");
    let items = "";
    if (St.loading || St.items === null) items = '<p class="empty">Lädt …</p>';
    else if (!St.items.length) items = '<p class="empty">Noch keine Turniere. Lege oben das erste an.</p>';
    else {
      items = '<ul class="bt-list">' + St.items.map((it) => {
        const t = it.t, n = t.entrants.length, c = champion(t), p = progress(t);
        const sub = `<span class="bt-fmt">${fmtLabel(t)}</span> · ${n} ${unit(t, n)}` + (t.rounds ? ` · ${p.done}/${p.total} Kämpfe entschieden` : "") + (c ? ` · Sieger: ${esc(c.name)}` : "");
        return `<li class="bt-item"><div class="bt-it"><b>${esc(t.name.trim() || "Ohne Namen")}</b><small>${sub}</small></div>${stateBadge(t)}<button class="btn primary" type="button" data-bt="open" data-id="${it.id}">Öffnen</button><button class="btn danger" type="button" data-bt="del-open" data-id="${it.id}">Löschen</button></li>`;
      }).join("") + "</ul>";
    }
    return `<section class="mpanel bt" aria-labelledby="bt-title">
      <div class="m-head"><h2 id="bt-title">Turnierbaum</h2><p>Erstelle K.-o.-Turniere von 1v1 bis 10v10. Nur du und andere Admins sehen diesen Bereich.</p></div>
      <form class="m-add" id="bt-new-form" data-bt-form="new">
        <label class="field grow" for="bt-new-name">Name des Turniers<input id="bt-new-name" maxlength="60" placeholder="z. B. Frühjahrsturnier" autocomplete="off"></label>
        <label class="field" for="bt-new-size">Format<select id="bt-new-size">${opts}</select></label>
        <button class="btn primary" type="submit">Turnier anlegen</button>
      </form>
      ${St.error ? `<p class="login-err" role="alert">${esc(St.error)}</p>` : ""}
      ${items}
    </section>`;
  }

  function infoText(t) {
    const n = t.entrants.length;
    if (n < 2) return "Für einen Turnierbaum braucht es mindestens 2 " + (t.size > 1 ? "Teams" : "Teilnehmer") + ".";
    const P = pow2(n), R = log2(P), by = P - n;
    return `${n} ${unit(t, n)} → ${R} ${R === 1 ? "Runde" : "Runden"} (${Array.from({ length: R }, (_, r) => roundName(R, r)).join(", ")})` + (by ? `. ${by} ${by === 1 ? "Freilos" : "Freilose"} in der ersten Runde.` : ".");
  }

  function setupHtml(it) {
    const t = it.t;
    const n = t.entrants.length;
    const sizeOpts = Array.from({ length: MAX_SIZE }, (_, i) => `<option value="${i + 1}"${t.size === i + 1 ? " selected" : ""}>${i + 1}v${i + 1}</option>`).join("");
    const members = (A().members() || []).map((m) => `<option value="${esc(m)}"></option>`).join("");
    let ents;
    if (t.size === 1) {
      ents = `<div class="card bt-ent"><header class="card-head"><h3>Teilnehmer</h3><span class="fill">${n}</span></header><div class="bt-body">` + t.entrants.map((e, i) =>
        `<div class="bt-solo"><span class="no">${i + 1}</span><input class="m-input" list="bt-members" data-bi="en" data-i="${i}" value="${esc(e.name)}" placeholder="Name eingeben" maxlength="40" autocomplete="off" spellcheck="false" aria-label="Teilnehmer ${i + 1}"><button class="icon-btn" type="button" data-bt="rm" data-i="${i}" aria-label="Teilnehmer ${i + 1} entfernen" title="Entfernen"${n <= 2 ? " disabled" : ""}>✕</button></div>`).join("") + "</div></div>";
    } else {
      ents = '<div class="bt-ents">' + t.entrants.map((e, i) => {
        const filled = e.members.filter((x) => x.trim()).length;
        return `<div class="card bt-ent"><header class="card-head"><h3>${esc(e.name.trim() || "Team " + (i + 1))}</h3><span class="fill" title="Besetzte Plätze">${filled}/${t.size}</span><button class="head-btn" type="button" data-bt="rm" data-i="${i}" aria-label="Team ${i + 1} entfernen" title="Team entfernen"${n <= 2 ? " disabled" : ""}>✕</button></header><div class="bt-body">`
          + `<input class="m-input" data-bi="en" data-i="${i}" value="${esc(e.name)}" placeholder="Teamname (Team ${i + 1})" maxlength="40" autocomplete="off" spellcheck="false" aria-label="Name von Team ${i + 1}">`
          + e.members.map((m, k) => `<input class="m-input" list="bt-members" data-bi="em" data-i="${i}" data-k="${k}" value="${esc(m)}" placeholder="Mitglied ${k + 1}" maxlength="40" autocomplete="off" spellcheck="false" aria-label="Team ${i + 1}: Mitglied ${k + 1}">`).join("")
          + "</div></div>";
      }).join("") + "</div>";
    }
    return `<section class="mpanel bt" aria-label="Turnier einrichten">
      <div class="bt-top"><button class="btn" type="button" data-bt="back">← Alle Turniere</button><span id="bt-state" class="bt-state"></span></div>
      <div class="m-add">
        <label class="field grow" for="bt-name">Name des Turniers<input id="bt-name" data-bi="name" maxlength="60" value="${esc(t.name)}" placeholder="z. B. Frühjahrsturnier" autocomplete="off"></label>
        <label class="field" for="bt-size">Format<select id="bt-size" data-bs="size">${sizeOpts}</select></label>
      </div>
      <p class="bt-info" id="bt-info">${esc(infoText(t))}</p>
      ${ents}
      <datalist id="bt-members">${members}</datalist>
      <p class="login-err" id="bt-err" role="alert"${St.err ? "" : " hidden"}>${esc(St.err)}</p>
      <div class="bt-actions"><button class="btn" type="button" data-bt="add"${n >= MAX_ENTRANTS ? " disabled" : ""}>+ ${t.size > 1 ? "Team" : "Teilnehmer"}</button><button class="btn" type="button" data-bt="shuffle">Zufällig mischen</button><button class="btn primary" type="button" data-bt="start">Turnierbaum erstellen</button></div>
      <p class="bt-info">Die Liste wird von oben nach unten gepaart: Nr. 1 gegen Nr. 2, Nr. 3 gegen Nr. 4 und so weiter. Mit „Zufällig mischen“ losst du neu aus.</p>
    </section>`;
  }

  function matchHtml(t, ents, r, m) {
    const R = t.rounds.length, mt = t.rounds[r][m];
    const bye = isBye(t, r, m);
    const canPick = !!(mt.a && mt.b && !mt.w);
    const side = (id, s) => {
      const e = id ? ents[id] : null;
      if (!e) return `<div class="bt-s empty"><span class="bt-n">${r === 0 ? "Freilos" : "wartet auf Sieger …"}</span></div>`;
      const win = !bye && mt.w === id, lose = !bye && mt.w && mt.w !== id;
      const mem = t.size > 1 ? e.members.filter((x) => x.trim()).join(", ") : "";
      return `<div class="bt-s${win ? " win" : ""}${lose ? " lose" : ""}"><div class="bt-n"><b title="${esc(e.name)}">${esc(e.name)}</b>${t.size > 1 ? `<small title="${esc(mem)}">${esc(mem) || "–"}</small>` : ""}</div>${win ? '<span class="bt-ck" title="Sieger">★</span>' : ""}${bye ? '<span class="bt-tag">weiter</span>' : ""}${canPick ? `<button class="btn bt-pick" type="button" data-bt="winner" data-r="${r}" data-m="${m}" data-s="${s}" aria-label="${esc(e.name)} als Sieger bestätigen">Sieger</button>` : ""}</div>`;
    };
    const head = r === R - 1 ? "Finale" : roundName(R, r) + " · " + (m + 1);
    const back = !bye && mt.w ? `<button class="bt-x" type="button" data-bt="reset-match" data-r="${r}" data-m="${m}" title="Ergebnis zurücknehmen">↺ zurück</button>` : "";
    return `<div class="bt-m${bye ? " bye" : ""}"><div class="bt-mh"><span>${head}</span>${back}</div>${side(mt.a, "a")}${side(mt.b, "b")}</div>`;
  }
  function nodeHtml(t, ents, r, m) {
    const root0 = r === t.rounds.length - 1;
    const kids = r > 0 ? `<div class="bt-kids">${nodeHtml(t, ents, r - 1, 2 * m)}${nodeHtml(t, ents, r - 1, 2 * m + 1)}</div>` : "";
    return `<div class="bt-node">${kids}<div class="bt-self${r > 0 ? " has-kids" : ""}${root0 ? "" : " has-par"}">${matchHtml(t, ents, r, m)}</div></div>`;
  }

  function runHtml(it) {
    const t = it.t, n = t.entrants.length, ents = entMap(t), c = champion(t), p = progress(t);
    const champ = c ? `<div class="bt-champ" role="status"><span class="st" aria-hidden="true">★</span><div><small>Turniersieger</small><b>${esc(c.name)}</b>${t.size > 1 && c.members.some((x) => x.trim()) ? `<span class="m">${esc(c.members.filter((x) => x.trim()).join(", "))}</span>` : ""}</div></div>` : "";
    return `<section class="mpanel bt" aria-label="Turnierbaum">
      <div class="bt-top"><button class="btn" type="button" data-bt="back">← Alle Turniere</button><span id="bt-state" class="bt-state"></span></div>
      <div class="m-head"><h2>${esc(t.name.trim() || "Ohne Namen")}</h2><p><span class="bt-fmt">${fmtLabel(t)}</span> · ${n} ${unit(t, n)} · ${p.done} von ${p.total} Kämpfen entschieden</p></div>
      ${champ}
      <div class="card bt-card"><header class="card-head"><h3>Turnierbaum</h3><span class="fill">${p.done}/${p.total}</span></header><div class="scroll bt-scroll"><div class="bt-tree" style="--bt-sh:${t.size > 1 ? 52 : 38}px">${nodeHtml(t, ents, t.rounds.length - 1, 0)}</div></div></div>
      <p class="legend">Bei jedem Kampf auf „Sieger“ klicken und bestätigen. Der Sieger kommt automatisch in die nächste Runde.</p>
      <div class="bt-actions"><button class="btn" type="button" data-bt="reset-all">Zurück zur Einrichtung</button><button class="btn danger" type="button" data-bt="del-open" data-id="${it.id}">Turnier löschen</button></div>
    </section>`;
  }

  function render() {
    const el = root();
    if (!el) return;
    const sx = window.scrollX, sy = window.scrollY;
    const it = cur();
    el.innerHTML = it ? (it.t.rounds ? runHtml(it) : setupHtml(it)) : listHtml();
    const sc = el.querySelector(".bt-scroll");
    if (sc) sc.scrollLeft = St.sl;
    paintState();
    if (Math.abs(window.scrollY - sy) > 1) window.scrollTo(sx, sy);
  }

  function mount() {
    const el = root();
    if (!el) return;
    const app = A();
    if (!app || !app.isAdmin()) { el.innerHTML = ""; return; }
    injectCss();
    const who = app.user();
    if (St.who !== who) { St.who = who; St.items = null; St.open = null; St.err = ""; }
    if (St.items === null && !St.loading) load(); else render();
  }

  /* ---------- Aktionen ---------- */
  function openIt(id) { St.open = id; St.err = ""; St.sl = 0; render(); window.scrollTo(0, 0); }
  async function createIt(form) {
    const name = form.querySelector("#bt-new-name").value;
    const size = form.querySelector("#bt-new-size").value;
    const t = create(name, size);
    const btn = form.querySelector('button[type="submit"]');
    if (btn) { btn.disabled = true; btn.textContent = "Lege an …"; }
    const r = await call("save", { data: t });
    if (r.status !== 200) {
      St.error = r.body.message || "Das Turnier konnte nicht angelegt werden.";
      if (r.status === 401) A().sessionLost();
      return render();
    }
    St.error = "";
    St.items.unshift({ id: r.body.id, t, updated: null, state: "saved", saving: false, again: false, timer: 0, err: "" });
    openIt(r.body.id);
  }
  function delIt(id) {
    const it = (St.items || []).find((x) => x.id === id);
    if (!it) return;
    dlg({
      title: "Turnier löschen?", text: "„" + (it.t.name.trim() || "Ohne Namen") + "“ wird mit allen Ergebnissen gelöscht. Das lässt sich nicht rückgängig machen.", ok: "Löschen", danger: true,
      run: async () => {
        clearTimeout(it.timer);
        const r = await call("delete", { id });
        if (r.status !== 200) { A().toast(r.body.message || "Löschen hat nicht geklappt."); if (r.status === 401) A().sessionLost(); return; }
        St.items = St.items.filter((x) => x.id !== id);
        if (St.open === id) St.open = null;
        render();
        A().toast("Turnier gelöscht.");
      }
    });
  }
  function changeSize(it, size) {
    const t = it.t;
    if (size === t.size) return;
    const lose = t.entrants.some((e) => e.members.slice(size > 1 ? size : 0).some((x) => x.trim()));
    const apply = () => {
      t.size = size;
      t.entrants.forEach((e) => {
        if (size === 1) e.members = [];
        else { e.members = e.members.slice(0, size); while (e.members.length < size) e.members.push(""); }
      });
      queueSave(it, 0);
      render();
    };
    if (!lose) return apply();
    dlg({ title: "Format ändern?", text: "Beim Wechsel auf " + size + "v" + size + " gehen Mitglieder-Einträge über den neuen Platzbedarf hinaus verloren.", ok: "Format ändern", run: apply });
    render();
  }
  function start(it) {
    const t = it.t;
    const c = check(t);
    St.err = c.errors.slice(0, 4).join(" ") + (c.errors.length > 4 ? " … und " + (c.errors.length - 4) + " weitere." : "");
    if (c.errors.length) { render(); return; }
    const go = () => {
      fillNames(t);
      build(t);
      St.err = "";
      St.sl = 0;
      queueSave(it, 0);
      render();
      A().toast("Turnierbaum erstellt.");
    };
    dlg({
      title: "Turnierbaum erstellen?", text: infoText(t) + " Danach sind die Teilnehmer festgelegt. Über „Zurück zur Einrichtung“ kannst du sie später noch ändern, dabei gehen aber alle Ergebnisse verloren.",
      extra: c.warnings.length ? "Hinweis: " + c.warnings.slice(0, 3).join(" ") + (c.warnings.length > 3 ? " …" : "") : "", ok: "Erstellen", run: go
    });
    render();
  }
  function pick(it, r, m, s) {
    const t = it.t, mt = t.rounds[r][m];
    const id = s === "a" ? mt.a : mt.b;
    const e = id && entMap(t)[id];
    if (!e || !mt.a || !mt.b || mt.w) return;
    const R = t.rounds.length;
    dlg({
      title: "Sieger bestätigen?",
      text: "„" + e.name + "“ gewinnt " + (r === R - 1 ? "das Finale und wird Turniersieger." : roundName(R, r) + " (Kampf " + (m + 1) + ") und kommt in die nächste Runde."),
      ok: "Als Sieger bestätigen",
      run: () => { if (setWinner(t, r, m, id)) { queueSave(it, 0); render(); } }
    });
  }
  function resetMatch(it, r, m) {
    const t = it.t;
    const go = () => { clearWinner(t, r, m); queueSave(it, 0); render(); };
    if (!downstreamDecided(t, r, m)) return go();
    dlg({ title: "Ergebnis zurücknehmen?", text: "Spätere Kämpfe, die von diesem Ergebnis abhängen, werden ebenfalls zurückgesetzt.", ok: "Zurücknehmen", danger: true, run: go });
  }
  function resetAll(it) {
    const t = it.t;
    const go = () => { t.rounds = null; St.err = ""; queueSave(it, 0); render(); };
    if (!progress(t).done) return go();
    dlg({ title: "Zurück zur Einrichtung?", text: "Alle bisherigen Ergebnisse gehen verloren. Danach kannst du Teilnehmer ändern und den Baum neu erstellen.", ok: "Zurücksetzen", danger: true, run: go });
  }

  /* ---------- Ereignisse ---------- */
  document.addEventListener("click", (e) => {
    const b = e.target.closest && e.target.closest("[data-bt]");
    const r0 = root();
    if (!b || !r0 || !r0.contains(b) || b.disabled) return;
    const it = cur();
    const num = (k) => parseInt(b.dataset[k], 10);
    switch (b.dataset.bt) {
      case "open": return openIt(num("id"));
      case "back": St.open = null; St.err = ""; return render();
      case "del-open": return delIt(num("id"));
      case "add": if (it && it.t.entrants.length < MAX_ENTRANTS) { it.t.entrants.push(emptyEntrant(it.t)); queueSave(it, 400); render(); } return;
      case "rm": if (it && it.t.entrants.length > 2) { it.t.entrants.splice(num("i"), 1); queueSave(it, 400); render(); } return;
      case "shuffle": if (it) { shuffle(it.t.entrants); queueSave(it, 400); render(); } return;
      case "start": return it && start(it);
      case "winner": return it && pick(it, num("r"), num("m"), b.dataset.s);
      case "reset-match": return it && resetMatch(it, num("r"), num("m"));
      case "reset-all": return it && resetAll(it);
    }
  });
  document.addEventListener("submit", (e) => {
    if (e.target && e.target.id === "bt-new-form") { e.preventDefault(); createIt(e.target); }
  });
  document.addEventListener("input", (e) => {
    const el = e.target;
    const r0 = root();
    if (!el || !el.dataset || !el.dataset.bi || !r0 || !r0.contains(el)) return;
    const it = cur();
    if (!it) return;
    const t = it.t, f = el.dataset.bi, i = parseInt(el.dataset.i, 10);
    if (f === "name") t.name = S(el.value, 60);
    else if (f === "en" && t.entrants[i]) {
      t.entrants[i].name = S(el.value, 40);
      const h = el.closest(".card") && el.closest(".card").querySelector(".card-head h3");
      if (h && t.size > 1) h.textContent = t.entrants[i].name.trim() || "Team " + (i + 1);
    } else if (f === "em" && t.entrants[i]) {
      t.entrants[i].members[parseInt(el.dataset.k, 10)] = S(el.value, 40);
      const fill = el.closest(".card") && el.closest(".card").querySelector(".card-head .fill");
      if (fill) fill.textContent = t.entrants[i].members.filter((x) => x.trim()).length + "/" + t.size;
    } else return;
    if (St.err) { St.err = ""; const er = document.getElementById("bt-err"); if (er) er.hidden = true; }
    queueSave(it, 700);
  });
  document.addEventListener("change", (e) => {
    const el = e.target;
    const r0 = root();
    if (!el || !el.dataset || el.dataset.bs !== "size" || !r0 || !r0.contains(el)) return;
    const it = cur();
    if (it) changeSize(it, parseInt(el.value, 10) || 1);
  });
  document.addEventListener("keydown", (e) => { if (e.key === "Escape" && document.getElementById("bt-dlg")) { e.stopPropagation(); closeDlg(); } }, true);
  document.addEventListener("scroll", (e) => { if (e.target && e.target.classList && e.target.classList.contains("bt-scroll")) St.sl = e.target.scrollLeft; }, true);

  window.SunaBracket = { mount, logic: L };
})();
