-- ============================================================================
--  Die Welt des Abenteuers: Räume und Gegenstände als reine Daten.
--  Dieses Modul wird mit require("welt") geladen.
-- ============================================================================

local welt = {}

welt.START_RAUM = "eingang"
welt.ZIEL = "schatz"

-- Räume: Beschreibung und Ausgänge. Ein Ausgang mit "sperre" braucht den
-- genannten Gegenstand im Inventar.
welt.RAEUME = {
  eingang = {
    name = "Burgeingang",
    beschreibung = "Du stehst vor einer alten Burg. Im Norden ragt ein Tor empor, im Osten liegt ein wilder Garten.",
    ausgaenge = {
      norden = { ziel = "halle" },
      osten = { ziel = "garten" },
    },
  },
  garten = {
    name = "Garten",
    beschreibung = "Hohes Gras und ein alter Brunnen. Auf dem Boden liegt eine Fackel.",
    ausgaenge = {
      westen = { ziel = "eingang" },
    },
  },
  halle = {
    name = "Große Halle",
    beschreibung = "Ein Kronleuchter hängt kalt von der Decke. Im Norden führt eine schwere Tür zur Schatzkammer, im Westen geht eine Treppe in die Dunkelheit hinab.",
    ausgaenge = {
      sueden = { ziel = "eingang" },
      norden = { ziel = "schatzkammer", sperre = "schluessel" },
      westen = { ziel = "keller", sperre = "fackel" },
    },
  },
  keller = {
    name = "Keller",
    beschreibung = "Es ist stockdunkel. Auf einem Fass liegt ein rostiger Schlüssel.",
    ausgaenge = {
      osten = { ziel = "halle" },
    },
  },
  schatzkammer = {
    name = "Schatzkammer",
    beschreibung = "Gold glänzt überall. In der Mitte steht eine offene Truhe.",
    ausgaenge = {
      sueden = { ziel = "halle" },
    },
  },
}

-- Gegenstände mit Anzeigename und Beschreibung.
welt.GEGENSTAENDE = {
  fackel = { name = "Fackel", beschreibung = "Eine Holzfackel, die noch gut brennt." },
  schluessel = { name = "Schlüssel", beschreibung = "Ein rostiger, aber stabiler Schlüssel." },
  schatz = { name = "Schatz", beschreibung = "Ein Beutel voller funkelnder Münzen!" },
}

-- Wo die Gegenstände am Anfang liegen.
welt.START_SACHEN = {
  garten = { "fackel" },
  keller = { "schluessel" },
  schatzkammer = { "schatz" },
}

-- Erzeugt einen frischen Spielzustand.
function welt.neuer_zustand()
  local sachen = {}
  for raum in pairs(welt.RAEUME) do
    sachen[raum] = {}
  end
  for raum, liste in pairs(welt.START_SACHEN) do
    for _, gegenstand in ipairs(liste) do
      table.insert(sachen[raum], gegenstand)
    end
  end
  return {
    raum = welt.START_RAUM,
    inventar = {},
    sachen = sachen,
    gewonnen = false,
  }
end

return welt
