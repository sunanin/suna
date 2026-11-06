-- ============================================================================
--  Spielstand als Textdatei speichern und wieder laden.
--  Das Format ist einfach gehalten, damit du es mit einem Texteditor lesen kannst:
--    raum=garten
--    inventar=fackel,schluessel
--    sachen.garten=
--    gewonnen=false
-- ============================================================================

local welt = require("welt")

local speichern = {}

-- Macht aus "a,b,c" eine Liste {"a", "b", "c"}. Leerer Text ergibt eine leere Liste.
local function liste_aus(text)
  local liste = {}
  for teil in string.gmatch(text, "[^,]+") do
    table.insert(liste, teil)
  end
  return liste
end

-- Schreibt den Zustand in eine Datei. Gibt true oder false und eine Meldung zurück.
function speichern.speichere(zustand, dateiname)
  local f, meldung = io.open(dateiname, "w")
  if not f then
    return false, meldung
  end

  f:write("raum=" .. zustand.raum .. "\n")
  f:write("inventar=" .. table.concat(zustand.inventar, ",") .. "\n")

  -- Räume sortiert schreiben, damit die Datei immer gleich aussieht.
  local raeume = {}
  for raum in pairs(zustand.sachen) do
    table.insert(raeume, raum)
  end
  table.sort(raeume)
  for _, raum in ipairs(raeume) do
    f:write("sachen." .. raum .. "=" .. table.concat(zustand.sachen[raum], ",") .. "\n")
  end

  f:write("gewonnen=" .. tostring(zustand.gewonnen) .. "\n")
  f:close()
  return true
end

-- Liest einen Spielstand. Gibt den Zustand zurück, oder nil und eine Meldung.
function speichern.lade(dateiname)
  local f = io.open(dateiname, "r")
  if not f then
    return nil, "Kein Spielstand gefunden."
  end

  local zustand = welt.neuer_zustand()
  zustand.inventar = {}
  zustand.sachen = {}
  for raum in pairs(welt.RAEUME) do
    zustand.sachen[raum] = {}
  end

  while true do
    local zeile = f:read("l")
    if not zeile then
      break
    end
    local schluessel, wert = zeile:match("^([^=]+)=(.*)$")
    if schluessel == "raum" then
      zustand.raum = wert
    elseif schluessel == "inventar" then
      zustand.inventar = liste_aus(wert)
    elseif schluessel == "gewonnen" then
      zustand.gewonnen = wert == "true"
    else
      local raum = schluessel and schluessel:match("^sachen%.(.+)$")
      if raum then
        zustand.sachen[raum] = liste_aus(wert)
      end
    end
  end
  f:close()

  if not welt.RAEUME[zustand.raum] then
    return nil, "Der Spielstand ist beschädigt."
  end
  return zustand
end

return speichern
