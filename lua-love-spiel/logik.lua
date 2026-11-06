-- ============================================================================
--  Spiellogik ohne LÖVE-Aufrufe. Dadurch kann man sie mit reinem Lua testen:
--  lua tests.lua
-- ============================================================================

local logik = {}

-- Schwierigkeitsgrade: Zeit, Spawn-Abstand (Sekunden), Anzahl und Tempo der Gegner.
logik.schwierigkeiten = {
  leicht = { name = "Leicht", zeit = 45, spawn = 1.0, gegner = 0, tempo = 0 },
  mittel = { name = "Mittel", zeit = 30, spawn = 0.8, gegner = 2, tempo = 90 },
  schwer = { name = "Schwer", zeit = 30, spawn = 0.5, gegner = 4, tempo = 150 },
}

-- Ein Quadrat (Spieler, Münze oder Gegner) mit Position und Kantenlänge.
function logik.neues_objekt(x, y, groesse)
  return { x = x, y = y, groesse = groesse }
end

-- Bewegt den Spieler, bleibt aber innerhalb des Fensters.
function logik.bewege(spieler, dx, dy, geschwindigkeit, dt, breite, hoehe)
  local neu_x = spieler.x + dx * geschwindigkeit * dt
  local neu_y = spieler.y + dy * geschwindigkeit * dt
  spieler.x = math.max(0, math.min(breite - spieler.groesse, neu_x))
  spieler.y = math.max(0, math.min(hoehe - spieler.groesse, neu_y))
  return spieler
end

-- Prüft, ob sich zwei Quadrate überlappen (AABB-Kollision).
function logik.beruehrt(a, b)
  return a.x < b.x + b.groesse and a.x + a.groesse > b.x
     and a.y < b.y + b.groesse and a.y + a.groesse > b.y
end

-- Erzeugt eine Münze an einer zufälligen Stelle im Fenster.
function logik.neue_muenze(breite, hoehe, groesse)
  local x = math.random(0, breite - groesse)
  local y = math.random(0, hoehe - groesse)
  return logik.neues_objekt(x, y, groesse)
end

-- Entfernt alle Münzen, die der Spieler berührt. Gibt die Anzahl zurück.
function logik.sammle(spieler, muenzen)
  local gesammelt = 0
  for i = #muenzen, 1, -1 do
    if logik.beruehrt(spieler, muenzen[i]) then
      table.remove(muenzen, i)
      gesammelt = gesammelt + 1
    end
  end
  return gesammelt
end

-- Erzeugt einen Gegner an einem zufälligen Rand des Fensters.
function logik.neuer_gegner(breite, hoehe, groesse)
  local seite = math.random(1, 4)
  local x, y
  if seite == 1 then
    x, y = 0, math.random(0, hoehe - groesse)
  elseif seite == 2 then
    x, y = breite - groesse, math.random(0, hoehe - groesse)
  elseif seite == 3 then
    x, y = math.random(0, breite - groesse), 0
  else
    x, y = math.random(0, breite - groesse), hoehe - groesse
  end
  return logik.neues_objekt(x, y, groesse)
end

-- Bewegt einen Gegner geradlinig auf das Ziel zu, ohne darüber hinauszuschießen.
function logik.jage(gegner, ziel, tempo, dt)
  local dx = ziel.x - gegner.x
  local dy = ziel.y - gegner.y
  local abstand = math.sqrt(dx * dx + dy * dy)
  local schritt = tempo * dt
  if abstand == 0 or abstand <= schritt then
    gegner.x, gegner.y = ziel.x, ziel.y
  else
    gegner.x = gegner.x + dx / abstand * schritt
    gegner.y = gegner.y + dy / abstand * schritt
  end
  return gegner
end

-- Fügt einen Punktestand in die Highscore-Liste ein.
-- Die Liste bleibt absteigend sortiert und hat höchstens max Einträge.
function logik.highscore_einfuegen(liste, punkte, max)
  local neu = {}
  for i, p in ipairs(liste) do
    neu[i] = p
  end
  neu[#neu + 1] = punkte
  table.sort(neu, function(a, b) return a > b end)
  while #neu > max do
    table.remove(neu)
  end
  return neu
end

-- Wandelt die Highscore-Liste in Text um (eine Zahl pro Zeile).
function logik.highscore_zu_text(liste)
  local zeilen = {}
  for _, p in ipairs(liste) do
    zeilen[#zeilen + 1] = tostring(p)
  end
  return table.concat(zeilen, "\n")
end

-- Liest die Highscore-Liste aus Text. Ungültige Zeilen werden übersprungen.
function logik.highscore_aus_text(text)
  local liste = {}
  for zeile in string.gmatch(text or "", "[^\n]+") do
    local zahl = tonumber(zeile)
    if zahl then
      liste[#liste + 1] = math.floor(zahl)
    end
  end
  table.sort(liste, function(a, b) return a > b end)
  return liste
end

return logik
