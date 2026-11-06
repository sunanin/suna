-- ============================================================================
--  Münzjagd: sammle so viele Münzen wie möglich, bevor die Zeit abläuft.
--  Steuerung: Pfeiltasten. R = neues Spiel, ESC = beenden.
-- ============================================================================

local logik = require("logik")

local SPIELER_GROESSE = 32
local MUENZ_GROESSE = 16
local GESCHWINDIGKEIT = 280
local SPAWN_INTERVALL = 0.8
local SPIELZEIT = 30

local spiel

local function neues_spiel()
  return {
    spieler = logik.neues_objekt(
      400 - SPIELER_GROESSE / 2, 300 - SPIELER_GROESSE / 2, SPIELER_GROESSE),
    muenzen = {},
    punkte = 0,
    zeit = SPIELZEIT,
    seit_spawn = 0,
    vorbei = false,
  }
end

function love.load()
  math.randomseed(os.time())
  spiel = neues_spiel()
end

function love.update(dt)
  if spiel.vorbei then
    return
  end

  -- Richtung aus den gedrückten Pfeiltasten berechnen.
  local dx, dy = 0, 0
  if love.keyboard.isDown("left") then dx = dx - 1 end
  if love.keyboard.isDown("right") then dx = dx + 1 end
  if love.keyboard.isDown("up") then dy = dy - 1 end
  if love.keyboard.isDown("down") then dy = dy + 1 end

  local breite, hoehe = love.graphics.getDimensions()
  logik.bewege(spiel.spieler, dx, dy, GESCHWINDIGKEIT, dt, breite, hoehe)

  -- Alle paar Sekunden eine neue Münze erzeugen.
  spiel.seit_spawn = spiel.seit_spawn + dt
  if spiel.seit_spawn >= SPAWN_INTERVALL then
    spiel.seit_spawn = 0
    table.insert(spiel.muenzen, logik.neue_muenze(breite, hoehe, MUENZ_GROESSE))
  end

  spiel.punkte = spiel.punkte + logik.sammle(spiel.spieler, spiel.muenzen)

  spiel.zeit = spiel.zeit - dt
  if spiel.zeit <= 0 then
    spiel.zeit = 0
    spiel.vorbei = true
  end
end

function love.draw()
  -- Münzen
  love.graphics.setColor(1, 0.85, 0)
  for _, m in ipairs(spiel.muenzen) do
    love.graphics.rectangle("fill", m.x, m.y, m.groesse, m.groesse)
  end

  -- Spieler
  love.graphics.setColor(0.3, 0.7, 1)
  local s = spiel.spieler
  love.graphics.rectangle("fill", s.x, s.y, s.groesse, s.groesse)

  -- Anzeige
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format("Punkte: %d", spiel.punkte), 10, 10)
  love.graphics.print(string.format("Zeit: %d", math.ceil(spiel.zeit)), 10, 30)

  if spiel.vorbei then
    local breite, hoehe = love.graphics.getDimensions()
    love.graphics.printf(
      string.format("Zeit vorbei!\nDu hast %d Münzen gesammelt.\n\nR drücken für ein neues Spiel", spiel.punkte),
      0, hoehe / 2 - 30, breite, "center")
  end
end

function love.keypressed(taste)
  if taste == "r" and spiel.vorbei then
    spiel = neues_spiel()
  elseif taste == "escape" then
    love.event.quit()
  end
end
