-- ============================================================================
--  Spiellogik ohne LÖVE-Aufrufe. Dadurch kann man sie mit reinem Lua testen:
--  lua tests.lua
-- ============================================================================

local logik = {}

-- Ein Quadrat (Spieler oder Münze) mit Position und Kantenlänge.
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

return logik
