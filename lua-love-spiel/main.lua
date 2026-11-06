-- ============================================================================
--  Münzjagd: sammle Münzen und weiche den Gegnern aus.
--  Steuerung: Pfeiltasten. Im Menü 1/2/3 für den Schwierigkeitsgrad.
--  R = zurück zum Menü nach dem Ende, ESC = Spiel verlassen bzw. zum Menü.
-- ============================================================================

local logik = require("logik")

local SPIELER_GROESSE = 32
local MUENZ_GROESSE = 16
local GEGNER_GROESSE = 24
local SPIELER_TEMPO = 280
local HIGHSCORE_DATEI = "highscores.txt"
local HIGHSCORE_PLATZE = 5

local spiel
local highscores = {}

-- Highscores liegen im Speicherordner von LÖVE. Fehlt die Datei, ist die Liste leer.
local function lade_highscores()
  highscores = logik.highscore_aus_text(love.filesystem.read(HIGHSCORE_DATEI))
end

local function speichere_highscores()
  love.filesystem.write(HIGHSCORE_DATEI, logik.highscore_zu_text(highscores))
end

local function starte(schluessel)
  local einstellung = logik.schwierigkeiten[schluessel]
  local breite, hoehe = love.graphics.getDimensions()
  spiel = {
    modus = "spiel",
    einstellung = einstellung,
    spieler = logik.neues_objekt(
      breite / 2 - SPIELER_GROESSE / 2, hoehe / 2 - SPIELER_GROESSE / 2, SPIELER_GROESSE),
    muenzen = {},
    gegner = {},
    punkte = 0,
    zeit = einstellung.zeit,
    seit_spawn = 0,
    grund = nil,
  }
  for _ = 1, einstellung.gegner do
    table.insert(spiel.gegner, logik.neuer_gegner(breite, hoehe, GEGNER_GROESSE))
  end
end

-- Beendet das Spiel und trägt den Punktestand in die Highscores ein.
local function ende(grund)
  spiel.modus = "vorbei"
  spiel.grund = grund
  highscores = logik.highscore_einfuegen(highscores, spiel.punkte, HIGHSCORE_PLATZE)
  speichere_highscores()
end

function love.load()
  math.randomseed(os.time())
  lade_highscores()
  spiel = { modus = "menue" }
end

function love.update(dt)
  if spiel.modus ~= "spiel" then
    return
  end
  local einstellung = spiel.einstellung

  -- Richtung aus den gedrückten Pfeiltasten berechnen.
  local dx, dy = 0, 0
  if love.keyboard.isDown("left") then dx = dx - 1 end
  if love.keyboard.isDown("right") then dx = dx + 1 end
  if love.keyboard.isDown("up") then dy = dy - 1 end
  if love.keyboard.isDown("down") then dy = dy + 1 end

  local breite, hoehe = love.graphics.getDimensions()
  logik.bewege(spiel.spieler, dx, dy, SPIELER_TEMPO, dt, breite, hoehe)

  -- Münzen erzeugen und einsammeln.
  spiel.seit_spawn = spiel.seit_spawn + dt
  if spiel.seit_spawn >= einstellung.spawn then
    spiel.seit_spawn = 0
    table.insert(spiel.muenzen, logik.neue_muenze(breite, hoehe, MUENZ_GROESSE))
  end
  spiel.punkte = spiel.punkte + logik.sammle(spiel.spieler, spiel.muenzen)

  -- Gegner jagen den Spieler. Ein Treffer beendet das Spiel.
  for _, g in ipairs(spiel.gegner) do
    logik.jage(g, spiel.spieler, einstellung.tempo, dt)
    if logik.beruehrt(spiel.spieler, g) then
      ende("Ein Gegner hat dich erwischt!")
      return
    end
  end

  spiel.zeit = spiel.zeit - dt
  if spiel.zeit <= 0 then
    spiel.zeit = 0
    ende("Die Zeit ist abgelaufen!")
  end
end

local function zeichne_menue()
  local breite = love.graphics.getWidth()
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("MÜNZJAGD", 0, 80, breite, "center")
  love.graphics.printf("1 = Leicht     2 = Mittel     3 = Schwer", 0, 150, breite, "center")

  love.graphics.printf("Highscores", 0, 230, breite, "center")
  if #highscores == 0 then
    love.graphics.printf("noch keine Einträge", 0, 260, breite, "center")
  end
  for platz, punkte in ipairs(highscores) do
    love.graphics.printf(string.format("%d.  %d", platz, punkte), 0, 250 + platz * 24, breite, "center")
  end
end

local function zeichne_spiel()
  love.graphics.setColor(1, 0.85, 0)
  for _, m in ipairs(spiel.muenzen) do
    love.graphics.rectangle("fill", m.x, m.y, m.groesse, m.groesse)
  end

  love.graphics.setColor(1, 0.3, 0.3)
  for _, g in ipairs(spiel.gegner) do
    love.graphics.rectangle("fill", g.x, g.y, g.groesse, g.groesse)
  end

  love.graphics.setColor(0.3, 0.7, 1)
  local s = spiel.spieler
  love.graphics.rectangle("fill", s.x, s.y, s.groesse, s.groesse)

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format("%s  Punkte: %d", spiel.einstellung.name, spiel.punkte), 10, 10)
  love.graphics.print(string.format("Zeit: %d", math.ceil(spiel.zeit)), 10, 30)
end

local function zeichne_vorbei()
  local breite, hoehe = love.graphics.getDimensions()
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(
    string.format("%s\nPunkte: %d\n\nR = zurück zum Menü", spiel.grund, spiel.punkte),
    0, hoehe / 2 - 40, breite, "center")
end

function love.draw()
  if spiel.modus == "menue" then
    zeichne_menue()
  else
    zeichne_spiel()
    if spiel.modus == "vorbei" then
      zeichne_vorbei()
    end
  end
end

function love.keypressed(taste)
  if spiel.modus == "menue" then
    if taste == "1" then starte("leicht")
    elseif taste == "2" then starte("mittel")
    elseif taste == "3" then starte("schwer")
    elseif taste == "escape" then love.event.quit()
    end
  elseif spiel.modus == "spiel" then
    if taste == "escape" then
      spiel = { modus = "menue" }
    end
  elseif spiel.modus == "vorbei" then
    if taste == "r" then
      spiel = { modus = "menue" }
    end
  end
end
