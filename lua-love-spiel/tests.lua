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
    logik.neues_objekt(2, 2, 5),    -- berührt
    logik.neues_objekt(500, 500, 5), -- weit weg
    logik.neues_objekt(8, 0, 5),    -- berührt
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

print(string.format("\n%d Tests, %d fehlgeschlagen", anzahl, fehler))
os.exit(fehler == 0 and 0 or 1)
