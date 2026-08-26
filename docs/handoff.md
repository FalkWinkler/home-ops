# Handoff – Küchenbeleuchtung auf Sonoff ZBMINIR2 umbauen

**Stand:** 2026-08-26 (Befunde vom 2026-08-23 erhoben, seitdem unverändert)
**Status:** Konzept fertig, Umbau noch nicht begonnen. Vier Standortfakten fehlen (siehe [Offene Punkte](#offene-punkte)).
Phase 0 teilweise erledigt: Area gesetzt. Lampe 3 weiterhin nicht angelernt – **das blockiert den Umbau.**

**Empfehlung, noch nicht entschieden:** Detach Relay Mode plus direktes Zigbee-Binding, damit die
Wandschalter auch ohne HA und ohne Cluster funktionieren. Der Klemmplan ist identisch zur Variante
ohne Binding – die Entscheidung fällt erst in Phase 4 und ändert nichts an der Verdrahtung.

---

## 1. Ziel

Drei Zigbee-Deckenlampen in der Küche sollen dauerhaft mit Strom versorgt bleiben und ausschließlich per Zigbee geschaltet werden. Die vorhandenen Wandschalter bleiben physisch erhalten, wirken aber nur noch als Zigbee-Taster (Detach Relay Mode). Dafür stehen **zwei** Sonoff ZBMINIR2 zur Verfügung.

## 2. Ausgangslage (Ist-Zustand)

### Elektrik

- **Wechselschaltung** mit insgesamt drei Schaltstellen.
- **Schalter A** und **Schalter B** = klassische Wechselschaltung, schalten gemeinsam **Lampe 1 + Lampe 2**.
- **Schalter C** = einfacher Ausschalter, sitzt in einer Kombination zusammen mit einem der beiden Wechselschalter, schaltet **Lampe 3** allein.
- Alle drei Lampen hängen aktuell an einer geschalteten Phase → sie sind zeitweise komplett stromlos.

### Home Assistant / Zigbee2MQTT

| Objekt | Wert |
|---|---|
| `light.kuche_lampe1` | Lidl „Livarno Lux Ceiling Panel RGB+CCT", device_id `e2f253b5a5f5083cd24b2651c1433fc2`, IEEE `0x84ba20fffe77b08c` |
| `light.kuche_lampe2` | Lidl „Livarno Lux Ceiling Panel RGB+CCT", device_id `7ef29698cca1ff81c7274cc989ecf912`, IEEE `0x84b4dbfffef35ad1` |
| Lampe 3 | **noch nicht in Z2M/HA vorhanden** (Stand 2026-08-23, in Z2M verifiziert) |
| `light.0x9035eafffeb4570f` | EVN `511.000` – **Controller der LED-Leiste, NICHT Lampe 3.** Unbenannt, online, Router |
| Z2M Bridge | device_id `365f5b7e23c7dddf0c2a2d1b6791ee9c`, sw `2.7.2`, IEEE `0x54dce9fffee33068` |
| Area-Zuordnung Lampe 1+2 | ✅ `kuche` gesetzt am 2026-08-23 |
| Automationen/Skripte/Szenen mit Küchenlampen | **keine** (via `ha_search` verifiziert) |

Beide bekannten Lampen standen bei der Bestandsaufnahme auf `unknown` – Beleg dafür, dass sie hinter der Wechselschaltung gerade spannungslos waren.

Weitere Z2M-Geräte im Netz: 3 Bosch Heizkörperthermostate, 4 Thermometer, 1 LED-Leisten-Controller (EVN).
Gesamt 10 Geräte plus Bridge.

> **Falle:** Das unbenannte Gerät `0x9035eafffeb4570f` sieht auf den ersten Blick nach der fehlenden
> Lampe 3 aus – es ist `light.*`, unbenannt und online, während Lampe 1+2 offline sind. Es ist aber der
> LED-Leisten-Controller. Lampe 3 ist weiterhin nicht angelernt.

## 3. Zielarchitektur

**Kernidee:** Lampen an Dauerphase, ZBMINIR2 nur als Zigbee-Schalterinterface.

Der springende Punkt: Zigbee-Leuchtmittel dürfen nie netzseitig abgeschaltet werden – sonst verlieren sie Erreichbarkeit, Dimm-/Farbsteuerung und ihre Router-Funktion im Mesh.

### Warum zwei Module für drei Schaltstellen reichen

Zwei Wechselschalter in Reihe bilden ein **XOR**. Jede Betätigung an *einem der beiden* Schalter kippt den Kontaktzustand des S1/S2-Kreises. Mit `external_trigger_mode: edge` erzeugt jeder Zustandswechsel genau ein `action: toggle`.

- **Modul 1** deckt die komplette Wechselschaltung (Schalter A + B) → Lampe 1 + 2
- **Modul 2** deckt Schalter C → Lampe 3

### Modulkonfiguration (beide Module)

```
detach_relay_mode:     true
external_trigger_mode: edge
power_on_behavior:     previous
```

Schaltertyp bleibt auf Werkseinstellung **rocker switch** (Wippe) – passt zu Wechsel- und Ausschalter. Umschalten auf Taster wäre 3× kurz die Gerätetaste drücken, bis die grüne LED 3× schnell blinkt. **Nicht nötig.**

### Lampenkonfiguration

Alle drei Lidl-Panels: `power_on_behavior: previous`.

## 4. Klemmplan ZBMINIR2

Der ZBMINIR2 hat **sechs** Klemmen:

| Klemme | Sonoff-Bezeichnung |
|---|---|
| `N In` | Neutral (Input Terminal) |
| `N Out` | Neutral (Output Terminal) |
| `L In` | Live (Input Terminal) |
| `L Out` | Live (Output Terminal) – Relaisausgang |
| `S1` | External Switch (Input Terminal) |
| `S2` | External Switch (Input Terminal) |

### Beschaltung in unserem Fall (beide Module gleich)

| Klemme | anschließen an |
|---|---|
| `L In` | Dauerphase |
| `N In` | Neutralleiter |
| `L Out` | **frei lassen und isolieren** |
| `N Out` | frei lassen, oder als Klemmstelle für Lampen-N nutzen (intern mit `N In` durchverbunden) |
| `S1` / `S2` | Schalterkreis (siehe unten) |

Der Lampen-L geht per Wago **direkt auf die Dauerphase**, nicht auf `L Out`.

> **Warum nicht über `L Out` mit Detach-Mode?** Ginge technisch – das Relais bliebe dauerhaft geschlossen. Aber ein versehentlicher Aus-Befehl aus HA/App oder ein falsches `power_on_behavior` nach Stromausfall nähme die Panels vom Netz. Mit Lampen-L direkt auf Dauerphase ist das konstruktiv ausgeschlossen.

### Modul 1 – Wechselschaltung (Lampe 1 + 2)

Einbauort: die Dose, in der die Zuleitung ankommt.

- `S1` → Mittelkontakt Wechselschalter **A**
- `S2` → über eine dritte Ader vom Mittelkontakt Wechselschalter **B**
- die beiden korrespondierenden Adern zwischen A und B bleiben unverändert
- alte Schaltader der Lampen wird in der Deckendose auf Dauerphase geklemmt

### Modul 2 – Schalter C (Lampe 3)

Einbauort: Dose von Schalter C.

- `S1` / `S2` → über Schalter C gebrückt
- alte Schaltader Lampe 3 auf Dauerphase

### Sicherheitsregeln

- **`S1`/`S2` niemals an N oder PE.** Sonoff wörtlich: *„It is prohibited to connect S1 and S2 terminals to the neutral or ground wire in order to avoid damaging the equipment and causing danger."*
- An `S1`/`S2` kommt **ausschließlich** der Schalterkontakt, sonst nichts.
- Die Signaladern beim Verlegen wie 230-V-Adern behandeln – sie laufen im selben Kabel.
- Die S-Kreise der beiden Module dürfen **nicht** miteinander verbunden werden.
- Beide Module auf demselben Stromkreis / derselben Phase.
- Sonoff wörtlich: *„Please install and maintain the device by a professional electrician. To avoid an electric shock hazard, do not operate any connection or contact the terminal connector while the device is powered on!"*

**Ungeklärt:** Die offizielle Doku sagt nicht explizit, ob `S1`/`S2` potentialfrei oder L-bezogen sind. Eine Sekundärquelle behauptet potentialfrei; das ist **nicht** durch Sonoff bestätigt. Vor dem Verlegen des S1/S2-Kreises quer durch die vorhandene Wechselschaltungs-Verkabelung ggf. nachmessen.

## 5. Aufgabenliste

### Phase 0 – sofort machbar, ohne Elektrik

- [ ] Lampe 3 in Zigbee2MQTT anlernen (Schalter C ein, „Permit join" in Z2M). **Muss vor dem Umbau passieren**, sonst hängt sie danach auf Dauerstrom ohne Zugriff. **Modell noch unbekannt** – bestimmt die Pairing-Sequenz.
- [x] Lampe 1+2 benannt und Area `kuche` zugewiesen (2026-08-23). Lampe 3 offen.
- [ ] `power_on_behavior: previous` bei allen drei Panels setzen. **Blockiert:** Lampe 1+2 sind `unavailable`, solange die Wechselschaltung aus ist – Schreibzugriff scheitert mit `Delivery failed`. Ob die Lidl-Panels das überhaupt exponieren, ist offen; im Payload steht nur `color_power_on_behavior`.
- [ ] Lichtgruppe für Lampe 1+2 anlegen (HA-Light-Group-Helper oder Zigbee-Gruppe in Z2M; Z2M-Gruppe schaltet synchroner)

### Phase 1 – Bestandsaufnahme in den Dosen (Sicherung raus)

- [ ] Sicherung aus, Spannungsfreiheit zweipolig prüfen
- [ ] **Ist N in den Schalterdosen vorhanden?** Ohne Neutralleiter läuft der ZBMINIR2 nicht.
- [ ] **Adernzahl zwischen den beiden Wechselschalter-Dosen zählen** – nötig sind **3** freie Adern (2× korrespondierend + 1× Rückleitung zu `S2`)
- [ ] **Wo kommt die Zuleitung an?** Dose A, Dose B oder Deckendose → dort kommt Modul 1 rein
- [ ] Einbautiefe prüfen (ZBMINIR2 ca. 39 × 39 × 18 mm)
- [ ] Foto von jeder Dose vor dem Abklemmen

### Phase 2 – Material

- [ ] Wago 221 (3- und 5-polig)
- [ ] Isolierkappe/Wago als Endverschluss für `L Out`
- [ ] ggf. tiefe Gerätedosen
- [ ] zweipoliger Spannungsprüfer

### Phase 3 – Umbau (Sicherung aus)

- [ ] Lampen in der Deckendose auf Dauerphase legen
- [ ] Modul 1 einbauen (Klemmplan oben)
- [ ] Modul 2 einbauen (Klemmplan oben)
- [ ] Kontrolle: `S1`/`S2` nirgends an N/PE, S-Kreise nicht verbunden
- [ ] Sicherung rein

### Phase 4 – Module konfigurieren

- [ ] Beide Module in Z2M anlernen, benennen (Vorschlag: `kueche_schalter_wechsel`, `kueche_schalter_lampe3`)
- [ ] `detach_relay_mode`, `external_trigger_mode`, `power_on_behavior` setzen
- [ ] Action-Events verifizieren: Wippe betätigen, in Z2M-Logs bzw. auf `zigbee2mqtt/{friendly_name}/action` prüfen, ob `toggle` kommt. Bei der Wechselschaltung muss **jede** Betätigung an **beiden** Schaltern ein Event auslösen.

### Phase 5 – Automationen in HA

- [ ] Automation 1: `action: toggle` Modul 1 → `light.toggle` auf Küchen-Lichtgruppe
- [ ] Automation 2: `action: toggle` Modul 2 → `light.toggle` auf Lampe 3

> Erst schreiben, **nachdem** die Module gepairt sind – das exakte Trigger-Format hängt an den Entities, die Z2M tatsächlich anlegt. Nicht raten.
> Vorgehen: `home-assistant-best-practices`-Skill konsultieren, dann via `ha_config_set_automation` anlegen (kein handgeschriebenes YAML), `entity_id` statt `device_id` verwenden.

### Phase 6 – Test

- [ ] Beide Wechselschalter einzeln in jeder Stellung → Lampe 1+2 toggeln
- [ ] Schalter C → Lampe 3 toggelt
- [ ] Sicherung aus/ein → alle Lampen im vorherigen Zustand zurück, Module wieder online
- [ ] Dimmen/Farbe aus HA funktioniert auch bei „ausgeschaltetem" Wandschalter

## 6. Offene Punkte

| # | Frage | Blockiert |
|---|---|---|
| 1 | Ist ein Neutralleiter in den Schalterdosen? | gesamten Umbau |
| 2 | Wie viele Adern liegen zwischen den beiden Wechselschalter-Dosen? | Modul-1-Konzept (braucht 3) |
| 3 | Wo kommt die Zuleitung an – Dose A, Dose B oder Decke? | Einbauort Modul 1 |
| 4 | Reicht die Einbautiefe der Dosen? | Montage |
| 5 | Sind `S1`/`S2` potentialfrei? Von Sonoff nicht bestätigt. | Leitungsführung S-Kreis |
| 6 | Kann der ZBMINIR2 direktes Zigbee-Binding auf eine Lampengruppe? | Fallback ohne HA/Z2M |

Punkte 1–4 muss der Nutzer vor Ort prüfen. Danach lässt sich der exakte Klemmplan pro Dose erstellen.

## 7. Bekannter Trade-off

Fällt HA oder Z2M aus, tun die Wandschalter nichts mehr. Das ist der Preis des Detach Relay Mode. Ob direktes Zigbee-Binding vom ZBMINIR2 auf die Lampengruppe als serverloser Fallback möglich ist, ist offen (Punkt 6) – prüfbar erst, wenn die Module gepairt sind.

## 8. Referenzen

- Offizielle ZBMINIR2-Doku: https://help.sonoff.tech/docs/zbminir2
- Z2M-Exposes ZBMINIR2: `state`, `power_on_behavior`, `network_indicator`, `turbo_mode`, `delayed_power_on_state`, `delayed_power_on_time` (0.5–3599.5 s), `detach_relay_mode` (bool), `external_trigger_mode` (`edge` | `pulse` | `following(off)` | `following(on)`), `inching_control_set`, `action` (`toggle`), Geräteoption `state_action` (bool, default `false`)
- MQTT-Topic-Konvention: `zigbee2mqtt/{friendly_name}/action`
