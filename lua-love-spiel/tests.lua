-- Tests für die Spiellogik. Ausführen mit:  lua tests.lua
package.path = "./?.lua;" .. package.path
local logik = require("logik")

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

test("beruehrt erkennt Überlappung", function()
  local a = logik.neues_objekt(0, 0, 10)
  local b = logik.neues_objekt(5, 5, 10)
  assert(logik.beruehrt(a, b), "sollte sich berühren")
end)

test("beruehrt erkennt Abstand", function()
  local a = logik.neues_objekt(0, 0, 10)
  local b = logik.neues_objekt(50, 50, 10)
  assert(not logik.beruehrt(a, b), "sollte sich nicht berühren")
end)

test("bewege bewegt den Spieler", function()
  local s = logik.neues_objekt(100, 100, 10)
  logik.bewege(s, 1, 0, 200, 0.5, 800, 600)
  assert(s.x == 200 and s.y == 100, "x=" .. s.x .. " y=" .. s.y)
end)

test("bewege bleibt im Fenster", function()
  local s = logik.neues_objekt(790, 0, 10)
  logik.bewege(s, 1, -1, 1000, 1, 800, 600)
  assert(s.x == 790 and s.y == 0, "x=" .. s.x .. " y=" .. s.y)
end)

test("sammle entfernt berührte Münzen und zählt sie", function()
  local s = logik.neues_objekt(0, 0, 10)
  local muenzen = {
    logik.neues_objekt(2, 2, 5),     -- berührt
    logik.neues_objekt(500, 500, 5), -- weit weg
    logik.neues_objekt(8, 0, 5),     -- berührt
  }
  local n = logik.sammle(s, muenzen)
  assert(n == 2, "gesammelt: " .. n)
  assert(#muenzen == 1 and muenzen[1].x == 500, "restliche Münze falsch")
end)

test("neue_muenze liegt im Fenster", function()
  math.randomseed(42)
  for _ = 1, 100 do
    local m = logik.neue_muenze(800, 600, 16)
    assert(m.x >= 0 and m.x <= 800 - 16, "x außerhalb: " .. m.x)
    assert(m.y >= 0 and m.y <= 600 - 16, "y außerhalb: " .. m.y)
  end
end)

test("neuer_gegner startet am Rand", function()
  math.randomseed(7)
  for _ = 1, 100 do
    local g = logik.neuer_gegner(800, 600, 20)
    local am_rand = g.x == 0 or g.y == 0 or g.x == 780 or g.y == 580
    assert(am_rand, "nicht am Rand: " .. g.x .. "," .. g.y)
  end
end)

test("jage bewegt Gegner Richtung Ziel", function()
  local g = logik.neues_objekt(0, 0, 10)
  local ziel = logik.neues_objekt(100, 0, 10)
  logik.jage(g, ziel, 50, 1)
  assert(g.x == 50 and g.y == 0, "x=" .. g.x .. " y=" .. g.y)
end)

test("jage überschießt das Ziel nicht", function()
  local g = logik.neues_objekt(0, 0, 10)
  local ziel = logik.neues_objekt(3, 4, 10)
  logik.jage(g, ziel, 1000, 1)
  assert(g.x == 3 and g.y == 4, "x=" .. g.x .. " y=" .. g.y)
end)

test("schwierigkeiten haben alle Werte", function()
  for _, name in ipairs({ "leicht", "mittel", "schwer" }) do
    local s = logik.schwierigkeiten[name]
    assert(s and s.zeit and s.spawn and s.gegner and s.tempo, name .. " unvollständig")
  end
  assert(logik.schwierigkeiten.schwer.gegner > logik.schwierigkeiten.mittel.gegner, "schwer hat nicht mehr Gegner")
end)

test("highscore_einfuegen sortiert und kürzt", function()
  local liste = logik.highscore_einfuegen({ 10, 5 }, 7, 2)
  assert(#liste == 2 and liste[1] == 10 and liste[2] == 7, "falsch: " .. table.concat(liste, ","))
end)

test("highscore_einfuegen verändert die alte Liste nicht", function()
  local alt = { 3 }
  logik.highscore_einfuegen(alt, 9, 5)
  assert(#alt == 1 and alt[1] == 3, "alte Liste wurde verändert")
end)

test("highscore Text hin und zurück", function()
  local liste = { 30, 12, 4 }
  local text = logik.highscore_zu_text(liste)
  local zurueck = logik.highscore_aus_text(text)
  assert(table.concat(zurueck, ",") == "30,12,4", "ergebnis: " .. table.concat(zurueck, ","))
end)

test("highscore_aus_text überspringt Unsinn", function()
  local liste = logik.highscore_aus_text("12\nkaputt\n\n7\n")
  assert(table.concat(liste, ",") == "12,7", "ergebnis: " .. table.concat(liste, ","))
end)

test("highscore_aus_text mit leerem Text", function()
  assert(#logik.highscore_aus_text(nil) == 0, "nicht leer")
end)

print(string.format("\n%d Tests, %d fehlgeschlagen", anzahl, fehler))
os.exit(fehler == 0 and 0 or 1)
