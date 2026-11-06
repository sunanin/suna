-- ============================================================================
--  Lua-Quest: ein Lernspiel, in dem du Lua Schritt für Schritt lernst.
--
--  Starten:          lua main.lua          (am Anfang beginnen)
--                    lua main.lua 4        (direkt bei Level 4 starten)
--  Selbsttest:       lua main.lua --selbsttest
--
--  Keine Abhängigkeiten, läuft mit Lua 5.3 oder 5.4.
-- ============================================================================

local LEVELS = {
  {
    titel = "Hallo Welt",
    erklaerung = [[
Mit print() gibst du etwas auf dem Bildschirm aus.
Text steht in Anführungszeichen, zum Beispiel "Hallo".
]],
    beispiel = 'print("Hallo")',
    aufgabe = "Gib genau den Text  Hallo Welt  aus.",
    hinweis = "Schreibe print(...) und setze den Text in Anführungszeichen.",
    loesung = 'print("Hallo Welt")',
    tests = {
      { erwartet = "Hallo Welt" },
    },
  },
  {
    titel = "Variablen",
    erklaerung = [[
Eine Variable ist ein Name, der einen Wert speichert:  name = "Lua"
Mit  ..  verbindest du Texte:  "Hallo " .. "Welt"  ergibt  Hallo Welt
]],
    beispiel = 'name = "Lua"\nprint("Ich lerne " .. name)',
    aufgabe = "Lege eine Variable  alter  mit dem Wert 17 an und gib sie mit print aus.",
    hinweis = "alter = 17 speichert den Wert. print(alter) zeigt ihn an.",
    loesung = "alter = 17\nprint(alter)",
    tests = {
      { erwartet = "17" },
    },
  },
  {
    titel = "Rechnen",
    erklaerung = [[
Lua kann rechnen: + - * / (Division), % (Rest), ^ (Potenz).
Punkt geht vor Strich, wie in der Mathematik. Klammern ( ) ändern die Reihenfolge.
]],
    beispiel = "print(2 + 3 * 4)  -- gibt 14 aus",
    aufgabe = "Berechne  17 + 25 * 2  und gib das Ergebnis mit print aus.",
    hinweis = "Punkt vor Strich: 25 * 2 wird zuerst berechnet.",
    loesung = "print(17 + 25 * 2)",
    tests = {
      { erwartet = "67" },
    },
  },
  {
    titel = "Entscheidungen (if)",
    erklaerung = [[
Mit if führst du Code nur aus, wenn eine Bedingung stimmt:
  if bedingung then ... else ... end
Gleich prüfst du mit ==, ungleich mit ~=.
Der Rest bei einer Division ist mit % berechnet.
]],
    beispiel = 'if alter >= 18 then\n  print("volljährig")\nelse\n  print("noch nicht")\nend',
    aufgabe = 'Die Variable  zahl  ist schon gesetzt. Gib "gerade" aus, wenn zahl gerade ist, sonst "ungerade".',
    hinweis = "Eine Zahl ist gerade, wenn zahl % 2 == 0 ist.",
    loesung = 'if zahl % 2 == 0 then\n  print("gerade")\nelse\n  print("ungerade")\nend',
    tests = {
      { setup = { zahl = 4 }, erwartet = "gerade" },
      { setup = { zahl = 7 }, erwartet = "ungerade" },
      { setup = { zahl = 0 }, erwartet = "gerade" },
    },
  },
  {
    titel = "Schleifen (for)",
    erklaerung = [[
Eine Schleife wiederholt Code. Mit  for i = 1, 5 do ... end  läuft i nacheinander
durch 1, 2, 3, 4, 5. Alles zwischen do und end wird bei jedem Durchlauf ausgeführt.
]],
    beispiel = 'for i = 1, 3 do\n  print("Runde " .. i)\nend',
    aufgabe = "Die Variable  n  ist schon gesetzt. Gib die Zahlen von 1 bis n aus, jede in einer eigenen Zeile.",
    hinweis = "for i = 1, n do ... end. Im Schleifenkörper gibst du i mit print aus.",
    loesung = "for i = 1, n do\n  print(i)\nend",
    tests = {
      { setup = { n = 3 }, erwartet = "1\n2\n3" },
      { setup = { n = 5 }, erwartet = "1\n2\n3\n4\n5" },
    },
  },
  {
    titel = "Funktionen",
    erklaerung = [[
Eine Funktion ist ein benannter Codeblock, den du immer wieder aufrufen kannst.
return gibt einen Wert an den Aufrufer zurück:
  function gruessen(name)
    return "Hallo " .. name
  end
]],
    beispiel = 'function gruessen(name)\n  return "Hallo " .. name\nend\n\nprint(gruessen("Anna"))',
    aufgabe = "Schreibe eine Funktion  verdoppeln(x), die x * 2 zurückgibt.",
    hinweis = "function verdoppeln(x) ... return x * 2 ... end",
    loesung = "function verdoppeln(x)\n  return x * 2\nend",
    tests = {
      { aufruf = "verdoppeln(5)", erwartet = "10" },
      { aufruf = "verdoppeln(-3)", erwartet = "-6" },
    },
  },
  {
    titel = "Tabellen",
    erklaerung = [[
Eine Tabelle (table) sammelt mehrere Werte. Die Zählung beginnt bei 1.
  obst = {"Apfel", "Birne"}
  print(obst[1])   -- Apfel
  print(#obst)     -- Anzahl der Einträge: 2
]],
    beispiel = "zahlen = {10, 20, 30}\nprint(zahlen[2])  -- gibt 20 aus",
    aufgabe = 'Erstelle eine Tabelle  farben  mit den Einträgen "Rot", "Grün" und "Blau" (in dieser Reihenfolge).',
    hinweis = 'farben = {"Rot", "Grün", "Blau"}. Die Einträge stehen in geschweiften Klammern.',
    loesung = 'farben = {"Rot", "Grün", "Blau"}',
    tests = {
      { aufruf = "#farben", erwartet = "3" },
      { aufruf = "farben[2]", erwartet = "Grün" },
    },
  },
  {
    titel = "Boss-Level: Summe",
    erklaerung = [[
Jetzt kombinierst du alles: Funktionen, Tabellen und Schleifen.
ipairs(t) liefert nacheinander alle Einträge einer Tabelle:
  for _, wert in ipairs(t) do ... end
Ein Ergebnis fängt bei 0 an und wächst mit jedem Wert.
]],
    beispiel = "for _, wert in ipairs({4, 5}) do\n  print(wert)\nend",
    aufgabe = "Schreibe eine Funktion  summe(t), die alle Zahlen in der Tabelle t addiert und die Summe zurückgibt.",
    hinweis = "Starte mit  local ergebnis = 0  und addiere in einer for-Schleife jeden Wert.",
    loesung = "function summe(t)\n  local ergebnis = 0\n  for _, wert in ipairs(t) do\n    ergebnis = ergebnis + wert\n  end\n  return ergebnis\nend",
    tests = {
      { aufruf = "summe({1, 2, 3})", erwartet = "6" },
      { aufruf = "summe({})", erwartet = "0" },
      { aufruf = "summe({10, -4, 5})", erwartet = "11" },
    },
  },
}

-- ----------------------------------------------------------------------------
--  Hilfsfunktionen
-- ----------------------------------------------------------------------------

local SCHRITTE_LIMIT = 5000000 -- schützt vor Endlosschleifen im Code der Spieler

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function einruecken(text)
  return "  " .. (text:gsub("\n", "\n  "))
end

-- Nur harmlose Funktionen stehen dem Spielercode zur Verfügung.
local ERLAUBT = { "tostring", "tonumber", "type", "pairs", "ipairs", "next",
                  "select", "error", "assert", "pcall", "math", "string", "table" }

local function neue_umgebung(ausgabe)
  local env = {}
  for _, name in ipairs(ERLAUBT) do
    env[name] = _G[name]
  end
  -- print sammelt die Ausgabe, statt sie sofort anzuzeigen.
  env.print = function(...)
    local teile = {}
    for i = 1, select("#", ...) do
      teile[#teile + 1] = tostring((select(i, ...)))
    end
    ausgabe[#ausgabe + 1] = table.concat(teile, "\t")
  end
  return env
end

-- Führt den Code eines Spielers für einen Test aus.
-- Gibt den Ergebnistext zurück, oder nil und eine Fehlermeldung.
local function ausfuehren(code, test)
  local ausgabe = {}
  local env = neue_umgebung(ausgabe)
  for k, v in pairs(test.setup or {}) do
    env[k] = v
  end

  local quelltext = code
  if test.aufruf then
    quelltext = code .. "\nreturn " .. test.aufruf
  end

  local fn, syntaxfehler = load(quelltext, "=dein Code", "t", env)
  if not fn then
    return nil, "Syntaxfehler: " .. syntaxfehler
  end

  debug.sethook(function()
    error("Dein Code läuft zu lange. Hast du eine Endlosschleife?", 0)
  end, "", SCHRITTE_LIMIT)
  local ok, ergebnis = pcall(fn)
  debug.sethook()

  if not ok then
    return nil, "Laufzeitfehler: " .. tostring(ergebnis)
  end
  if test.aufruf then
    return tostring(ergebnis)
  end
  return trim(table.concat(ausgabe, "\n"))
end

local function beschreibe(test)
  if test.aufruf then
    return " (Aufruf: " .. test.aufruf .. ")"
  end
  if test.setup then
    local teile = {}
    for k, v in pairs(test.setup) do
      teile[#teile + 1] = k .. " = " .. tostring(v)
    end
    table.sort(teile)
    return " (mit " .. table.concat(teile, ", ") .. ")"
  end
  return ""
end

-- Prüft den Code gegen alle Tests eines Levels.
-- Gibt true zurück, oder false und eine verständliche Fehlermeldung.
local function pruefe(level, code)
  for i, test in ipairs(level.tests) do
    local ist, fehler = ausfuehren(code, test)
    if not ist then
      return false, fehler
    end
    if ist ~= test.erwartet then
      return false, string.format("Test %d%s\n  erwartet: %s\n  bekommen: %s",
        i, beschreibe(test), string.format("%q", test.erwartet), string.format("%q", ist))
    end
  end
  return true
end

-- ----------------------------------------------------------------------------
--  Anzeige und Eingabe
-- ----------------------------------------------------------------------------

local function zeige_willkommen()
  print([[

  ============================================
            W I L L K O M M E N
                 bei Lua-Quest!
  ============================================

Du lernst Programmieren, indem du Aufgaben löst.
Du schreibst echten Lua-Code, das Spiel führt ihn aus und prüft ihn.

Befehle:
  Code eingeben, Zeile für Zeile.
  Mit einem einzelnen Punkt  .  in einer eigenen Zeile abschließen.
  /hinweis   zeigt einen Tipp
  /loesung   zeigt die Lösung und geht zum nächsten Level
  /quit      beendet das Spiel
]])
end

local function zeige_level(nr, level)
  print("")
  print(string.rep("=", 50))
  print(string.format("Level %d/%d: %s", nr, #LEVELS, level.titel))
  print(string.rep("=", 50))
  print(trim(level.erklaerung))
  print("")
  print("Beispiel:")
  print(einruecken(level.beispiel))
  print("")
  print("Aufgabe: " .. level.aufgabe)
  print("")
end

-- Liest den Code des Spielers. Gibt einen Text zurück, oder "quit" / "loesung".
local function lies_code(level)
  local zeilen = {}
  print("(Code eingeben, mit '.' abschließen | /hinweis | /loesung | /quit)")
  while true do
    io.write("> ")
    local zeile = io.read()
    if not zeile then
      return "quit"
    end
    zeile = zeile:gsub("\r$", "")

    if zeile == "/quit" then
      return "quit"
    elseif zeile == "/loesung" then
      return "loesung"
    elseif zeile == "/hinweis" then
      print("Tipp: " .. level.hinweis)
    elseif zeile == "." then
      return table.concat(zeilen, "\n")
    else
      zeilen[#zeilen + 1] = zeile
    end
  end
end

-- ----------------------------------------------------------------------------
--  Spielablauf
-- ----------------------------------------------------------------------------

local function spiel(start)
  zeige_willkommen()

  for nr = start, #LEVELS do
    local level = LEVELS[nr]
    zeige_level(nr, level)

    while true do
      local eingabe = lies_code(level)

      if eingabe == "quit" then
        print("\nBis bald! Dein Fortschritt: Level " .. nr .. " von " .. #LEVELS
          .. ". Starte mit  lua main.lua " .. nr  .. "  weiter.")
        return
      end

      if eingabe == "loesung" then
        print("\nLösung:")
        print(einruecken(level.loesung))
        break
      end

      local ok, fehler = pruefe(level, eingabe)
      if ok then
        print("\n*** Geschafft! ***")
        break
      end
      print("\nNoch nicht ganz.")
      print(fehler)
      print("Versuch es noch einmal oder tippe /hinweis.\n")
    end
  end

  print("\n============================================")
  print("  Glückwunsch, du hast alle Level geschafft!")
  print("============================================")
  print("Wie geht es weiter?")
  print("  - Schreibe eigene kleine Programme, zum Beispiel ein Ratespiel.")
  print("  - Handbuch:  https://www.lua.org/manual/5.4/")
  print("  - Buch:      https://www.lua.org/pil/  (Programming in Lua)")
end

-- ----------------------------------------------------------------------------
--  Selbsttest: prüft, dass jede Musterlösung alle Tests besteht.
-- ----------------------------------------------------------------------------

local function selbsttest()
  local fehlerzahl = 0
  for nr, level in ipairs(LEVELS) do
    local ok, fehler = pruefe(level, level.loesung)
    if ok then
      print(string.format("Level %d '%s': OK", nr, level.titel))
    else
      fehlerzahl = fehlerzahl + 1
      print(string.format("Level %d '%s': FEHLER\n%s", nr, level.titel, fehler))
    end
  end
  print(fehlerzahl == 0 and "Alle Lösungen bestehen die Tests."
    or (fehlerzahl .. " Level mit Fehlern."))
  return fehlerzahl == 0
end

-- ----------------------------------------------------------------------------
--  Start
-- ----------------------------------------------------------------------------

if arg and arg[1] == "--selbsttest" then
  os.exit(selbsttest() and 0 or 1)
end

local start = tonumber(arg and arg[1]) or 1
start = math.max(1, math.min(#LEVELS, math.floor(start)))
spiel(start)
