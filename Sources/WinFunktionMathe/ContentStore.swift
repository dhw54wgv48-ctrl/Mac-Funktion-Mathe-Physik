import Foundation

struct Chapter {
    let title: String
    let body: [String]
}

struct Topic {
    let id: Int
    let title: String
    let symbol: String
    let intro: String
    let chapters: [Chapter]

    /// Zusätzliches Transkript für Sprachausgabe (VoiceOver).
    var accessibilityDescription: String {
        "Lerngebiet \(title): \(intro)"
    }
}

struct Formula {
    let topic: String
    let name: String
    let formula: String
    let note: String
}

/// Lerninhalte der App WinFunktion Mathe (sinngemäß die Struktur von
/// Arithmetik/Algebra, Geometrie, Analysis, Stochastik und Lineare Algebra).
enum ContentStore {

    static let topics: [Topic] = [
        Topic(
            id: 0,
            title: "Arithmetik",
            symbol: "🧮",
            intro: "Grundoperationen, Brüche, Potenzen und Prozentrechnung.",
            chapters: [
                Chapter(title: "Grundrechenarten", body: [
                    "Punkt vor Strich: Multiplikation und Division binden stärker als Addition und Subtraktion.",
                    "Klammern stehen immer an oberster Stelle: (2 + 3) · 4 = 20, aber 2 + 3 · 4 = 14.",
                    "Beispiel: 12 + 5 · (8 − 3) = 12 + 25 = 37."
                ]),
                Chapter(title: "Bruchrechnung", body: [
                    "Addition/Subtraktion: Brüche werden auf einen gemeinsamen Nenner gebracht: a/b + c/d = (ad + cb)/(bd).",
                    "Multiplikation: Zähler mal Zähler, Nenner mal Nenner: a/b · c/d = ac/(bd).",
                    "Division: Multiplikation mit dem Kehrwert: (a/b) ÷ (c/d) = a/b · d/c.",
                    "Beispiel: 3/4 + 1/6 = 9/12 + 2/12 = 11/12."
                ]),
                Chapter(title: "Prozentrechnung", body: [
                    "Grundformel: W = G · p / 100 (W = Prozentwert, G = Grundwert, p = Prozentsatz).",
                    "Wachstumsfaktor bei prozentualer Änderung: q = 1 + p/100 (z. B. + 20 % ⇒ q = 1,2).",
                    "Beispiel: 15 % von 240 € = 240 · 15 / 100 = 36 €."
                ]),
                Chapter(title: "Potenzen und Wurzeln", body: [
                    "Potenzgesetze: aᵐ · aⁿ = aᵐ⁺ⁿ, aᵐ / aⁿ = aᵐ⁻ⁿ, (aᵐ)ⁿ = aᵐ·ⁿ.",
                    "a⁰ = 1 (für a ≠ 0), a⁻ⁿ = 1/aⁿ.",
                    "n-te Wurzel: a^(1/n) ist die Zahl, deren n-te Potenz a ergibt: √9 = 3."
                ])
            ]
        ),
        Topic(
            id: 1,
            title: "Algebra",
            symbol: "✏️",
            intro: "Gleichungen, Ungleichungen und Funktionen.",
            chapters: [
                Chapter(title: "Lineare Gleichungen", body: [
                    "Äquivalenzumformungen: Addition, Subtraktion, Multiplikation und Division (mit Zahlen ≠ 0) auf beiden Seiten.",
                    "ax + b = c ⇒ x = (c − b)/a (für a ≠ 0).",
                    "Beispiel: 3x + 5 = 20 ⇒ 3x = 15 ⇒ x = 5."
                ]),
                Chapter(title: "Quadratische Gleichungen", body: [
                    "p-q-Formel für x² + px + q = 0: x = −p/2 ± √(p²/4 − q).",
                    "Mitternachtsformel für ax² + bx + c = 0: x = (−b ± √(b² − 4ac)) / (2a).",
                    "Satz von Vieta: x₁ + x₂ = −p und x₁ · x₂ = q.",
                    "Diskriminante D = p²/4 − q: D > 0 zwei Lösungen, D = 0 eine Lösung, D < 0 keine reelle Lösung."
                ]),
                Chapter(title: "Ungleichungen", body: [
                    "Bei Multiplikation oder Division mit einer negativen Zahl dreht sich das Ungleichheitszeichen um!",
                    "Beispiel: −2x < 6 ⇒ x > −3.",
                    "Lösungen werden als Intervalle notiert, z. B. x ∈ (−3, ∞)."
                ]),
                Chapter(title: "Lineare Funktionen", body: [
                    "f(x) = mx + b: m ist die Steigung, b der y-Achsenabschnitt.",
                    "Steigung aus zwei Punkten: m = (y₂ − y₁)/(x₂ − x₁).",
                    "Zwei Geraden sind genau dann parallel, wenn ihre Steigungen übereinstimmen."
                ])
            ]
        ),
        Topic(
            id: 2,
            title: "Geometrie",
            symbol: "📐",
            intro: "Flächen, Körper, Sätze und Trigonometrie.",
            chapters: [
                Chapter(title: "Satz des Pythagoras", body: [
                    "Im rechtwinkligen Dreieck mit Hypotenuse c und Katheten a, b gilt: a² + b² = c².",
                    "Kathetensatz: a² = c · p und b² = c · q (p, q Hypotenusenabschnitte).",
                    "Höhe: h² = p · q."
                ]),
                Chapter(title: "Flächen", body: [
                    "Quadrat: A = a². Rechteck: A = a · b. Dreieck: A = ½ · g · h.",
                    "Kreis: A = π r², Umfang U = 2 π r.",
                    "Trapez: A = (a + c)/2 · h."
                ]),
                Chapter(title: "Körper", body: [
                    "Würfel: V = a³. Quader: V = a · b · c.",
                    "Zylinder: V = π r² h. Kegel: V = ⅓ π r² h. Kugel: V = (4/3) π r³.",
                    "Oberfläche Kugel: O = 4 π r²."
                ]),
                Chapter(title: "Trigonometrie", body: [
                    "sin α = Gegenkathete / Hypotenuse, cos α = Ankathete / Hypotenuse, tan α = Gegenkathete / Ankathete.",
                    "sin²α + cos²α = 1.",
                    "Sinussatz: a/sin α = b/sin β = c/sin γ.",
                    "Vorsicht: Winkel im Taschenrechner dieser App sind im Bogenmaß (Rad)."
                ])
            ]
        ),
        Topic(
            id: 3,
            title: "Analysis",
            symbol: "📉",
            intro: "Ableitungen, Grenzwerte und Integrale.",
            chapters: [
                Chapter(title: "Ableitungsregeln", body: [
                    "Potenzregel: f(x) = xⁿ ⇒ f'(x) = n · xⁿ⁻¹.",
                    "Produktregel: (u · v)' = u' · v + u · v'.",
                    "Quotientenregel: (u/v)' = (u'v − uv') / v².",
                    "Kettenregel: (u(v(x)))' = u'(v(x)) · v'(x)."
                ]),
                Chapter(title: "Wichtige Ableitungen", body: [
                    "sin x → cos x, cos x → −sin x, eˣ → eˣ, ln x → 1/x.",
                    "f(x) = x² → f'(x) = 2x, f(x) = 1/x → f'(x) = −1/x²."
                ]),
                Chapter(title: "Kurvendiskussion", body: [
                    "Notwendige Bedingung für Extremstellen: f'(x₀) = 0.",
                    "Hinreichende Bedingung: Vorzeichenwechsel von f' (oder f''(x₀) > 0 Minimum, f''(x₀) < 0 Maximum).",
                    "Wendestelle: Vorzeichenwechsel von f''."
                ]),
                Chapter(title: "Integralrechnung", body: [
                    "Stammfunktion: F'(x) = f(x). Beispiel: f(x) = x² ⇒ F(x) = x³/3.",
                    "Hauptsatz der Differential- und Integralrechnung: ∫ₐᵇ f(x) dx = F(b) − F(a).",
                    "Fläche zwischen Graph und x-Achse: Beispiel ∫₀² x² dx = 8/3."
                ])
            ]
        ),
        Topic(
            id: 4,
            title: "Stochastik",
            symbol: "🎲",
            intro: "Wahrscheinlichkeitsrechnung und Statistik.",
            chapters: [
                Chapter(title: "Laplace-Wahrscheinlichkeit", body: [
                    "P(E) = |E| / |Ω| = günstige Fälle / mögliche Fälle.",
                    "Beispiel: Würfelwurf, gerade Zahl: 3/6 = 0,5.",
                    "Gegenereignis: P(Ẽ) = 1 − P(E)."
                ]),
                Chapter(title: "Kombinatorik", body: [
                    "Binomialkoeffizient: C(n, k) = n! / (k! · (n−k)!) — Anzahl der Auswahlen von k aus n ohne Reihenfolge.",
                    "Permutationen von n Elementen: n!.",
                    "Mit Zurücklegen und Reihenfolge: nᵏ."
                ]),
                Chapter(title: "Binomialverteilung", body: [
                    "P(X = k) = C(n, k) · pᵏ · (1−p)ⁿ⁻ᵏ.",
                    "Erwartungswert E(X) = n · p, Varianz V(X) = n · p · (1−p).",
                    "Beispiel: 10 Würfe, Wahrscheinlichkeit genau 6 Sechser mit fairem Würfel: C(10,6) · (1/6)⁶ · (5/6)⁴ ≈ 0,1936."
                ]),
                Chapter(title: "Beschreibende Statistik", body: [
                    "Mittelwert: x̄ = (Σ xᵢ)/n.",
                    "Median: mittlerer Wert der sortierten Daten.",
                    "Standardabweichung: σ = √(Σ(xᵢ − x̄)²/n)."
                ])
            ]
        ),
        Topic(
            id: 5,
            title: "Lineare Algebra",
            symbol: "➗",
            intro: "Vektoren, Matrizen und Gleichungssysteme.",
            chapters: [
                Chapter(title: "Vektoren", body: [
                    "Ein Vektor a = (a₁, a₂, a₃) beschreibt Pfeilrichtung und Länge.",
                    "Länge (Betrag): |a| = √(a₁² + a₂² + a₃²).",
                    "Skalarprodukt: a · b = a₁b₁ + a₂b₂ + a₃b₃; a ⊥ b ⇔ a · b = 0."
                ]),
                Chapter(title: "Matrizen", body: [
                    "Matrizenmultiplikation: (A·B)ᵢⱼ = Zeile i von A mal Spalte j von B.",
                    "Eigenschaften: A·B ≠ B·A im Allgemeinen; 1 ist das neutrale Element über der Einheitsmatrix.",
                    "Determinante 2×2: det A = ad − bc."
                ]),
        ),
        Topic(
            id: 6,
            title: "Physik",
            symbol: "🧲",
            intro: "Mechanik, Elektrizitätslehre, Optik und Wärmelehre – die Physik-Kapitel der Lernsoftware.",
            chapters: [
                Chapter(title: "Mechanik", body: [
                    "Geschwindigkeit (gleichförmig): v = s / t – Weg pro Zeit, Einheit m/s.",
                    "Beschleunigung: a = Δv / Δt; gleichförmig beschleunigte Bewegung: s = ½ a t², v = a t.",
                    "Newtonsche Grundgleichung: F = m · a (Kraft = Masse mal Beschleunigung, Einheit Newton).",
                    "Freier Fall: v = g · t mit g ≈ 9,81 m/s²."
                ]),
                Chapter(title: "Arbeit, Energie, Leistung", body: [
                    "Arbeit: W = F · s (Kraft mal Weg, Einheit Joule).",
                    "Kinetische Energie: Ekin = ½ m v². Potentielle Energie: Epot = m g h.",
                    "Leistung: P = W / t (Arbeit pro Zeit, Einheit Watt).",
                    "Energieerhaltungssatz: In einem abgeschlossenen System bleibt die Gesamtenergie erhalten."
                ]),
                Chapter(title: "Elektrizitätslehre", body: [
                    "Ohmsches Gesetz: U = R · I (Spannung = Widerstand mal Stromstärke).",
                    "Leistung: P = U · I; elektrische Arbeit: W = P · t.",
                    "Reihenschaltung: R_ges = R₁ + R₂ + …; Parallelschaltung: 1/R_ges = 1/R₁ + 1/R₂.",
                    "Beispiel: Bei U = 12 V und R = 4 Ω fließt I = 3 A."
                ]),
                Chapter(title: "Optik und Wärmelehre", body: [
                    "Snelliussches Brechungsgesetz: n₁ sin α = n₂ sin β.",
                    "Linsen: Linsengleichung 1/f = 1/a + 1/b (a Gegenstandsweite, b Bildweite, f Brennweite).",
                    "Wärmemenge: Q = m · c · ΔT (c spezifische Wärmekapazität, z. B. Wasser 4,19 kJ/(kg·K)).",
                    "Wirkungsgrad: η = Nutzenenergie / zugeführte Energie (immer < 1 bei realen Maschinen)."
                ])
            ]
        )
    ]

    static let formulas: [Formula] = [
        Formula(topic: "Arithmetik", name: "Prozentwert", formula: "W = G · p / 100", note: "p Prozentsatz, G Grundwert"),
        Formula(topic: "Arithmetik", name: "Zinseszins", formula: "Kₙ = K₀ · (1 + p/100)ⁿ", note: "Kapital nach n Jahren"),
        Formula(topic: "Arithmetik", name: "Binomische Formeln", formula: "(a+b)² = a²+2ab+b², (a−b)² = a²−2ab+b², (a+b)(a−b) = a²−b²", note: "Grundlage vieler Umformungen"),
        Formula(topic: "Algebra", name: "p-q-Formel", formula: "x² + px + q = 0 ⇒ x = −p/2 ± √(p²/4 − q)", note: "Quadratische Gleichung"),
        Formula(topic: "Algebra", name: "Mitternachtsformel", formula: "ax² + bx + c = 0 ⇒ x = (−b ± √(b² − 4ac)) / (2a)", note: "Allgemeine quadratische Gleichung"),
        Formula(topic: "Algebra", name: "Satz von Vieta", formula: "x₁ + x₂ = −p, x₁ · x₂ = q", note: "Zusammenhang zwischen Lösungen und Koeffizienten"),
        Formula(topic: "Algebra", name: "Geradengleichung", formula: "f(x) = m·x + b", note: "m Steigung, b y-Achsenabschnitt"),
        Formula(topic: "Geometrie", name: "Satz des Pythagoras", formula: "a² + b² = c²", note: "Rechtwinkliges Dreieck, c Hypotenuse"),
        Formula(topic: "Geometrie", name: "Kreisfläche", formula: "A = π r²", note: "Umfang U = 2 π r"),
        Formula(topic: "Geometrie", name: "Kreis-Zylinder", formula: "V = π r² h", note: "Kegel: V = ⅓ π r² h"),
        Formula(topic: "Geometrie", name: "Kugel", formula: "V = (4/3) π r³, O = 4 π r²", note: "Volumen und Oberfläche"),
        Formula(topic: "Geometrie", name: "Dreiecksfläche", formula: "A = ½ · g · h", note: "g Grundseite, h Höhe"),
        Formula(topic: "Geometrie", name: "Sinussatz", formula: "a / sin α = b / sin β = c / sin γ", note: "Beliebiges Dreieck"),
        Formula(topic: "Analysis", name: "Potenzregel", formula: "f(x) = xⁿ ⇒ f'(x) = n xⁿ⁻¹", note: "Basisregel der Differentiation"),
        Formula(topic: "Analysis", name: "Produktregel", formula: "(u v)' = u' v + u v'", note: "u, v Funktionen von x"),
        Formula(topic: "Analysis", name: "Kettenregel", formula: "(u(v))' = u'(v) · v'", note: "Verkettete Funktionen"),
        Formula(topic: "Analysis", name: "Hauptsatz", formula: "∫ₐᵇ f(x) dx = F(b) − F(a)", note: "F Stammfunktion von f"),
        Formula(topic: "Analysis", name: "Wichtige Stammfunktionen", formula: "xⁿ → xⁿ⁺¹/(n+1), 1/x → ln|x|, eˣ → eˣ", note: "Für n ≠ −1"),
        Formula(topic: "Stochastik", name: "Laplace", formula: "P(E) = |E| / |Ω|", note: "Günstige durch mögliche Fälle"),
        Formula(topic: "Stochastik", name: "Binomialkoeffizient", formula: "C(n,k) = n! / (k! (n−k)!)", note: "Auswahl ohne Reihenfolge"),
        Formula(topic: "Stochastik", name: "Binomialverteilung", formula: "P(X = k) = C(n,k) pᵏ (1−p)ⁿ⁻ᵏ", note: "Erwartungswert n p"),
        Formula(topic: "Stochastik", name: "Standardabweichung", formula: "σ = √(Σ(xᵢ − x̄)² / n)", note: "Streuung um den Mittelwert x̄"),
        Formula(topic: "Lineare Algebra", name: "Vektorlänge", formula: "|a| = √(a₁² + a₂² + a₃²)", note: "Betrag eines Vektors"),
        Formula(topic: "Lineare Algebra", name: "Skalarprodukt", formula: "a · b = a₁b₁ + a₂b₂ + a₃b₃", note: "a ⊥ b ⇔ a · b = 0"),
        Formula(topic: "Physik", name: "Grundgleichung der Mechanik", formula: "F = m · a", note: "Kraft in Newton, Masse in kg"),
        Formula(topic: "Physik", name: "Geschwindigkeit / gleichf. Beschl. Bewegung", formula: "v = s/t, s = ½ a t²", note: "v in m/s, s in m"),
        Formula(topic: "Physik", name: "Kinetische / potentielle Energie", formula: "Ekin = ½ m v², Epot = m g h", note: "g ≈ 9,81 m/s²"),
        Formula(topic: "Physik", name: "Arbeit und Leistung", formula: "W = F s, P = W/t", note: "W in Joule, P in Watt"),
        Formula(topic: "Physik", name: "Ohmsches Gesetz", formula: "U = R · I", note: "P = U · I elektrische Leistung"),
        Formula(topic: "Physik", name: "Wärmemenge", formula: "Q = m c ΔT", note: "Wasser: c = 4,19 kJ/(kg·K)"),
        Formula(topic: "Physik", name: "Brechungsgesetz", formula: "n₁ sin α = n₂ sin β", note: "Snelliussches Gesetz"),
        Formula(topic: "Physik", name: "Linsengleichung", formula: "1/f = 1/a + 1/b", note: "f Brennweite, b Bildweite")
    ]
}
