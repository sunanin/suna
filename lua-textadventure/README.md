# Die Schatzsuche (Textadventure)

Ein Textadventure im Terminal. Du bist in einer alten Burg und musst den Schatz finden.
Gesteuert wird mit Textbefehlen.

## Starten

Nur Lua 5.3 oder 5.4 nötig:

```bash
cd lua-textadventure
lua main.lua
```

Befehle: `hilfe`, `schau`, `gehe <richtung>` (oder nur `n`, `s`, `o`, `w`),
`nimm <gegenstand>`, `lege <gegenstand>`, `inventar`, `speichern`, `laden`, `ende`.

Tipp: Der Schatz ist gut versteckt. Überlege, welche Gegenstände du brauchst und wo du sie findest.

## Aufbau: mehrere Module

Das Projekt ist in Module aufgeteilt, jede Datei hat eine klare Aufgabe:

| Datei         | Aufgabe                                                              |
|---------------|----------------------------------------------------------------------|
| `welt.lua`    | Räume, Gegenstände und der Startzustand, nur Daten                    |
| `befehle.lua` | verarbeitet Eingaben und ändert den Zustand, gibt Text zurück         |
| `speichern.lua` | schreibt den Zustand in eine Textdatei und liest ihn wieder ein   |
| `main.lua`    | die Spielschleife, lädt die Module mit `require`                      |
| `tests.lua`   | Tests für Befehle und Speichern                                       |

`befehle.lua` kennt keine Ein- und Ausgabe. Dadurch lässt es sich mit `tests.lua` prüfen,
ohne ein Spiel zu starten.

## Tests

```bash
lua tests.lua
```

## Ideen zum Weiterbauen

- Einen neuen Raum mit einem Rätsel hinzufügen. Dafür brauchst du nur einen Eintrag in `welt.RAEUME`
  und eventuell eine Sperre.
- Einen Befehl `benutze <gegenstand>` einbauen, z. B. um den Brunnen zu benutzen.
- Für jeden neuen Befehl zuerst einen Test in `tests.lua` schreiben.
