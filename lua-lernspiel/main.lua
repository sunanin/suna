-- ============================================================================
--  Lua-Quest: ein Lernspiel, in dem du Lua Schritt für Schritt lernst.
--
--  Starten:          lua main.lua          (am Anfang beginnen)
--                    lua main.lua 9        (direkt bei Level 9 starten)
--  Selbsttest:       lua main.lua --selbsttest
--
--  Keine Abhängigkeiten, läuft mit Lua 5.3 oder 5.4.
-- ============================================================================

local LEVELS = {
  -- ==========================================================================
  {
    kapitel = "Kapitel 1: Grundlagen",
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
Lua kann rechnen: + - * / (Division), % (Rest), ^ (Potenz) und // (ganzzahlige Division).
Punkt geht vor Strich, wie in der Mathematik. Klammern ( ) ändern die Reihenfolge.
]],
    beispiel = "print(2 + 3 * 4)  -- 14\nprint(7 // 2)      -- 3",
    aufgabe = "Berechne  17 + 25 * 2  und gib das Ergebnis mit print aus.",
    hinweis = "Punkt vor Strich: 25 * 2 wird zuerst berechnet.",
    loesung = "print(17 + 25 * 2)",
    tests = {
      { erwartet = "67" },
    },
  },
  {
    titel = "Datentypen",
    erklaerung = [[
Jeder Wert in Lua hat einen Typ. type(x) verrät dir, welchen:
  number    Zahl          string    Text
  boolean   true/false    table     Tabelle
  function  Funktion      nil       "nichts"
]],
    beispiel = 'print(type(42))     -- number\nprint(type("hi"))   -- string',
    aufgabe = "Schreibe eine Funktion typ(x), die den Typ von x als Text zurückgibt.",
    hinweis = "type(x) liefert genau das. Die Funktion muss es nur weitergeben: return type(x)",
    loesung = "function typ(x)\n  return type(x)\nend",
    tests = {
      { aufruf = "typ(1)", erwartet = "number" },
      { aufruf = 'typ("a")', erwartet = "string" },
      { aufruf = "typ(true)", erwartet = "boolean" },
      { aufruf = "typ({})", erwartet = "table" },
      { aufruf = "typ(nil)", erwartet = "nil" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 2: Kontrollfluss",
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
    titel = "Schleifen (while)",
    erklaerung = [[
while läuft, solange die Bedingung wahr ist:
  while bedingung do ... end
Achte darauf, dass die Bedingung irgendwann falsch wird, sonst läuft die Schleife ewig.
]],
    beispiel = "countdown = 3\nwhile countdown > 0 do\n  print(countdown)\n  countdown = countdown - 1\nend",
    aufgabe = "Die Variable  n  ist schon gesetzt. Gib die Zahlen n, n-1, ..., 1 aus, jede in einer eigenen Zeile (Countdown).",
    hinweis = "Solange n > 0 ist: ausgeben, dann n um 1 verringern.",
    loesung = "while n > 0 do\n  print(n)\n  n = n - 1\nend",
    tests = {
      { setup = { n = 3 }, erwartet = "3\n2\n1" },
      { setup = { n = 1 }, erwartet = "1" },
      { setup = { n = 0 }, erwartet = "" },
    },
  },
  {
    titel = "Schleife abbrechen (break)",
    erklaerung = [[
break beendet die innerste Schleife sofort. So verlässt du eine Schleife vorzeitig:
  for i = 1, 100 do
    if i > 3 then break end
    print(i)
  end
]],
    beispiel = "for i = 1, 10 do\n  if i == 3 then\n    break\n  end\n  print(i)\nend  -- gibt 1 und 2 aus",
    aufgabe = "Die Variable  n  ist schon gesetzt. Gib die Zahlen von 1 bis n aus. Sobald die Zahl 5 erreicht ist, beendest du die Schleife mit break. Die 5 wird dann nicht mehr ausgegeben.",
    hinweis = "In der Schleife: if i == 5 then break end, bevor du i ausgibst.",
    loesung = "for i = 1, n do\n  if i == 5 then\n    break\n  end\n  print(i)\nend",
    tests = {
      { setup = { n = 10 }, erwartet = "1\n2\n3\n4" },
      { setup = { n = 3 }, erwartet = "1\n2\n3" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 3: Texte",
    titel = "Texte: Länge, Groß und Klein",
    erklaerung = [[
Texte (strings) kannst du bearbeiten, ohne sie zu verändern:
  #text                 Länge des Textes
  string.upper(t)       GROSSBUCHSTABEN
  string.lower(t)       kleinbuchstaben
  string.sub(t, i, j)   Teil von Position i bis j (ab 1 gezählt)
]],
    beispiel = 'print(#"Lua")                 -- 3\nprint(string.upper("lua"))      -- LUA\nprint(string.sub("Lua", 1, 2))  -- Lu',
    aufgabe = "Schreibe eine Funktion kuerzel(text), die die ersten drei Buchstaben in Großbuchstaben zurückgibt.",
    hinweis = "string.sub(text, 1, 3) schneidet aus, string.upper macht Großbuchstaben.",
    loesung = "function kuerzel(text)\n  return string.upper(string.sub(text, 1, 3))\nend",
    tests = {
      { aufruf = 'kuerzel("lua")', erwartet = "LUA" },
      { aufruf = 'kuerzel("programm")', erwartet = "PRO" },
      { aufruf = 'kuerzel("ab")', erwartet = "AB" },
    },
  },
  {
    titel = "Suchen und Ersetzen",
    erklaerung = [[
string.gsub(text, alt, neu) ersetzt alle Vorkommen von alt durch neu.
Es gibt zwei Werte zurück: den neuen Text und die Anzahl der Ersetzungen.
Mit Klammern (...) nimmst du nur den ersten Wert.
]],
    beispiel = 'print(string.find("Hallo Welt", "Welt"))  -- 7  10\nprint((string.gsub("aaa", "a", "b")))  -- bbb',
    aufgabe = 'Schreibe eine Funktion ersetze(text), die jedes Vorkommen von "Katze" durch "Hund" ersetzt und den neuen Text zurückgibt.',
    hinweis = 'return (string.gsub(text, "Katze", "Hund")). Die Klammern sorgen dafür, dass nur der Text zurückkommt.',
    loesung = 'function ersetze(text)\n  return (string.gsub(text, "Katze", "Hund"))\nend',
    tests = {
      { aufruf = 'ersetze("Katze springt")', erwartet = "Hund springt" },
      { aufruf = 'ersetze("Katze und Katze")', erwartet = "Hund und Hund" },
      { aufruf = 'ersetze("Vogel")', erwartet = "Vogel" },
    },
  },
  {
    titel = "Text formatieren",
    erklaerung = [[
string.format baut Texte nach einem Muster:
  %s     Text
  %d     ganze Zahl
  %.2f   Kommazahl mit 2 Nachkommastellen
]],
    beispiel = 'print(string.format("%s hat %d Punkte", "Anna", 42))\nprint(string.format("%.2f", 3.14159))  -- 3.14',
    aufgabe = 'Schreibe eine Funktion preis(name, betrag), die z.B. "Brot kostet 3.00 Euro" zurückgibt. Der Betrag hat 2 Nachkommastellen.',
    hinweis = 'string.format("%s kostet %.2f Euro", name, betrag)',
    loesung = 'function preis(name, betrag)\n  return string.format("%s kostet %.2f Euro", name, betrag)\nend',
    tests = {
      { aufruf = 'preis("Brot", 3)', erwartet = "Brot kostet 3.00 Euro" },
      { aufruf = 'preis("Milch", 1.5)', erwartet = "Milch kostet 1.50 Euro" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 4: Tabellen",
    titel = "Listen erweitern",
    erklaerung = [[
table.insert(liste, wert) hängt einen Wert ans Ende an.
table.remove(liste) entfernt den letzten Wert.
table.concat(liste, ", ") verbindet alle Werte zu einem Text.
]],
    beispiel = 'liste = {1, 2}\ntable.insert(liste, 3)\nprint(table.concat(liste, ", "))  -- 1, 2, 3',
    aufgabe = "Schreibe eine Funktion hinzufuegen(liste, wert), die wert ans Ende der Liste anhängt und die Liste zurückgibt.",
    hinweis = "table.insert(liste, wert) und danach return liste.",
    loesung = "function hinzufuegen(liste, wert)\n  table.insert(liste, wert)\n  return liste\nend",
    tests = {
      { aufruf = 'table.concat(hinzufuegen({1, 2}, 3), ",")', erwartet = "1,2,3" },
      { aufruf = 'table.concat(hinzufuegen({}, "x"), ",")', erwartet = "x" },
    },
  },
  {
    titel = "Tabellen mit Namen",
    erklaerung = [[
Tabellen können auch Namen als Schlüssel haben:
  alter = {anna = 20, ben = 25}
  print(alter.anna)  -- 20
Mit pairs(t) durchläufst du alle Schlüssel und Werte. Die Reihenfolge ist dabei nicht festgelegt.
]],
    beispiel = "punkte = {anna = 3, ben = 5}\nfor name, wert in pairs(punkte) do\n  print(name, wert)\nend",
    aufgabe = "Schreibe eine Funktion anzahl_eintraege(t), die zählt, wie viele Einträge die Tabelle t hat. Auch Listen zählen.",
    hinweis = "Zähle mit einer for-Schleife über pairs(t), mit einem Zähler, der bei 0 startet.",
    loesung = "function anzahl_eintraege(t)\n  local zaehler = 0\n  for _ in pairs(t) do\n    zaehler = zaehler + 1\n  end\n  return zaehler\nend",
    tests = {
      { aufruf = "anzahl_eintraege({a = 1, b = 2, c = 3})", erwartet = "3" },
      { aufruf = "anzahl_eintraege({})", erwartet = "0" },
      { aufruf = "anzahl_eintraege({5, 6})", erwartet = "2" },
    },
  },
  {
    titel = "Sortieren",
    erklaerung = [[
table.sort(liste) sortiert eine Liste direkt, an Ort und Stelle.
Mit einer eigenen Vergleichsfunktion bestimmst du die Reihenfolge:
  table.sort(liste, function(a, b) return a < b end)
Die Funktion gibt true zurück, wenn a vor b stehen soll.
]],
    beispiel = 'zahlen = {3, 1, 2}\ntable.sort(zahlen)\nprint(table.concat(zahlen, ", "))  -- 1, 2, 3',
    aufgabe = "Schreibe eine Funktion nach_laenge(woerter), die die Wörter nach Länge sortiert (kürzestes zuerst) und die Tabelle zurückgibt.",
    hinweis = "table.sort(woerter, function(a, b) return #a < #b end). Das # misst die Länge.",
    loesung = "function nach_laenge(woerter)\n  table.sort(woerter, function(a, b)\n    return #a < #b\n  end)\n  return woerter\nend",
    tests = {
      { aufruf = 'table.concat(nach_laenge({"Hausboot", "a", "Baum"}), ",")', erwartet = "a,Baum,Hausboot" },
      { aufruf = 'table.concat(nach_laenge({"xy", "x"}), ",")', erwartet = "x,xy" },
    },
  },
  {
    titel = "Summe bilden",
    erklaerung = [[
ipairs(t) liefert nacheinander alle Einträge einer Liste:
  for _, wert in ipairs(t) do ... end
Ein Ergebnis fängt bei 0 an und wächst mit jedem Wert.
]],
    beispiel = "for _, wert in ipairs({4, 5}) do\n  print(wert)\nend",
    aufgabe = "Schreibe eine Funktion summe(t), die alle Zahlen in der Liste t addiert und die Summe zurückgibt.",
    hinweis = "Starte mit  local ergebnis = 0  und addiere in einer for-Schleife jeden Wert.",
    loesung = "function summe(t)\n  local ergebnis = 0\n  for _, wert in ipairs(t) do\n    ergebnis = ergebnis + wert\n  end\n  return ergebnis\nend",
    tests = {
      { aufruf = "summe({1, 2, 3})", erwartet = "6" },
      { aufruf = "summe({})", erwartet = "0" },
      { aufruf = "summe({10, -4, 5})", erwartet = "11" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 5: Funktionen vertieft",
    titel = "Mehrere Werte",
    erklaerung = [[
Eine Funktion kann beliebig viele Argumente annehmen. Mit ... bekommst du sie alle:
  function f(...)
    local werte = {...}
  end
Eine Funktion kann auch mehrere Werte zurückgeben:  return min, max
]],
    beispiel = "function zwei()\n  return 1, 2\nend\n\nlocal a, b = zwei()\nprint(a + b)  -- 3",
    aufgabe = "Schreibe eine Funktion minmax(...), die die kleinste und die größte der übergebenen Zahlen zurückgibt (zwei Werte).",
    hinweis = "local werte = {...}. Starte mit werte[1] und vergleiche danach jeden Wert in einer Schleife.",
    loesung = "function minmax(...)\n  local werte = {...}\n  local kleinste, groesste = werte[1], werte[1]\n  for _, wert in ipairs(werte) do\n    if wert < kleinste then kleinste = wert end\n    if wert > groesste then groesste = wert end\n  end\n  return kleinste, groesste\nend",
    tests = {
      { aufruf = 'table.concat({minmax(3, 1, 2)}, ",")', erwartet = "1,3" },
      { aufruf = 'table.concat({minmax(5)}, ",")', erwartet = "5,5" },
    },
  },
  {
    titel = "Closures: Funktionen mit Gedächtnis",
    erklaerung = [[
Eine innere Funktion kann Variablen der äußeren Funktion weiter benutzen,
auch nachdem die äußere Funktion beendet ist. Das nennt man Closure:
  function zaehler()
    local n = 0
    return function()
      n = n + 1
      return n
    end
  end
Jeder Aufruf von zaehler() erzeugt einen eigenen, unabhängigen Zähler.
]],
    beispiel = "z = zaehler()\nprint(z())  -- 1\nprint(z())  -- 2",
    aufgabe = "Schreibe eine Funktion zaehler(), die eine Funktion zurückgibt. Jeder Aufruf dieser Funktion liefert die nächste Zahl: 1, 2, 3, ...",
    hinweis = "Lege in zaehler() eine lokale Variable n an und gib eine Funktion zurück, die n erhöht.",
    loesung = "function zaehler()\n  local n = 0\n  return function()\n    n = n + 1\n    return n\n  end\nend",
    tests = {
      { zusatz = "local z = zaehler()\nz()\nz()", aufruf = "z()", erwartet = "3" },
      { zusatz = "local a = zaehler()\nlocal b = zaehler()\na()\na()\nb()", aufruf = "a() * 10 + b()", erwartet = "32" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 6: Fehler",
    titel = "Fehler abfangen (pcall)",
    erklaerung = [[
error("Text", 0) stoppt den Code mit einer Fehlermeldung. Die 0 verhindert,
dass eine Zeilennummer davor steht.
pcall(f, ...) führt f aus und fängt Fehler ab. Das Ergebnis ist true und der
Rückgabewert, oder false und die Fehlermeldung.
]],
    beispiel = 'local ok, fehler = pcall(function()\n  error("kaputt", 0)\nend)\nprint(ok, fehler)  -- false  kaputt',
    aufgabe = "Schreibe eine Funktion sicher_teilen(a, b), die a // b zurückgibt. Ist b gleich 0, löst sie den Fehler Division durch Null aus.",
    hinweis = 'if b == 0 then error("Division durch Null", 0) end',
    loesung = 'function sicher_teilen(a, b)\n  if b == 0 then\n    error("Division durch Null", 0)\n  end\n  return a // b\nend',
    tests = {
      { aufruf = "sicher_teilen(7, 2)", erwartet = "3" },
      { aufruf = "select(2, pcall(sicher_teilen, 1, 0))", erwartet = "Division durch Null" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 7: Objekte",
    titel = "Objekte mit Metatables",
    erklaerung = [[
Lua hat keine Klassen. Mit Tabellen und Metatables baust du Objekte.
k:einzahlen(5) ist dasselbe wie Konto.einzahlen(k, 5). Dafür nutzt man dieses Muster:
  Konto = {}
  Konto.__index = Konto

  function Konto.neu(startwert)
    local self = setmetatable({}, Konto)
    self.kontostand = startwert
    return self
  end
]],
    beispiel = 'function Konto:stand()\n  return self.kontostand\nend',
    aufgabe = [[
Baue ein Konto mit diesen Funktionen:
  Konto.neu(startwert)   erzeugt ein Konto mit diesem Stand
  k:einzahlen(betrag)    erhöht den Stand
  k:abheben(betrag)      senkt den Stand; fehlt Geld, löse error("Nicht genug Geld", 0) aus
  k:stand()              gibt den aktuellen Stand zurück
]],
    hinweis = "function Konto:einzahlen(betrag) ... end. Der Doppelpunkt übergibt self automatisch.",
    loesung = [[
Konto = {}
Konto.__index = Konto

function Konto.neu(startwert)
  local self = setmetatable({}, Konto)
  self.kontostand = startwert
  return self
end

function Konto:einzahlen(betrag)
  self.kontostand = self.kontostand + betrag
end

function Konto:abheben(betrag)
  if betrag > self.kontostand then
    error("Nicht genug Geld", 0)
  end
  self.kontostand = self.kontostand - betrag
end

function Konto:stand()
  return self.kontostand
end]],
    tests = {
      { zusatz = "local k = Konto.neu(100)\nk:einzahlen(50)", aufruf = "k:stand()", erwartet = "150" },
      { zusatz = "local k = Konto.neu(100)\nk:abheben(30)", aufruf = "k:stand()", erwartet = "70" },
      { zusatz = "local k = Konto.neu(10)", aufruf = "select(2, pcall(k.abheben, k, 50))", erwartet = "Nicht genug Geld" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Kapitel 8: Coroutines",
    titel = "Coroutines",
    erklaerung = [[
Eine Coroutine ist ein Codestück, das mit coroutine.yield pausieren und
später weiterlaufen kann. So erzeugst du Werte nach und nach:
  co = coroutine.create(function() coroutine.yield(1) end)
  print(coroutine.resume(co))  -- true  1
]],
    beispiel = 'co = coroutine.create(function()\n  coroutine.yield("eins")\n  coroutine.yield("zwei")\nend)\nprint(coroutine.resume(co))  -- true  eins',
    aufgabe = "Schreibe eine Funktion zaehlen(n), die eine Coroutine zurückgibt. Sie soll die Zahlen 1 bis n nacheinander mit coroutine.yield liefern.",
    hinweis = "coroutine.create(function() for i = 1, n do coroutine.yield(i) end end)",
    loesung = "function zaehlen(n)\n  return coroutine.create(function()\n    for i = 1, n do\n      coroutine.yield(i)\n    end\n  end)\nend",
    tests = {
      {
        zusatz = "local co = zaehlen(3)\nlocal werte = {}\nwhile true do\n  local ok, wert = coroutine.resume(co)\n  if not wert then break end\n  werte[#werte + 1] = wert\nend",
        aufruf = "table.concat(werte, ',')",
        erwartet = "1,2,3",
      },
      { zusatz = "local co = zaehlen(0)\nlocal ok, wert = coroutine.resume(co)", aufruf = "tostring(wert)", erwartet = "nil" },
    },
  },
  -- ==========================================================================
  {
    kapitel = "Abschluss: Projekt",
    titel = "Abschlussprojekt: Wörter zählen",
    erklaerung = [[
Jetzt kombinierst du alles: Texte, Schleifen, Bedingungen und Funktionen.
string.gmatch(text, "%a+") liefert nacheinander alle Wörter eines Textes.
string.lower macht Text klein, damit Groß und Klein gleich behandelt werden.
]],
    beispiel = 'for wort in string.gmatch("Lua ist cool", "%a+") do\n  print(wort)\nend',
    aufgabe = "Schreibe eine Funktion anzahl(text, wort), die zählt, wie oft wort als ganzes Wort im Text vorkommt. Groß und Klein spielen keine Rolle.",
    hinweis = "Zähler auf 0, dann mit string.gmatch alle Wörter durchgehen und mit string.lower(wort) vergleichen.",
    loesung = 'function anzahl(text, wort)\n  local zaehler = 0\n  local gesucht = string.lower(wort)\n  for w in string.gmatch(string.lower(text), "%a+") do\n    if w == gesucht then\n      zaehler = zaehler + 1\n    end\n  end\n  return zaehler\nend',
    tests = {
      { aufruf = 'anzahl("Lua ist super, lua rockt", "LUA")', erwartet = "2" },
      { aufruf = 'anzahl("Lua Lua Luana", "lua")', erwartet = "2" },
      { aufruf = 'anzahl("nichts hier", "lua")', erwartet = "0" },
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
                  "select", "error", "assert", "pcall", "math", "string", "table",
                  "coroutine", "setmetatable", "getmetatable",
                  "rawget", "rawset", "rawequal", "rawlen" }

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

  -- Spielercode, dann optionaler Vorbereitungscode, dann der Aufruf.
  local quelltext = code
  if test.zusatz then
    quelltext = quelltext .. "\n" .. test.zusatz
  end
  if test.aufruf then
    quelltext = quelltext .. "\nreturn " .. test.aufruf
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
  if level.kapitel then
    print("#### " .. level.kapitel .. " ####")
  end
  print(string.rep("=", 50))
  print(string.format("Level %d/%d: %s", nr, #LEVELS, level.titel))
  print(string.rep("=", 50))
  print(trim(level.erklaerung))
  print("")
  print("Beispiel:")
  print(einruecken(trim(level.beispiel)))
  print("")
  print("Aufgabe:")
  print(einruecken(trim(level.aufgabe)))
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
          .. ". Starte mit  lua main.lua " .. nr .. "  weiter.")
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
  print("  - Schreibe eigene Programme, zum Beispiel ein Textadventure oder ein Ratespiel.")
  print("  - Lies das Handbuch:  https://www.lua.org/manual/5.4/")
  print("  - Lies das Buch:      https://www.lua.org/pil/  (Programming in Lua)")
end

-- ----------------------------------------------------------------------------
--  Selbsttest: prüft, dass jede Musterlösung alle Tests besteht.
-- ----------------------------------------------------------------------------

local function selbsttest()
  local fehlerzahl = 0
  for nr, level in ipairs(LEVELS) do
    local ok, fehler = pruefe(level, level.loesung)
    if ok then
      print(string.format("Level %2d '%s': OK", nr, level.titel))
    else
      fehlerzahl = fehlerzahl + 1
      print(string.format("Level %2d '%s': FEHLER\n%s", nr, level.titel, fehler))
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
