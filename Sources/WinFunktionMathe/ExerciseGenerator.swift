import Foundation

struct Exercise {
    let question: String
    let answer: Double
    let hint: String
    let tolerance: Double
}

/// Erzeugt zufällige Übungsaufgaben zu jedem Lerngebiet.
enum ExerciseGenerator {

    private static var rng = SystemRandomNumberGenerator()

    private static func int(_ min: Int, _ max: Int) -> Int {
        Int.random(in: min...max, using: &rng)
    }

    static func make(topicId: Int) -> Exercise {
        switch topicId {
        case 0: return arithmetic()
        case 1: return algebra()
        case 2: return geometry()
        case 3: return analysis()
        case 4: return stochastics()
        case 5: return linearAlgebra()
        default: return physics()
        }
    }

    // MARK: Arithmetik

    private static func arithmetic() -> Exercise {
        switch int(0, 2) {
        case 0:
            let a = int(12, 99), b = int(3, 19), c = int(2, 9)
            return Exercise(
                question: "Berechne: \(a) + \(b) · \(c)",
                answer: Double(a + b * c),
                hint: "Punkt vor Strich: erst \(b) · \(c), dann addieren.",
                tolerance: 0.01
            )
        case 1:
            let g = int(40, 400), p = [5, 10, 15, 20, 25, 30, 40][int(0, 6)]
            return Exercise(
                question: "Berechne \(p) % von \(g).",
                answer: Double(g * p) / 100.0,
                hint: "W = G · p / 100",
                tolerance: 0.01
            )
        default:
            let n = int(2, 5)
            let b = int(2, 9)
            return Exercise(
                question: "Berechne: \(b)^\(n)",
                answer: pow(Double(b), Double(n)),
                hint: "Potenz: \(b) mit sich selbst \(n)-mal multipliziert.",
                tolerance: 0.01
            )
        }
    }

    // MARK: Algebra

    private static func algebra() -> Exercise {
        switch int(0, 1) {
        case 0:
            let a = int(2, 9), x = int(2, 15), b = int(1, 30)
            let c = a * x + b
            return Exercise(
                question: "Löse: \(a)x + \(b) = \(c)  ( Gib den Wert von x ein )",
                answer: Double(x),
                hint: "Erst \(b) abziehen, dann durch \(a) teilen.",
                tolerance: 0.01
            )
        default:
            // x² + px + q = 0 mit ganzzahliger Lösung x1 und gefordertem x2...
            let r1 = [-4, -3, -2, -1, 1, 2, 3, 4][int(0, 7)]
            let p = -r1 * 2 // doppelte Nullstelle
            let x1 = r1
            let middleTerm = p >= 0 ? "+ \(p)" : "− \(-p)"
            let constantTerm = r1 * r1
            return Exercise(
                question: "Löse x² \(middleTerm)x + \(constantTerm) = 0 (doppelte Nullstelle). Gib x an.",
                answer: Double(x1),
                hint: "doppelte Nullstelle bei x, Satz von Vieta: q = x²",
                tolerance: 0.01
            )
        }
    }

    // MARK: Geometrie

    private static func geometry() -> Exercise {
        switch int(0, 1) {
        case 0:
            let triples: [(Int, Int, Int)] = [(3, 4, 5), (6, 8, 10), (5, 12, 13), (9, 12, 15), (8, 15, 17), (7, 24, 25)]
            let t = triples[int(0, triples.count - 1)]
            return Exercise(
                question: "Ein rechtwinkliges Dreieck hat die Katheten a = \(t.0) und b = \(t.1). Wie lang ist die Hypotenuse c?",
                answer: Double(t.2),
                hint: "Satz des Pythagoras: c = √(a² + b²)",
                tolerance: 0.01
            )
        default:
            let r = int(2, 12)
            return Exercise(
                question: "Berechne den Flächeninhalt eines Kreises mit Radius r = \(r) (auf 2 Nachkommastellen genau, π ≈ 3,14159).",
                answer: Double.pi * Double(r) * Double(r),
                hint: "A = π r²",
                tolerance: 0.05
            )
        }
    }

    // MARK: Analysis

