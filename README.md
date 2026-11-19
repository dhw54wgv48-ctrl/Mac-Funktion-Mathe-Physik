# Mac Funktion Mathe-Physik (macOS)

Eine native Mac-App (Swift + AppKit), inspiriert von den klassischen Lernsoftwaren **WinFunktion Mathematik / Physik**. Sie funktioniert ohne externe Abhängigkeiten – nur Swift Package Manager und macOS 11+ werden benötigt.

## Funktionen

| Bereich | Beschreibung |
| --- | --- |
| 🧮 **Lerngebiete** | Arithmetik, Algebra, Geometrie, Analysis, Stochastik, Lineare Algebra **und Physik** (Mechanik, Elektrizität, Optik, Wärme) mit Kapiteln, Erklärungen und Beispielen |
| 🎓 **Übungen** | Zufällig generierte Aufgaben je Lerngebiet mit Antwortprüfung, Tipps und Punktestand |
| 📚 **Formelsammlung** | Nach Themengebieten gruppierte Formeln (p-q-Formel, Satz des Pythagoras, Ableitungsregeln, Binomialverteilung u. v. m.) |
| 🔬 **Physik-Simulationen** | **Schräge Rampe** (Kräftezerlegung mit Pfeilen, Reibung, Beschleunigung), **Optikbank** (Sammellinse mit Strahlengang nach Linsengleichung) und **Reihenschaltung** (U, R1, R2 → I, Teilspannungen, Leistungen) – jeweils mit Reglern |
| 📈 **Funktionsplotter** | Zeichnet beliebige Terme f(x) mit Achsen, Gitter und Zoom (z. B. `x^2 - 3`, `sin(x)`, `exp(x)/x`) |
| 🧮 **Taschenrechner** | Wissenschaftlicher Ausdrucks-Parser: `+ - * / ^`, Klammern, `sin cos tan sqrt ln log exp abs`, `pi`, `e` – mit Verlauf |

## Bauen und Starten

Voraussetzung: macOS 11+ mit installiertem Swift (enthalten in Xcode Command Line Tools).

```bash
./build.sh
open "build/Mac Funktion Mathe-Physik.app"
```

Alternativ ohne Bundle:

```bash
swift run
```

## Eingabehinweise Taschenrechner/Plotter

- Dezimaltrennzeichen: `.` **oder** `,` (Komma wird automatisch in Punkt umgewandelt)
- Winkel­funktionen rechnen im **Bogenmaß** (Rad), z. B. `sin(pi/2) = 1`
- Potenzen mit `^` (rechtsassoziativ): `2^3^2 = 2^9 = 512`

## Projektstruktur

```
Sources/WinFunktionMathe/
├── main.swift                  App-Einstiegspunkt
├── AppDelegate.swift           Fenster- und App-Lebenszyklus
├── MainViewController.swift    Sidebar + Inhaltsbereich
├── PhysicsModel.swift           Rechenmodelle der Simulationen
├── PhysicsSimulations.swift     Rampe, Optikbank, Reihenschaltung
├── TopicDetailViews.swift      Lerngebiete + Formelsammlung
├── ExerciseViewController.swift Übungsmodus
├── PlotAndCalculatorViews.swift Funktionsplotter + Taschenrechner
├── ExerciseGenerator.swift     Zufällige Übungsaufgaben
├── ContentStore.swift          Lerninhalte und Formeln
└── MathEngine.swift            Ausdrucks-Parser und -Auswerter
```

## Bedienung

Links in der Seitenleiste wird zwischen Lerngebieten und Werkzeugen gewechselt. Im Übungsmodus wird ein Lerngebiet ausgewählt, die Antwort eingegeben und mit **Antwort prüfen** bestätigt; **Tipp anzeigen** hilft bei Verständnisproblemen, und der Punktestand zählt richtige Lösungen mit.

## Lizenz

MIT – freie Nutzung und Anpassung. „WinFunktion“ ist ein Begriff der ursprünglichen Windows-Lernsoftware; dieses Projekt ist eine eigenständige, unabhängige Neuimplementation für macOS und deckt Mathematik **und** Physik ab.
