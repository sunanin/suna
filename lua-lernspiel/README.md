# Lua-Quest

Ein kleines Terminal-Spiel, mit dem du Lua Schritt für Schritt lernst.
Jedes Level erklärt ein Konzept, zeigt ein Beispiel und stellt eine Aufgabe.
Du schreibst den Code selbst, das Spiel führt ihn aus und prüft die Ergebnisse.

## Starten

Du brauchst nur den Lua-Interpreter (Version 5.3 oder 5.4):

```bash
# Linux (Debian/Ubuntu)
sudo apt install lua5.4
# macOS
brew install lua

cd lua-lernspiel
lua main.lua          # vom ersten Level an
lua main.lua 4        # direkt bei Level 4 starten
```

## Bedienung

- Code Zeile für Zeile eingeben, mit einem einzelnen `.` in einer eigenen Zeile abschließen.
- `/hinweis` zeigt einen Tipp.
- `/loesung` zeigt die Musterlösung und geht zum nächsten Level.
- `/quit` beendet das Spiel.

## Levels

1. Hallo Welt (`print`)
2. Variablen
3. Rechnen
4. Entscheidungen (`if`)
5. Schleifen (`for`)
6. Funktionen
7. Tabellen
8. Boss-Level: Summe (Funktionen, Tabellen und Schleifen zusammen)

## Selbsttest

```bash
lua main.lua --selbsttest
```

Prüft, dass alle Musterlösungen die Tests bestehen. Nützlich, wenn du selbst Levels änderst oder ergänzt.

## Eigene Levels hinzufügen

Jedes Level in `main.lua` in der Liste `LEVELS` hat diese Felder:

- `titel`, `erklaerung`, `beispiel`, `aufgabe`, `hinweis`, `loesung`
- `tests`: Liste von Prüfungen. Jede Prüfung hat `erwartet` (die Ausgabe) und entweder
  - `setup = { name = wert }`: Variablen, die vor dem Code gesetzt werden, oder
  - `aufruf = "funktion(3)"`: ein Ausdruck, dessen Ergebnis geprüft wird.
