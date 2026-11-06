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
lua main.lua          # Kurs 1 vom ersten Level an
lua main.lua 2        # Kurs 2 (Module, Dateien, Tests, Objekte)
lua main.lua 1 9      # Kurs 1, direkt bei Level 9
```

## Bedienung

- Code Zeile für Zeile eingeben, mit einem einzelnen `.` in einer eigenen Zeile abschließen.
- `/hinweis` zeigt einen Tipp.
- `/loesung` zeigt die Musterlösung und geht zum nächsten Level.
- `/quit` beendet das Spiel.

## Kurs 1: Grundlagen

21 Level in 8 Kapiteln plus Abschlussprojekt:

1. **Grundlagen:** Hallo Welt, Variablen, Rechnen, Datentypen
2. **Kontrollfluss:** if, for, while, break
3. **Texte:** Länge und Groß/Klein, Suchen und Ersetzen, string.format
4. **Tabellen:** Listen (insert, concat), Schlüssel-Wert-Tabellen (pairs), sortieren, Summe
5. **Funktionen vertieft:** mehrere Werte und Varargs, Closures
6. **Fehler:** error und pcall
7. **Objekte:** Metatables, eigene Klasse `Konto`
8. **Coroutines:** Werte nach und nach erzeugen
9. **Abschlussprojekt:** Wörter zählen

## Kurs 2: Module, Dateien, Tests

9 Level, die auf Kurs 1 aufbauen:

1. **Module:** eigenes Modul schreiben, `require` verwenden
2. **Dateien:** lesen, schreiben, anhängen (in einer virtuellen Datei im Speicher, es werden keine echten Dateien verändert)
3. **Tests:** einen eigenen Test-Runner mit `pcall` schreiben
4. **Objekte vertieft:** Metamethoden (`__add`, `__eq`, `__tostring`) und Vererbung
5. **Abschlussprojekt:** Inventar in einer Datei speichern und wieder laden

Den Kurs-2-Code findest du in `kurs2.lua`.

## Selbsttest

```bash
lua main.lua --selbsttest
```

Prüft für beide Kurse, dass alle Musterlösungen die Tests bestehen. Nützlich, wenn du selbst Levels änderst oder ergänzt.

## Eigene Levels hinzufügen

Jedes Level in `main.lua` in der Liste `LEVELS` hat diese Felder:

- `kapitel` (optional, zeigt eine Kapitelüberschrift), `titel`, `erklaerung`, `beispiel`, `aufgabe`, `hinweis`, `loesung`
- `tests`: Liste von Prüfungen. Jede Prüfung hat `erwartet` (die Ausgabe) und entweder
  - `setup = { name = wert }`: Variablen, die vor dem Code gesetzt werden, oder
  - `aufruf = "funktion(3)"`: ein Ausdruck, dessen Ergebnis geprüft wird.
  - optional `zusatz = "..."`: Lua-Code, der vor dem Aufruf ausgeführt wird (z. B. Objekte anlegen).
- Für Kurs 2 zusätzlich: `modul = true` (Code endet mit `return M`), `bibliothek = {...}` (Module für `require`) und `dateien = {...}` (virtuelle Dateien).
