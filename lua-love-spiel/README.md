# Münzjagd (LÖVE)

Ein kleines Spiel mit [LÖVE](https://love2d.org), dem Spiele-Framework für Lua.
Du steuerst ein Quadrat mit den Pfeiltasten und sammelst Münzen, bevor die 30 Sekunden ablaufen.

## Starten

1. LÖVE installieren (https://love2d.org, Version 11.x).
2. Den Ordner `lua-love-spiel` mit LÖVE öffnen:
   - Terminal im Ordner: `love .`
   - oder LÖVE starten und den Ordner per Drag and Drop hineinziehen.

Steuerung: Pfeiltasten bewegen, `R` startet nach dem Ende neu, `ESC` beendet.

## Was du hier lernst

- **Module:** `logik.lua` gibt eine Tabelle zurück, `main.lua` lädt sie mit `require`.
- **Spielschleife:** `love.load` richtet alles ein, `love.update(dt)` rechnet jeden Frame,
  `love.draw` zeichnet. `dt` ist die Zeit seit dem letzten Frame.
- **Trennung von Logik und Darstellung:** Die Logik in `logik.lua` kommt ohne LÖVE aus
  und lässt sich mit normalem Lua testen.

## Tests

Die Spiellogik lässt sich ohne LÖVE testen:

```bash
cd lua-love-spiel
lua tests.lua
```

## Ideen zum Weiterbauen

- Schwierigkeit steigern: die Münzen schneller spawnen lassen oder die Zeit verkürzen.
- Ein Highscore-Datei anlegen (mit `io.open` aus Kurs 2 in `lua-lernspiel`).
- Gegner hinzufügen, die sich auf den Spieler zubewegen, und `beruehrt` für Treffer nutzen.
- Eigene Tests für neue Funktionen in `tests.lua` schreiben.
