-- ============================================================================
--  Das Abenteuer: finde den Schatz in der Burg.
--  Starten:  lua main.lua
-- ============================================================================

-- Die Module liegen neben dieser Datei, daher den Pfad dorthin setzen.
local verzeichnis = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"
package.path = verzeichnis .. "?.lua;" .. package.path

local welt = require("welt")
local befehle = require("befehle")
local speichern = require("speichern")

local SPIELSTAND = "spielstand.txt"

local zustand = welt.neuer_zustand()

print("=== Die Schatzsuche ===")
print("Tippe 'hilfe' für alle Befehle.\n")
print(befehle.raumtext(zustand))

while not zustand.gewonnen do
  io.write("\n> ")
  local eingabe = io.read()
  if not eingabe then
    break
  end
  local verb = eingabe:match("^%s*(%S*)") or ""
  verb = verb:lower()

  if verb == "ende" then
    print("Bis bald!")
    break
  elseif verb == "speichern" then
    local ok, meldung = speichern.speichere(zustand, SPIELSTAND)
    print(ok and "Spiel gespeichert." or ("Speichern fehlgeschlagen: " .. tostring(meldung)))
  elseif verb == "laden" then
    local neu, meldung = speichern.lade(SPIELSTAND)
    if neu then
      zustand = neu
      print("Spielstand geladen.\n" .. befehle.raumtext(zustand))
    else
      print(meldung)
    end
  else
    print(befehle.verarbeite(zustand, eingabe))
  end
end

if zustand.gewonnen then
  print("\n*** Glückwunsch! Du hast den Schatz gefunden. ***")
end
