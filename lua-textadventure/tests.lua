-- Tests für das Textadventure. Ausführen mit:  lua tests.lua
package.path = "./?.lua;" .. package.path
local welt = require("welt")
local befehle = require("befehle")
local speichern = require("speichern")

local anzahl, fehler = 0, 0

local function test(name, fn)
  anzahl = anzahl + 1
  local ok, meldung = pcall(fn)
  if ok then
    print("OK     " .. name)
  else
    fehler = fehler + 1
    print("FEHLER " .. name .. "\n       " .. tostring(meldung))
  end
end

-- Führt mehrere Befehle nacheinander aus und gibt die letzte Antwort zurück.
local function spiele(zustand, ...)
  local antwort
  for _, eingabe in ipairs({ ... }) do
    antwort = befehle.verarbeite(zustand, eingabe)
  end
  return antwort
end

test("neuer Zustand startet im Eingang", function()
  local z = welt.neuer_zustand()
  assert(z.raum == "eingang", "raum: " .. z.raum)
  assert(#z.inventar == 0, "Inventar nicht leer")
  assert(not z.gewonnen, "schon gewonnen")
end)

test("gehe wechselt den Raum", function()
  local z = welt.neuer_zustand()
  spiele(z, "osten")
  assert(z.raum == "garten", "raum: " .. z.raum)
end)

test("unbekannte Richtung wird abgelehnt", function()
  local z = welt.neuer_zustand()
  local antwort = spiele(z, "gehe himmel")
  assert(antwort == "Wohin? Zum Beispiel: gehe norden" or antwort == "Dorthin kannst du nicht gehen.", antwort)
  assert(z.raum == "eingang", "raum hat sich geändert")
end)

test("Ausgang ohne Weg wird abgelehnt", function()
  local z = welt.neuer_zustand()
  local antwort = spiele(z, "westen")
  assert(antwort == "Dorthin kannst du nicht gehen.", antwort)
end)

test("gesperrter Ausgang braucht den Gegenstand", function()
  local z = welt.neuer_zustand()
  spiele(z, "norden", "westen")
  assert(z.raum == "halle", "raum: " .. z.raum)
  local antwort = spiele(z, "westen")
  assert(antwort:find("versperrt", 1, true), antwort)
  assert(z.raum == "halle", "trotz Sperre gegangen")
end)

test("nimm legt einen Gegenstand ins Inventar", function()
  local z = welt.neuer_zustand()
  spiele(z, "osten", "nimm fackel")
  assert(z.inventar[1] == "fackel", "Inventar fehlt fackel")
  assert(#z.sachen.garten == 0, "Gegenstand liegt noch im Raum")
end)

test("nimm mit Anzeigenamen funktioniert", function()
  local z = welt.neuer_zustand()
  spiele(z, "osten")
  local antwort = spiele(z, "nimm Fackel")
  assert(antwort == "Du nimmst: Fackel.", antwort)
end)

test("nimm eines fehlenden Gegenstands wird abgelehnt", function()
  local z = welt.neuer_zustand()
  local antwort = spiele(z, "nimm fackel")
  assert(antwort == "Hier gibt es so etwas nicht.", antwort)
end)

test("lege legt den Gegenstand im Raum ab", function()
  local z = welt.neuer_zustand()
  spiele(z, "osten", "nimm fackel", "westen", "osten")
  spiele(z, "lege fackel")
  assert(#z.inventar == 0, "Inventar nicht leer")
  assert(z.sachen.garten[1] == "fackel", "Fackel nicht im Garten")
end)

test("komplette Lösung gewinnt das Spiel", function()
  local z = welt.neuer_zustand()
  spiele(z,
    "osten", "nimm fackel", "westen",   -- Fackel holen
    "norden",                           -- Halle
    "westen", "nimm schlüssel",         -- Keller, Fackel nötig
    "osten",
    "norden", "nimm schatz")            -- Schatzkammer mit Schlüssel
  assert(z.gewonnen, "nicht gewonnen")
end)

test("ohne Schlüssel kommt man nicht in die Schatzkammer", function()
  local z = welt.neuer_zustand()
  spiele(z, "osten", "nimm fackel", "westen", "norden")
  local antwort = spiele(z, "norden")
  assert(antwort:find("Schlüssel", 1, true), antwort)
  assert(z.raum == "halle", "trotzdem gegangen")
end)

test("inventar zeigt die Gegenstände", function()
  local z = welt.neuer_zustand()
  assert(spiele(z, "inventar") == "Du trägst nichts bei dir.")
  spiele(z, "osten", "nimm fackel")
  assert(spiele(z, "inventar") == "Du trägst bei dir: Fackel.")
end)

test("unbekannter Befehl wird freundlich abgelehnt", function()
  local z = welt.neuer_zustand()
  local antwort = spiele(z, "tanze")
  assert(antwort:find("hilfe", 1, true), antwort)
end)

test("Speichern und Laden ergibt den gleichen Zustand", function()
  local datei = "test_spielstand.txt"
  local z = welt.neuer_zustand()
  spiele(z, "osten", "nimm fackel", "westen", "norden", "westen")
  assert(speichern.speichere(z, datei))

  local geladen, meldung = speichern.lade(datei)
  os.remove(datei)
  assert(geladen, meldung)
  assert(geladen.raum == z.raum, "raum unterschiedlich")
  assert(table.concat(geladen.inventar, ",") == table.concat(z.inventar, ","), "inventar unterschiedlich")
  assert(table.concat(geladen.sachen.garten, ",") == "", "garten sollte leer sein")
  assert(geladen.gewonnen == false, "gewonnen falsch")
end)

test("laden einer fehlenden Datei meldet einen Fehler", function()
  local geladen, meldung = speichern.lade("gibt_es_nicht.txt")
  assert(geladen == nil and meldung, "kein Fehler gemeldet")
end)

print(string.format("\n%d Tests, %d fehlgeschlagen", anzahl, fehler))
os.exit(fehler == 0 and 0 or 1)
