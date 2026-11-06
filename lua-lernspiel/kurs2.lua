-- ============================================================================
--  Lua-Quest, Kurs 2: Module, Dateien, Tests und Objekte vertieft.
--  Wird von main.lua geladen. Starten mit:  lua main.lua 2
--
--  Zusätzliche Felder für Tests:
--    modul = true          der Code ist ein Modul (endet mit return M)
--    bibliothek = {...}    Module, die require(...) bereitstellt
--    dateien = {...}       virtuelle Dateien: { ["name.txt"] = "Inhalt" }
-- ============================================================================

return {
  -- ==========================================================================
  {
    kapitel = "Kapitel 1: Module",
    titel = "Eigenes Modul schreiben",
    erklaerung = [[
Ein Modul ist Code, der eine Tabelle zurückgibt. So bündelst du zusammengehörige
Funktionen. Ein Modul beginnt meist mit local M = {} und endet mit return M:
  local M = {}
  function M.hallo()
    return "hallo"
  end
  return M
]],
    beispiel = 'local M = {}\nfunction M.hallo()\n  return "hallo"\nend\nreturn M',
    aufgabe = "Schreibe ein Modul: eine Tabelle M mit den Funktionen M.quadrat(x) und M.dreifach(x). Das Modul endet mit return M.",
    hinweis = "Jede Funktion als function M.name(x) ... end schreiben. Am Ende steht return M.",
    loesung = "local M = {}\n\nfunction M.quadrat(x)\n  return x * x\nend\n\nfunction M.dreifach(x)\n  return x * 3\nend\n\nreturn M",
    tests = {
      { modul = true, aufruf = "M.quadrat(4)", erwartet = "16" },
      { modul = true, aufruf = "M.dreifach(5)", erwartet = "15" },
    },
  },
  {
    titel = "Module laden mit require",
    erklaerung = [[
require("name") lädt ein Modul und gibt seine Tabelle zurück:
  local mathe = require("mathe")
  print(mathe.quadrat(3))
Ein geladenes Modul wird nur einmal ausgeführt und danach zwischengespeichert.
Hier stellt das Spiel das Modul "mathe" für dich bereit.
]],
    beispiel = 'local mathe = require("mathe")\nprint(mathe.quadrat(3))  -- 9',
    aufgabe = "Schreibe eine Funktion quadrat_summe(a, b), die das Modul mathe lädt und quadrat(a) + quadrat(b) zurückgibt.",
    hinweis = "local mathe = require(\"mathe\") und dann mathe.quadrat(a) + mathe.quadrat(b).",
    loesung = 'function quadrat_summe(a, b)\n  local mathe = require("mathe")\n  return mathe.quadrat(a) + mathe.quadrat(b)\nend',
    bibliothek = {
      mathe = { PI = 3, quadrat = function(x) return x * x end },
    },
    tests = {
      { aufruf = "quadrat_summe(3, 4)", erwartet = "25" },
      { aufruf = 'require("mathe").PI', erwartet = "3" },
      { aufruf = 'select(2, pcall(require, "fehlt"))', erwartet = "Modul nicht gefunden: fehlt" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 2: Dateien",
    titel = "Dateien lesen",
    erklaerung = [[
So liest du eine Datei Zeile für Zeile:
  local f = io.open("name.txt", "r")
  if not f then return nil end        -- Datei fehlt
  local zeile = f:read("l")           -- nächste Zeile oder nil am Ende
  f:close()                           -- Datei wieder schließen
io.open liefert bei Fehlern nil statt einer Datei. Prüfe deshalb immer, ob f existiert.
]],
    beispiel = 'local f = io.open("zahlen.txt", "r")\nprint(f:read("l"))  -- erste Zeile\nf:close()',
    aufgabe = "Schreibe eine Funktion summe_datei(name), die alle Zahlen aus der Datei addiert, eine Zahl pro Zeile. Gibt es die Datei nicht, gib nil zurück.",
    hinweis = "Schleife mit while true do, f:read(\"l\") holen und bei nil mit break aufhören. tonumber macht aus Text eine Zahl.",
    loesung = 'function summe_datei(name)\n  local f = io.open(name, "r")\n  if not f then\n    return nil\n  end\n  local summe = 0\n  while true do\n    local zeile = f:read("l")\n    if not zeile then\n      break\n    end\n    local wert = tonumber(zeile)\n    if wert then\n      summe = summe + wert\n    end\n  end\n  f:close()\n  return summe\nend',
    tests = {
      { dateien = { ["zahlen.txt"] = "3\n4\n5\n" }, aufruf = 'summe_datei("zahlen.txt")', erwartet = "12" },
      { aufruf = 'tostring(summe_datei("nichts.txt"))', erwartet = "nil" },
    },
  },
  {
    titel = "Dateien schreiben",
    erklaerung = [[
Mit "w" öffnest du eine Datei zum Schreiben. Sie wird dabei leer gemacht,
also überschrieben:
  local f = io.open("notiz.txt", "w")
  f:write("Hallo\n")
  f:close()
Vergiss das close nicht, sonst ist der Inhalt nicht zuverlässig gespeichert.
]],
    beispiel = 'local f = io.open("notiz.txt", "w")\nf:write("Hallo")\nf:close()',
    aufgabe = "Schreibe eine Funktion speichere(name, text), die text in die Datei schreibt (alter Inhalt wird ersetzt) und true zurückgibt.",
    hinweis = "io.open(name, \"w\"), f:write(text), f:close(), return true.",
    loesung = 'function speichere(name, text)\n  local f = io.open(name, "w")\n  if not f then\n    return false\n  end\n  f:write(text)\n  f:close()\n  return true\nend',
    tests = {
      { aufruf = 'tostring(speichere("notiz.txt", "Hallo")) .. "|" .. inhalt("notiz.txt")', erwartet = "true|Hallo" },
      { dateien = { ["notiz.txt"] = "alt" }, aufruf = 'tostring(speichere("notiz.txt", "neu")) .. "|" .. inhalt("notiz.txt")', erwartet = "true|neu" },
    },
  },
  {
    titel = "Dateien erweitern (anhängen)",
    erklaerung = [[
Mit "a" (append) öffnest du eine Datei und hängst an das Ende an.
Existiert sie nicht, wird sie neu angelegt. Ein Protokoll funktioniert so:
  local f = io.open("log.txt", "a")
  f:write("neuer Eintrag\n")
  f:close()
]],
    beispiel = 'local f = io.open("log.txt", "a")\nf:write("Start\\n")\nf:close()',
    aufgabe = "Schreibe eine Funktion protokoll(name, eintrag), die eintrag mit einem Zeilenumbruch ans Ende der Datei anhängt und true zurückgibt.",
    hinweis = 'io.open(name, "a"), f:write(eintrag .. "\\n"), f:close().',
    loesung = 'function protokoll(name, eintrag)\n  local f = io.open(name, "a")\n  if not f then\n    return false\n  end\n  f:write(eintrag .. "\\n")\n  f:close()\n  return true\nend',
    tests = {
      { dateien = { ["log.txt"] = "alt\n" }, aufruf = 'tostring(protokoll("log.txt", "neu")) .. "|" .. inhalt("log.txt")', erwartet = "true|alt\nneu\n" },
      { aufruf = 'tostring(protokoll("neu.txt", "x")) .. "|" .. inhalt("neu.txt")', erwartet = "true|x\n" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 3: Tests schreiben",
    titel = "Eigener Test-Runner",
    erklaerung = [[
assert(bedingung, meldung) löst einen Fehler aus, wenn die Bedingung falsch ist:
  assert(quadrat(2) == 4, "quadrat(2) sollte 4 sein")
Ein Test ist eine Funktion, die ohne Fehler durchläuft, wenn alles stimmt.
pcall(fn) führt fn aus und fängt Fehler ab, damit ein Test den Rest nicht stoppt.
]],
    beispiel = 'local ok, fehler = pcall(function()\n  assert(1 == 2, "falsch")\nend)\nprint(ok)  -- false',
    aufgabe = 'Schreibe eine Funktion test(name, fn). Sie führt fn mit pcall aus und gibt "OK: name" zurück, wenn kein Fehler passiert, sonst "FEHLER: name".',
    hinweis = "local ok = pcall(fn) und dann je nach ok den passenden Text zurückgeben.",
    loesung = 'function test(name, fn)\n  local ok = pcall(fn)\n  if ok then\n    return "OK: " .. name\n  end\n  return "FEHLER: " .. name\nend',
    tests = {
      { aufruf = 'test("a", function() end)', erwartet = "OK: a" },
      { aufruf = 'test("b", function() error("x", 0) end)', erwartet = "FEHLER: b" },
      { aufruf = 'test("c", function() assert(1 == 2, "nope") end)', erwartet = "FEHLER: c" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 4: Objekte vertieft",
    titel = "Metamethoden: Vektoren",
    erklaerung = [[
Metamethoden legen fest, wie deine Objekte mit Operatoren umgehen:
  __add       a + b
  __eq        a == b
  __tostring  tostring(a) und print(a)
  __index     Methoden suchen (das kennst du schon)
Sie werden in die Metatable geschrieben, z. B. Vektor.__add = function(a, b) ... end.
]],
    beispiel = 'Vektor.__tostring = function(v)\n  return "(" .. v.x .. ")"\nend',
    aufgabe = "Baue einen Vektor mit Vektor.neu(x, y). Zwei Vektoren lassen sich mit + addieren, mit == vergleichen, und tostring(v) gibt \"(x, y)\" zurück.",
    hinweis = "Die Metatable ist Vektor, also setmetatable({x = x, y = y}, Vektor). Die Metamethoden stehen als Vektor.__add usw.",
    loesung = 'Vektor = {}\nVektor.__index = Vektor\n\nfunction Vektor.neu(x, y)\n  return setmetatable({x = x, y = y}, Vektor)\nend\n\nVektor.__add = function(a, b)\n  return Vektor.neu(a.x + b.x, a.y + b.y)\nend\n\nVektor.__eq = function(a, b)\n  return a.x == b.x and a.y == b.y\nend\n\nVektor.__tostring = function(v)\n  return "(" .. v.x .. ", " .. v.y .. ")"\nend',
    tests = {
      { zusatz = "local a = Vektor.neu(1, 2)\nlocal b = Vektor.neu(3, 4)", aufruf = "tostring(a + b)", erwartet = "(4, 6)" },
      { aufruf = "tostring(Vektor.neu(1, 2) == Vektor.neu(1, 2))", erwartet = "true" },
      { aufruf = "tostring(Vektor.neu(1, 2) == Vektor.neu(2, 1))", erwartet = "false" },
    },
  },
  {
    titel = "Vererbung",
    erklaerung = [[
Mit Vererbung übernimmt ein Objekt die Methoden einer anderen Klasse und darf sie
ändern. Die Kindklasse verweist dafür über ihre Metatable auf die Elternklasse:
  Hund = setmetatable({}, {__index = Tier})
Wenn Hund eine Methode nicht hat, sucht Lua bei Tier weiter.
]],
    beispiel = 'Tier = {}\nTier.__index = Tier\nfunction Tier:laut()\n  return "..."\nend',
    aufgabe = 'Baue Tier mit Tier.neu(name), Tier:sprich() (gibt "..." zurück) und Tier:vorstellen() (gibt z. B. "Max macht ..." zurück). Hund erbt davon, hat Hund.neu(name) und überschreibt sprich() so, dass "Wuff" zurückkommt.',
    hinweis = "Hund = setmetatable({}, {__index = Tier}) und Hund.__index = Hund. Hund.neu setzt die Metatable auf Hund.",
    loesung = 'Tier = {}\nTier.__index = Tier\n\nfunction Tier.neu(name)\n  return setmetatable({name = name}, Tier)\nend\n\nfunction Tier:sprich()\n  return "..."\nend\n\nfunction Tier:vorstellen()\n  return self.name .. " macht " .. self:sprich()\nend\n\nHund = setmetatable({}, {__index = Tier})\nHund.__index = Hund\n\nfunction Hund.neu(name)\n  return setmetatable({name = name}, Hund)\nend\n\nfunction Hund:sprich()\n  return "Wuff"\nend',
    tests = {
      { aufruf = 'Tier.neu("Max"):vorstellen()', erwartet = "Max macht ..." },
      { aufruf = 'Hund.neu("Rex"):sprich()', erwartet = "Wuff" },
      { aufruf = 'Hund.neu("Rex"):vorstellen()', erwartet = "Rex macht Wuff" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Abschluss: Projekt",
    titel = "Abschlussprojekt: Inventar speichern",
    erklaerung = [[
Du kombinierst Tabellen, Dateien und Muster-Suche.
string.match(zeile, "^(%w+)=(%d+)$") zerlegt eine Zeile wie "apfel=2" in Name und Zahl.
Zum Speichern gehst du die Schlüssel mit table.sort sortiert durch,
damit die Datei immer gleich aussieht.
]],
    beispiel = 'local k, v = string.match("apfel=2", "^(%w+)=(%d+)$")\nprint(k, v)  -- apfel  2',
    aufgabe = [[
Schreibe zwei Funktionen:
  speichern(inventar, name)  schreibt jede Zeile als "schluessel=wert" in die Datei (sortiert), gibt true zurück
  laden(name)                liest die Datei und gibt eine Tabelle zurück (Werte als Zahlen). Fehlt die Datei, ist die Tabelle leer.
]],
    hinweis = "Schlüssel mit pairs einsammeln, mit table.sort sortieren, dann f:write(k .. \"=\" .. v .. \"\\n\").",
    loesung = 'function speichern(inventar, name)\n  local schluessel = {}\n  for k in pairs(inventar) do\n    schluessel[#schluessel + 1] = k\n  end\n  table.sort(schluessel)\n  local f = io.open(name, "w")\n  if not f then\n    return false\n  end\n  for _, k in ipairs(schluessel) do\n    f:write(k .. "=" .. inventar[k] .. "\\n")\n  end\n  f:close()\n  return true\nend\n\nfunction laden(name)\n  local inventar = {}\n  local f = io.open(name, "r")\n  if not f then\n    return inventar\n  end\n  while true do\n    local zeile = f:read("l")\n    if not zeile then\n      break\n    end\n    local k, v = string.match(zeile, "^(%w+)=(%d+)$")\n    if k then\n      inventar[k] = tonumber(v)\n    end\n  end\n  f:close()\n  return inventar\nend',
    tests = {
      { aufruf = 'tostring(speichern({apfel = 2, birne = 5}, "inv.txt")) .. "|" .. inhalt("inv.txt")', erwartet = "true|apfel=2\nbirne=5\n" },
      { dateien = { ["inv.txt"] = "apfel=2\nbirne=5\n" }, aufruf = 'laden("inv.txt").birne', erwartet = "5" },
      { aufruf = 'tostring(laden("fehlt.txt").x)', erwartet = "nil" },
    },
  },
}
