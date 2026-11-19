import Foundation

/// Physikalische Modelle für die Simulationen – ohne AppKit, direkt testbar.

enum PhysicsConstants {
    static let gravity = 9.81 // m/s²
}

// MARK: Schräge Rampe

struct RampModel {
    var angleDeg: Double // Neigungswinkel
    var mass: Double     // kg
    var friction: Double // Reibungskoeffizient µ

    var angleRad: Double { angleDeg * .pi / 180 }

    var gravityForce: Double { mass * PhysicsConstants.gravity }
    var slopeForce: Double { mass * PhysicsConstants.gravity * sin(angleRad) }
    var normalForce: Double { mass * PhysicsConstants.gravity * cos(angleRad) }
    var frictionForce: Double { friction * normalForce }

    var isMoving: Bool { slopeForce > frictionForce && friction < 1 }

    /// Beschleunigung entlang der Rampe (m/s²), 0 wenn der Block haftet.
    var acceleration: Double {
        let a = PhysicsConstants.gravity * (sin(angleRad) - friction * cos(angleRad))
        return a > 0 ? a : 0
    }

    /// Geschwindigkeit nach t Sekunden Rutschen (m/s).
    func velocity(after seconds: Double) -> Double {
        acceleration * seconds
    }
}

// MARK: Optikbank (Sammellinse)

struct LensModel {
    var focalLength: Double   // cm, positiv (Sammellinse)
    var objectDistance: Double // cm
    var objectHeight: Double   // cm (Gegenstandspfeil)

    var isValid: Bool { abs(objectDistance - focalLength) > 0.01 }

    /// Bildweite b nach Linsengleichung 1/f = 1/a + 1/b (cm); negativ = virtuelles Bild.
    var imageDistance: Double {
        guard isValid else { return .infinity }
        return 1.0 / (1.0 / focalLength - 1.0 / objectDistance)
    }

    var isRealImage: Bool { isValid && imageDistance > 0 }

    var magnification: Double {
        guard isValid, imageDistance.isFinite else { return 0 }
        return -imageDistance / objectDistance
    }

    var imageHeight: Double { magnification * objectHeight }
}

// MARK: Reihenschaltung

struct CircuitModel {
    var voltage: Double // V
    var r1: Double      // Ω
    var r2: Double      // Ω

    var totalResistance: Double { r1 + r2 }
    var current: Double { voltage / totalResistance }
    var voltageR1: Double { current * r1 }
    var voltageR2: Double { current * r2 }
    var powerTotal: Double { voltage * current }
    var powerR1: Double { current * current * r1 }
    var powerR2: Double { current * current * r2 }
}