    private static func analysis() -> Exercise {
        switch int(0, 1) {
        case 0:
            let n = int(2, 6), a = int(2, 9), x0 = int(1, 4)
            // f(x) = a x^n, gesucht f'(x0)
            let answer = Double(a * n) * pow(Double(x0), Double(n - 1))
            return Exercise(
                question: "f(x) = \(a)x^\(n). Berechne f '(\(x0)).",
                answer: answer,
                hint: "Potenzregel: f'(x) = \(a · n) x^\(n - 1), dann x = \(x0) einsetzen.",
                tolerance: 0.01
            )
        default:
            let k = int(1, 5)
            // ∫₀^k 3x² dx = k³
            return Exercise(
                question: "Berechne das Integral ∫₀^\(k) 3x² dx.",
                answer: Double(k * k * k),
                tolerance: 0.01,
                hint: "Stammfunktion F(x) = x³, dann F(\(k)) − F(0)."
            )
        }
    }

    // MARK: Stochastik

    private static func stochastics() -> Exercise {
        switch int(0, 1) {
        case 0:
            // Zwei Würfel, Summe = 7 → 6/36
            return Exercise(
                question: "Zwei faire Würfel werden geworfen. Wie groß ist die Wahrscheinlichkeit (in Prozent, 2 Nachkommastellen) für die Augensumme 7?",
                answer: 100.0 * 6.0 / 36.0,
                hint: "Günstige Paare: (1,6),(2,5),(3,4),(4,3),(5,2),(6,1) – von 36 gleich wahrscheinlichen Ergebnissen.",
                tolerance: 0.05
            )
        default:
            let n = int(2, 8), k = int(1, n)
            return Exercise(
                question: "Berechne C(\(n), \(k)) – Anzahl der Auswahlen von \(k) aus \(n) ohne Reihenfolge. (Numerischer Wert)",
                answer: Double(binomial(n, k)),
                hint: "C(n,k) = n! / (k!·(n−k)!)",
                tolerance: 0.01
            )
        }
    }

    // MARK: Lineare Algebra

    private static func linearAlgebra() -> Exercise {
        let a1 = int(-6, 6), a2 = int(-6, 6), a3 = int(-6, 6)
        return Exercise(
            question: "Gegeben ist der Vektor a = (\(a1) | \(a2) | \(a3)). Berechne seinen Betrag |a| (2 Nachkommastellen).",
            answer: sqrt(Double(a1 * a1 + a2 * a2 + a3 * a3)),
            hint: "|a| = √(a₁² + a₂² + a₃²)",
            tolerance: 0.01
        )
    }

    // MARK: Physik

    private static func physics() -> Exercise {
        switch int(0, 3) {
        case 0:
            let m = int(2, 20), a = int(2, 8)
            return Exercise(
                question: "Ein Körper mit m = \(m) kg wird mit a = \(a) m/s² beschleunigt. Welche Kraft F (in Newton) wirkt auf ihn?",
                answer: Double(m * a),
                hint: "F = m · a",
                tolerance: 0.01
            )
        case 1:
            let v = int(5, 30), t = int(2, 12)
            return Exercise(
                question: "Ein Fahrzeug fährt \(t) s gleichförmig mit v = \(v) m/s. Welchen Weg s (in Metern) legt es zurück?",
                answer: Double(v * t),
                hint: "s = v · t",
                tolerance: 0.01
            )
        case 2:
            let u = int(6, 24), r = int(2, 12)
            let i = Double(u) / Double(r)
            return Exercise(
                question: "An einem Widerstand R = \(r) Ω liegt die Spannung U = \(u) V. Wie groß ist die Stromstärke I (in Ampere, 2 Nachkommastellen)?",
                answer: i,
                hint: "Ohmsches Gesetz: I = U / R",
                tolerance: 0.05
            )
        default:
            let f = int(10, 80), s = int(2, 15)
            let v = sqrt(2.0 * Double(f) * Double(s))
            return Exercise(
                question: "Ein Körper der Masse 1 kg wird mit F = \(f) N über \(s) m beschleunigt (W = F·s geht in Bewegungsenergie). Wie groß ist seine Endgeschwindigkeit v (m/s, 2 Nachkommastellen)?",
                answer: v,
                hint: "W = ½ m v² ⇒ v = √(2W/m)",
                tolerance: 0.05
            )
        }
    }

    private static func binomial(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        var result = 1
        for i in 0..<min(k, n - k) {
            result = result * (n - i) / (i + 1)
        }
        return result
    }
}

/// Hilfsfunktionen für die Darstellung deutscher Zahlen.
enum NumberFormatting {
    static func german(_ value: Double, fractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "de_DE")
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
