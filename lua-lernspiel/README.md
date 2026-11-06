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
lua main.lua 9        # direkt bei Level 9 starten
```

## Bedienung

- Code Zeile für Zeile eingeben, mit einem einzelnen `.` in einer eigenen Zeile abschließen.
- `/hinweis` zeigt einen Tipp.
- `/loesung` zeigt die Musterlösung und geht zum nächsten Level.
- `/quit` beendet das Spiel.

## Levels

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

## Selbsttest

```bash
lua main.lua --selbsttest
```

Prüft, dass alle Musterlösungen die Tests bestehen. Nützlich, wenn du selbst Levels änderst oder ergänzt.

## Eigene Levels hinzufügen

Jedes Level in `main.lua` in der Liste `LEVELS` hat diese Felder:

- `kapitel` (optional, zeigt eine Kapitelüberschrift), `titel`, `erklaerung`, `beispiel`, `aufgabe`, `hinweis`, `loesung`
- `tests`: Liste von Prüfungen. Jede Prüfung hat `erwartet` (die Ausgabe) und entweder
  - `setup = { name = wert }`: Variablen, die vor dem Code gesetzt werden, oder
  - `aufruf = "funktion(3)"`: ein Ausdruck, dessen Ergebnis geprüft wird.
  - optional `zusatz = "..."`: Lua-Code, der vor dem Aufruf ausgeführt wird (z. B. Objekte anlegen).
