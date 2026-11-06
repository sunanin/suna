# Münzjagd (LÖVE)

Ein kleines Spiel mit [LÖVE](https://love2d.org), dem Spiele-Framework für Lua.
Du steuerst ein Quadrat mit den Pfeiltasten und sammelst Münzen. Gegner jagen dich,
und die Zeit läuft. Im Menü wählst du den Schwierigkeitsgrad (1 Leicht, 2 Mittel, 3 Schwer).
Die Top 5 werden in einer Highscore-Datei gespeichert.

## Starten

1. LÖVE installieren (https://love2d.org, Version 11.x).
2. Den Ordner `lua-love-spiel` mit LÖVE öffnen:
   - Terminal im Ordner: `love .`
   - oder LÖVE starten und den Ordner per Drag and Drop hineinziehen.

Steuerung: Pfeiltasten bewegen, `1`/`2`/`3` im Menü wählt den Schwierigkeitsgrad,
`R` führt nach dem Ende zurück ins Menü, `ESC` geht ins Menü bzw. beendet das Programm.

## Was du hier lernst

- **Module:** `logik.lua` gibt eine Tabelle zurück, `main.lua` lädt sie mit `require`.
- **Spielschleife:** `love.load` richtet alles ein, `love.update(dt)` rechnet jeden Frame,
  `love.draw` zeichnet. `dt` ist die Zeit seit dem letzten Frame.
- **Trennung von Logik und Darstellung:** Die Logik in `logik.lua` kommt ohne LÖVE aus
  und lässt sich mit normalem Lua testen.
- **Gegner und Vektoren:** `logik.jage` bewegt einen Gegner Schritt für Schritt auf ein Ziel zu.
- **Speichern:** Highscores werden mit `love.filesystem` im Speicherordner von LÖVE abgelegt.
  Die Umwandlung von Liste zu Text und zurück steht in `logik.lua`, damit man sie testen kann.

## Tests

Die Spiellogik lässt sich ohne LÖVE testen:

```bash
cd lua-love-spiel
lua tests.lua
```

## Ideen zum Weiterbauen

- Gegner nach einer Weile nachspawnen lassen, damit es mit der Zeit schwerer wird.
- Name eingeben lassen und den Namen mit dem Punktestand speichern.
- Power-ups einbauen, z. B. eine Münze, die die Gegner kurz anhält.
- Für jede neue Funktion einen Test in `tests.lua` schreiben, bevor du sie in `main.lua` einbaust.
