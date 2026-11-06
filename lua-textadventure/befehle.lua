-- ============================================================================
--  Befehlsverarbeitung: wandelt eine Eingabe wie "nimm fackel" in eine
--  Änderung des Spielzustands und liefert den Text für den Spieler zurück.
-- ============================================================================

local welt = require("welt")

local befehle = {}

-- Richtungen, auch mit Kurzformen.
local RICHTUNGEN = {
  norden = "norden", n = "norden",
  sueden = "sueden", ["süden"] = "sueden", s = "sueden",
  osten = "osten", o = "osten",
  westen = "westen", w = "westen",
}

local function enthaelt(liste, wert)
  for _, v in ipairs(liste) do
    if v == wert then
      return true
    end
  end
  return false
end

local function entferne(liste, wert)
  for i, v in ipairs(liste) do
    if v == wert then
      table.remove(liste, i)
      return true
    end
  end
  return false
end

-- Gegenstand anhand seines Anzeigenamens finden, z. B. "Schlüssel" -> "schluessel".
local function finde_gegenstand(eingabe)
  for schluessel, gegenstand in pairs(welt.GEGENSTAENDE) do
    if eingabe == schluessel or eingabe == gegenstand.name:lower() then
      return schluessel
    end
  end
  return nil
end

local function raumtext(zustand)
  local raum = welt.RAEUME[zustand.raum]
  local zeilen = { raum.name, raum.beschreibung }

  local liegt = zustand.sachen[zustand.raum]
  if #liegt > 0 then
    local namen = {}
    for _, g in ipairs(liegt) do
      table.insert(namen, welt.GEGENSTAENDE[g].name)
    end
    table.insert(zeilen, "Hier liegt: " .. table.concat(namen, ", ") .. ".")
  end

  local richtungen = {}
  for richtung in pairs(raum.ausgaenge) do
    table.insert(richtungen, richtung)
  end
  table.sort(richtungen)
  table.insert(zeilen, "Ausgänge: " .. table.concat(richtungen, ", ") .. ".")

  return table.concat(zeilen, "\n")
end

local function gehe(zustand, richtung)
  local raum = welt.RAEUME[zustand.raum]
  local ausgang = raum.ausgaenge[richtung]
  if not ausgang then
    return "Dorthin kannst du nicht gehen."
  end
  if ausgang.sperre and not enthaelt(zustand.inventar, ausgang.sperre) then
    return "Der Weg ist versperrt. Du brauchst: " .. welt.GEGENSTAENDE[ausgang.sperre].name .. "."
  end
  zustand.raum = ausgang.ziel
  return raumtext(zustand)
end

local function nimm(zustand, name)
  local schluessel = finde_gegenstand(name)
  local liegt = zustand.sachen[zustand.raum]
  if not schluessel or not enthaelt(liegt, schluessel) then
    return "Hier gibt es so etwas nicht."
  end
  entferne(liegt, schluessel)
  table.insert(zustand.inventar, schluessel)
  if schluessel == welt.ZIEL then
    zustand.gewonnen = true
    return "Du nimmst den Schatz. Du hast gewonnen!"
  end
  return "Du nimmst: " .. welt.GEGENSTAENDE[schluessel].name .. "."
end

local function lege(zustand, name)
  local schluessel = finde_gegenstand(name)
  if not schluessel or not enthaelt(zustand.inventar, schluessel) then
    return "Das hast du nicht dabei."
  end
  entferne(zustand.inventar, schluessel)
  table.insert(zustand.sachen[zustand.raum], schluessel)
  return "Du legst " .. welt.GEGENSTAENDE[schluessel].name .. " ab."
end

local function inventar(zustand)
  if #zustand.inventar == 0 then
    return "Du trägst nichts bei dir."
  end
  local namen = {}
  for _, g in ipairs(zustand.inventar) do
    table.insert(namen, welt.GEGENSTAENDE[g].name)
  end
  return "Du trägst bei dir: " .. table.concat(namen, ", ") .. "."
end

local HILFE = [[
Befehle:
  schau                 Umgebung beschreiben
  gehe <richtung>       z. B. "gehe norden" oder nur "n"
  nimm <gegenstand>     Gegenstand aufheben
  lege <gegenstand>     Gegenstand ablegen
  inventar              mitgeführte Gegenstände zeigen
  speichern / laden     Spielstand sichern oder laden
  ende                  Spiel beenden]]

-- Verarbeitet eine Eingabe und gibt den Antworttext zurück.
-- speichern, laden und ende behandelt main.lua, weil dort die Dateien liegen.
function befehle.verarbeite(zustand, eingabe)
  local verb, rest = eingabe:match("^%s*(%S*)%s*(.-)%s*$")
  verb = verb:lower()

  if RICHTUNGEN[verb] then
    return gehe(zustand, RICHTUNGEN[verb])
  elseif verb == "gehe" then
    local richtung = RICHTUNGEN[rest:lower()]
    if not richtung then
      return "Wohin? Zum Beispiel: gehe norden"
    end
    return gehe(zustand, richtung)
  elseif verb == "schau" then
    return raumtext(zustand)
  elseif verb == "nimm" then
    return nimm(zustand, rest:lower())
  elseif verb == "lege" then
    return lege(zustand, rest:lower())
  elseif verb == "inventar" or verb == "i" then
    return inventar(zustand)
  elseif verb == "hilfe" then
    return HILFE
  elseif verb == "" then
    return "Bitte gib einen Befehl ein. Mit 'hilfe' siehst du alle Befehle."
  end
  return "Das verstehe ich nicht. Mit 'hilfe' siehst du alle Befehle."
end

-- Zum Testen und für main.lua: Beschreibung des aktuellen Raums.
befehle.raumtext = raumtext

return befehle
