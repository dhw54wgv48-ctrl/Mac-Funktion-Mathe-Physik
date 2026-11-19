import AppKit

// MARK: Zeichenhilfen

private enum Drawing {

    static func arrow(from: NSPoint, to: NSPoint, color: NSColor, width: CGFloat = 2) {
        let path = NSBezierPath()
        path.lineWidth = width
        path.move(to: from)
        path.line(to: to)
        color.setStroke()
        path.stroke()

        let angle = atan2(to.y - from.y, to.x - from.x)
        let head: CGFloat = 8
        for offset in [CGFloat.pi * 0.85, -CGFloat.pi * 0.85] {
            let wing = NSPoint(
                x: to.x - head * cos(angle + offset),
                y: to.y - head * sin(angle + offset)
            )
            let headPath = NSBezierPath()
            headPath.lineWidth = width
            headPath.move(to: to)
            headPath.line(to: wing)
            headPath.stroke()
        }
    }

    static func text(_ string: String, at point: NSPoint, size: CGFloat = 12, color: NSColor = .labelColor, bold: Bool = false) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size),
            .foregroundColor: color
        ]
        NSString(string: string).draw(at: point, withAttributes: attributes)
    }

    static func dashedRect(_ rect: NSRect, color: NSColor) {
        let path = NSBezierPath(rect: rect)
        path.setLineDash([4, 3], count: 2, phase: 0)
        path.lineWidth = 1
        color.setStroke()
        path.stroke()
    }
}

// MARK: Schräge Rampe

private final class RampCanvasView: NSView {
    var model = RampModel(angleDeg: 30, mass: 5, friction: 0.2)

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let margin: CGFloat = 34
        let width = bounds.width
        let height = bounds.height
        let origin = NSPoint(x: margin, y: height - margin)
        let rampLength: CGFloat = min(width - 2 * margin - 60, 380)
        let theta = CGFloat(model.angleRad)

        func toScreen(_ x: Double, _ y: Double) -> NSPoint {
            NSPoint(x: origin.x + CGFloat(x), y: origin.y - CGFloat(y))
        }

        let u = (cos: cos(theta), sin: sin(theta))

        // Dreieck
        let triangle = NSBezierPath()
        triangle.move(to: origin)
        let slopeEnd = toScreen(Double(rampLength * u.cos), Double(rampLength * u.sin))
        triangle.line(to: slopeEnd)
        triangle.line(to: NSPoint(x: slopeEnd.x, y: origin.y))
        triangle.close()
        NSColor.underPageBackgroundColor.setFill()
        triangle.fill()
        NSColor.separatorColor.setStroke()
        triangle.lineWidth = 1.5
        triangle.stroke()

        Drawing.text("θ = \(Int(model.angleDeg))°", at: NSPoint(x: origin.x + 26, y: origin.y - 14), color: .secondaryLabelColor)

        // Winkelbogen
        let arc = NSBezierPath()
        arc.appendArc(
            withCenter: origin,
            radius: 44,
            startAngle: 270,
            endAngle: 270 + CGFloat(model.angleDeg),
            clockwise: false
        )
        NSColor.systemBlue.setStroke()
        arc.stroke()

        // Block (Parallelogramm entlang der Rampe)
        let normal = (cos: -sin(theta), sin: cos(theta))
        let side: CGFloat = 34
        let blockPos = rampLength * 0.55
        let p0 = toScreen(Double(blockPos * u.cos), Double(blockPos * u.sin))
        let p1 = toScreen(Double((blockPos + side) * u.cos), Double((blockPos + side) * u.sin))
        let p2 = toScreen(Double((blockPos + side) * u.cos + side * normal.cos), Double((blockPos + side) * u.sin + side * normal.sin))
        let p3 = toScreen(Double(blockPos * u.cos + side * normal.cos), Double(blockPos * u.sin + side * normal.sin))
        let block = NSBezierPath()
        block.move(to: p0)
        block.line(to: p1)
        block.line(to: p2)
        block.line(to: p3)
        block.close()
        NSColor.systemOrange.setFill()
        block.fill()

        // Kräftepfeile vom Blockmittelpunkt
        let center = NSPoint(x: (p0.x + p2.x) / 2, y: (p0.y + p2.y) / 2)
        let fg = model.gravityForce
        let fn = model.normalForce
        let fh = model.slopeForce
        let fr = model.frictionForce
        let maxForce = max(fg, fh, fn, fr, 1)
        let scale: CGFloat = 55.0 / CGFloat(maxForce)

        Drawing.arrow(from: center, to: NSPoint(x: center.x, y: center.y + CGFloat(fg) * scale), color: .systemRed)
        Drawing.text("Fg=\(NumberFormatting.german(fg)) N", at: NSPoint(x: center.x + 4, y: center.y + CGFloat(fg) * scale + 4), color: .systemRed)

        Drawing.arrow(
            from: center,
            to: NSPoint(x: center.x - CGFloat(fn) * scale * CGFloat(normal.cos), y: center.y - CGFloat(fn) * scale * CGFloat(normal.sin)),
            color: .systemBlue
        )
        Drawing.text("FN=\(NumberFormatting.german(fn)) N", at: NSPoint(x: p2.x + 4, y: p2.y - 16), color: .systemBlue)

        let hang = NSPoint(x: center.x + CGFloat(fh) * scale * CGFloat(u.cos), y: center.y + CGFloat(fh) * scale * CGFloat(u.sin))
        Drawing.arrow(from: center, to: hang, color: .systemGreen)
        Drawing.text("FH=\(NumberFormatting.german(fh)) N", at: NSPoint(x: hang.x + 4, y: hang.y + 4), color: .systemGreen)

        if fr > 0.01 {
            let frictionEnd = NSPoint(
                x: center.x - CGFloat(fr) * scale * CGFloat(u.cos) * 0.9,
                y: center.y - CGFloat(fr) * scale * CGFloat(u.sin) * 0.9
            )
            Drawing.arrow(from: center, to: frictionEnd, color: .systemPurple)
            Drawing.text("FR=\(NumberFormatting.german(fr)) N", at: NSPoint(x: frictionEnd.x - 140, y: frictionEnd.y + 10), color: .systemPurple)
        }

        // Statuszeile
        let status = model.isMoving
            ? "Block rutscht: a = \(NumberFormatting.german(model.acceleration)) m/s²"
            : "Block haftet (FH ≤ FR)"
        Drawing.text(status, at: NSPoint(x: margin, y: height - 18), size: 13, color: model.isMoving ? .systemGreen : .secondaryLabelColor, bold: true)
    }
}

// MARK: Optikbank

private final class OpticsCanvasView: NSView {
    var model = LensModel(focalLength: 10, objectDistance: 25, objectHeight: 5)

    override func draw(_ dirtyRect: NSRect) {
        let height = bounds.height
        let axisY = height / 2
        let lensX = bounds.width / 2 + 40

        let spanNeeded = max(model.objectDistance, abs(min(model.imageDistance, 60)))
        let pxPerCm = min(5.0, max(1.5, (bounds.width - 120) / max(spanNeeded, 1)))

        // Optische Achse
        let axis = NSBezierPath()
        axis.setLineDash([6, 4], count: 2, phase: 0)
        axis.move(to: NSPoint(x: 20, y: axisY))
        axis.line(to: NSPoint(x: bounds.width - 20, y: axisY))
        NSColor.separatorColor.setStroke()
        axis.stroke()

        // Linse (Doppelpfeil-Form als Ellipse)
        let lensRect = NSRect(x: lensX - 8, y: axisY - 90, width: 16, height: 180)
        let lens = NSBezierPath(ovalIn: lensRect)
        NSColor.systemBlue.withAlphaComponent(0.35).setFill()
        lens.fill()
        NSColor.systemBlue.setStroke()
        lens.stroke()
        Drawing.text("Linse", at: NSPoint(x: lensX - 22, y: axisY + 96), color: .systemBlue)

        // Brennpunkte
        let fLeft = lensX - CGFloat(model.focalLength) * pxPerCm
        let fRight = lensX + CGFloat(model.focalLength) * pxPerCm
        for (x, name) in [(fLeft, "F"), (fRight, "F'")] {
            NSColor.systemBlue.setFill()
            NSRect(x: x - 2.5, y: axisY - 2.5, width: 5, height: 5).fill()
            Drawing.text(name, at: NSPoint(x: x - 4, y: axisY + 8), color: .systemBlue)
        }
        Drawing.text("f = \(NumberFormatting.german(model.focalLength)) cm", at: NSPoint(x: fLeft - 30, y: axisY + 24), color: .systemBlue)

        guard model.isValid, model.imageDistance.isFinite else {
            Drawing.text("Gegenstand liegt im Brennpunkt → Bild im Unendlichen", at: NSPoint(x: 30, y: 24), size: 13, color: .systemOrange, bold: true)
            return
        }

        let objectX = lensX - CGFloat(model.objectDistance) * pxPerCm
        let objectH = CGFloat(model.objectHeight) * pxPerCm
        let imageX = lensX + CGFloat(model.imageDistance) * pxPerCm
        let imageH = -CGFloat(model.imageHeight) * pxPerCm

        // Gegenstand (Pfeil)
        Drawing.arrow(from: NSPoint(x: objectX, y: axisY), to: NSPoint(x: objectX, y: axisY - objectH), color: .systemGreen, width: 3)
        Drawing.text("Gegenstand", at: NSPoint(x: objectX - 40, y: axisY - objectH - 18), color: .systemGreen)

        // Strahlengang
        let objectTip = NSPoint(x: objectX, y: axisY - objectH)
        // Strahl 1: parallel → durch F'
        Drawing.arrow(from: objectTip, to: NSPoint(x: lensX, y: objectTip.y), color: .systemRed)
        Drawing.arrow(from: NSPoint(x: lensX, y: objectTip.y), to: NSPoint(x: imageX, y: axisY + imageH), color: .systemRed)
        // Strahl 2: durch Mittelpunkt
        Drawing.arrow(from: objectTip, to: NSPoint(x: lensX, y: axisY), color: .systemPurple)
        let slope = (axisY - objectTip.y) / (lensX - objectX)
        Drawing.arrow(from: NSPoint(x: lensX, y: axisY), to: NSPoint(x: imageX, y: axisY - slope * (imageX - lensX)), color: .systemPurple)

        // Bild
        let imageColor: NSColor = model.isRealImage ? .systemOrange : .systemTeal
        Drawing.arrow(from: NSPoint(x: imageX, y: axisY), to: NSPoint(x: imageX, y: axisY + imageH), color: imageColor, width: 3)
        let capping = min(max(imageX + 10, 30), bounds.width - 140)
        Drawing.text(model.isRealImage ? "reelles Bild" : "virtuelles Bild", at: NSPoint(x: capping, y: axisY + imageH - (imageH > 0 ? -16 : 16)), color: imageColor, bold: true)
        Drawing.text("b = \(NumberFormatting.german(model.imageDistance)) cm", at: NSPoint(x: capping, y: axisY + imageH + (imageH > 0 ? -18 : 30)), color: imageColor)
    }
}

// MARK: Schaltung

private final class CircuitCanvasView: NSView {
    var model = CircuitModel(voltage: 12, r1: 10, r2: 20)

    override func draw(_ dirtyRect: NSRect) {
        let inset: CGFloat = 46
        let rect = NSRect(x: inset + 30, y: inset, width: bounds.width - 2 * inset - 30, height: bounds.height - 2 * inset)

        // Leitungslinien
        NSColor.labelColor.setStroke()
        let path = NSBezierPath()
        path.lineWidth = 2
        path.move(to: NSPoint(x: rect.minX, y: rect.minY))
        path.line(to: NSPoint(x: rect.minX, y: rect.maxY))
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
        path.line(to: NSPoint(x: rect.maxX, y: rect.minY))
        path.line(to: NSPoint(x: rect.minX, y: rect.minY))
        path.stroke()

        // Spannungsquelle (links, zwei Striche)
        NSColor.systemRed.setStroke()
        let long = NSBezierPath()
        long.lineWidth = 3
        long.move(to: NSPoint(x: rect.minX - 10, y: rect.minY + (rect.height / 3)))
        long.line(to: NSPoint(x: rect.minX + 10, y: rect.minY + (rect.height / 3)))
        long.stroke()
        let short = NSBezierPath()
        short.lineWidth = 3
        short.move(to: NSPoint(x: rect.minX - 6, y: rect.minY + (rect.height / 3) - 22))
        short.line(to: NSPoint(x: rect.minX + 6, y: rect.minY + (rect.height / 3) - 22))
        short.stroke()
        Drawing.text("+", at: NSPoint(x: rect.minX + 14, y: rect.minY + (rect.height / 3) + 4), color: .systemRed, bold: true)
        Drawing.text("U = \(NumberFormatting.german(model.voltage)) V", at: NSPoint(x: rect.minX - 6, y: rect.minY + (rect.height / 3) + 24), color: .systemRed)

        // Widerstände als Rechtecke (Reihenschaltung oben)
        let boxWidth: CGFloat = 64
        let boxHeight: CGFloat = 26
        let r1Center = NSPoint(x: rect.minX + rect.width * 0.3, y: rect.maxY)
        let r2Center = NSPoint(x: rect.minX + rect.width * 0.7, y: rect.maxY)
        for (center, label, value) in [
            (r1Center, "R1", "R1 = \(NumberFormatting.german(model.r1)) Ω"),
            (r2Center, "R2", "R2 = \(NumberFormatting.german(model.r2)) Ω")
        ] {
            let rbox = NSRect(x: center.x - boxWidth / 2, y: center.y - boxHeight / 2, width: boxWidth, height: boxHeight)
            NSColor.windowBackgroundColor.setFill()
            NSBezierPath(roundedRect: rbox, xRadius: 5, yRadius: 5).fill()
            NSColor.systemBlue.setStroke()
            let boxPath = NSBezierPath(roundedRect: rbox, xRadius: 5, yRadius: 5)
            boxPath.lineWidth = 2
            boxPath.stroke()
            Drawing.text(label, at: NSPoint(x: center.x - 8, y: center.y + 5), color: .systemBlue, bold: true)
            Drawing.text(value, at: NSPoint(x: center.x - 42, y: center.y + boxHeight + 2), color: .systemBlue)
        }

        // Stromrichtung
        let arrowY = rect.minY - 16
        Drawing.arrow(from: NSPoint(x: rect.minX + 40, y: arrowY + 14), to: NSPoint(x: rect.minX + 120, y: arrowY + 14), color: .systemGreen)
        Drawing.text("I = \(NumberFormatting.german(model.current)) A", at: NSPoint(x: rect.minX + 130, y: arrowY + 8), color: .systemGreen, bold: true)
    }
}


private func wrapField(_ text: String) -> NSTextField {
    let field = NSTextField(wrappingLabelWithString: text)
    field.font = NSFont.systemFont(ofSize: 11)
    field.preferredMaxLayoutWidth = 210
    return field
}

// MARK: Simulations-View-Controller

private func sliderGroup(title: String, min: Double, max: Double, value: Double, target: Any?, action: Selector, tag: Int, unit: String, valueLabel: inout NSTextField?) -> NSStackView {
    let titleLabel = NSTextField(labelWithString: title)
    titleLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)

    let slider = NSSlider(value: value, target: target, action: action, minValue: min, maxValue: max)
    slider.tag = tag
    slider.continuous = true

    let label = NSTextField(labelWithString: "\(NumberFormatting.german(value)) \(unit)")
    label.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
    label.textColor = NSColor.secondaryLabelColor
    valueLabel = label

    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 4
    stack.addView(titleLabel, in: .leading)
    stack.addView(slider, in: .leading)
    stack.addView(label, in: .leading)
    slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
    return stack
}

final class RampSimulationViewController: NSViewController {

    private var canvas: RampCanvasView!
    private var angleLabel: NSTextField?
    private var massLabel: NSTextField?
    private var frictionLabel: NSTextField?
    private var readoutLabel: NSTextField!
    private var model = RampModel(angleDeg: 30, mass: 5, friction: 0.2)

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 460))

        let canvasView = RampCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(canvasView)
        canvas = canvasView

        let controls = NSStackView()
        controls.orientation = .vertical
        controls.alignment = .leading
        controls.spacing = 16
        controls.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(controls)

        let heading = NSTextField(labelWithString: "Schräge Rampe")
        heading.font = NSFont.boldSystemFont(ofSize: 17)
        controls.addView(heading, in: .leading)

        controls.addView(
            sliderGroup(title: "Neigungswinkel θ", min: 5, max: 80, value: model.angleDeg, target: self, action: #selector(sliderMoved(_:)), tag: 0, unit: "°", valueLabel: &angleLabel),
            in: .leading
        )
        controls.addView(
            sliderGroup(title: "Masse m", min: 0.5, max: 20, value: model.mass, target: self, action: #selector(sliderMoved(_:)), tag: 1, unit: "kg", valueLabel: &massLabel),
            in: .leading
        )
        controls.addView(
            sliderGroup(title: "Reibung µ", min: 0, max: 1, value: model.friction, target: self, action: #selector(sliderMoved(_:)), tag: 2, unit: "", valueLabel: &frictionLabel),
            in: .leading
        )

        let explanation = wrapField("Hangabtriebskraft F_H = m·g·sinθ, Normalkraft F_N = m·g·cosθ, Reibung F_R = µ·F_N. Der Block rutscht, sobald F_H > F_R; dann gilt a = g·(sinθ − µ·cosθ).")
        explanation.font = NSFont.systemFont(ofSize: 11)
        controls.addView(explanation, in: .leading)

        readoutLabel = wrapField("")
        readoutLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        controls.addView(readoutLabel, in: .leading)

        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 24),
            canvas.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            canvas.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -16),
            canvas.trailingAnchor.constraint(equalTo: controls.leadingAnchor, constant: -20),
            controls.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            controls.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20)
        ])

        view = wrapper
        update()
    }

    @objc private func sliderMoved(_ sender: NSSlider) {
        switch sender.tag {
        case 0: model.angleDeg = sender.doubleValue
        case 1: model.mass = sender.doubleValue
        default: model.friction = sender.doubleValue
        }
        update()
    }

    private func update() {
        canvas.model = model
        canvas.needsDisplay = true
        angleLabel?.stringValue = "\(NumberFormatting.german(model.angleDeg)) °"
        massLabel?.stringValue = "\(NumberFormatting.german(model.mass)) kg"
        frictionLabel?.stringValue = NumberFormatting.german(model.friction, fractionDigits: 2)
        readoutLabel.stringValue = """
            F_G = \(NumberFormatting.german(model.gravityForce)) N
            F_H = \(NumberFormatting.german(model.slopeForce)) N
            F_N = \(NumberFormatting.german(model.normalForce)) N
            F_R = \(NumberFormatting.german(model.frictionForce)) N
            a   = \(NumberFormatting.german(model.acceleration)) m/s²
            """
    }
}

final class OpticsSimulationViewController: NSViewController {

    private var canvas: OpticsCanvasView!
    private var focalLabel: NSTextField?
    private var distanceLabel: NSTextField?
    private var readoutLabel: NSTextField!
    private var model = LensModel(focalLength: 10, objectDistance: 25, objectHeight: 5)

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 460))

        let canvasView = OpticsCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(canvasView)
        canvas = canvasView

        let controls = NSStackView()
        controls.orientation = .vertical
        controls.alignment = .leading
        controls.spacing = 16
        controls.translatesAutoresizingMaskIntoConstraints = false

        let heading = NSTextField(labelWithString: "Optikbank (Sammellinse)")
        heading.font = NSFont.boldSystemFont(ofSize: 17)
        controls.addView(heading, in: .leading)

        controls.addView(
            sliderGroup(title: "Brennweite f", min: 5, max: 30, value: model.focalLength, target: self, action: #selector(sliderMoved(_:)), tag: 0, unit: "cm", valueLabel: &focalLabel),
            in: .leading
        )
        controls.addView(
            sliderGroup(title: "Gegenstandsweite a", min: 6, max: 80, value: model.objectDistance, target: self, action: #selector(sliderMoved(_:)), tag: 1, unit: "cm", valueLabel: &distanceLabel),
            in: .leading
        )

        let explanation = wrapField("Linsengleichung 1/f = 1/a + 1/b. Der Gegenstandspfeil steht links; gezeichnet werden der Parallelstrahl (rot) und der Mittelpunktstrahl (violett). Für a > f entsteht ein reelles, umgekehrtes Bild.")
        explanation.font = NSFont.systemFont(ofSize: 11)
        controls.addView(explanation, in: .leading)

        readoutLabel = wrapField("")
        readoutLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        controls.addView(readoutLabel, in: .leading)

        wrapper.addSubview(controls)

        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 24),
            canvas.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            canvas.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -16),
            canvas.trailingAnchor.constraint(equalTo: controls.leadingAnchor, constant: -20),
            controls.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            controls.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20)
        ])

        view = wrapper
        update()
    }

    @objc private func sliderMoved(_ sender: NSSlider) {
        switch sender.tag {
        case 0: model.focalLength = sender.doubleValue
        default: model.objectDistance = sender.doubleValue
        }
        update()
    }

    private func update() {
        canvas.model = model
        canvas.needsDisplay = true
        focalLabel?.stringValue = "\(NumberFormatting.german(model.focalLength)) cm"
        distanceLabel?.stringValue = "\(NumberFormatting.german(model.objectDistance)) cm"
        if !model.isValid || !model.imageDistance.isFinite {
            readoutLabel.stringValue = "Bild im Unendlichen (a = f)."
            return
        }
        readoutLabel.stringValue = """
            b   = \(NumberFormatting.german(model.imageDistance)) cm
            V   = \(NumberFormatting.german(model.magnification))
            B   = \(NumberFormatting.german(model.imageHeight)) cm
            \(model.isRealImage ? "reelles, umgekehrtes Bild" : "virtuelles, aufrechtes Bild")
            """
    }
}

final class CircuitSimulationViewController: NSViewController {

    private var canvas: CircuitCanvasView!
    private var voltageLabel: NSTextField?
    private var r1Label: NSTextField?
    private var r2Label: NSTextField?
    private var readoutLabel: NSTextField!
    private var model = CircuitModel(voltage: 12, r1: 10, r2: 20)

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 460))

        let canvasView = CircuitCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(canvasView)
        canvas = canvasView

        let controls = NSStackView()
        controls.orientation = .vertical
        controls.alignment = .leading
        controls.spacing = 16
        controls.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(controls)

        let heading = NSTextField(labelWithString: "E-Lehre: Reihenschaltung")
        heading.font = NSFont.boldSystemFont(ofSize: 17)
        controls.addView(heading, in: .leading)

        controls.addView(
            sliderGroup(title: "Quellspannung U", min: 1, max: 24, value: model.voltage, target: self, action: #selector(sliderMoved(_:)), tag: 0, unit: "V", valueLabel: &voltageLabel),
            in: .leading
        )
        controls.addView(
            sliderGroup(title: "Widerstand R1", min: 1, max: 60, value: model.r1, target: self, action: #selector(sliderMoved(_:)), tag: 1, unit: "Ω", valueLabel: &r1Label),
            in: .leading
        )
        controls.addView(
            sliderGroup(title: "Widerstand R2", min: 1, max: 60, value: model.r2, target: self, action: #selector(sliderMoved(_:)), tag: 2, unit: "Ω", valueLabel: &r2Label),
            in: .leading
        )

        let explanation = wrapField("Reihenschaltung: R_ges = R1 + R2, I = U / R_ges. Spannungen teilen sich im Verhältnis der Widerstände auf (U1 = I·R1, U2 = I·R2).")
        explanation.font = NSFont.systemFont(ofSize: 11)
        controls.addView(explanation, in: .leading)

        readoutLabel = wrapField("")
        readoutLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        controls.addView(readoutLabel, in: .leading)

        NSLayoutConstraint.activate([
            canvas.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 24),
            canvas.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 16),
            canvas.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -16),
            canvas.trailingAnchor.constraint(equalTo: controls.leadingAnchor, constant: -20),
            controls.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            controls.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20)
        ])

        view = wrapper
        update()
    }

    @objc private func sliderMoved(_ sender: NSSlider) {
        switch sender.tag {
        case 0: model.voltage = sender.doubleValue
        case 1: model.r1 = sender.doubleValue
        default: model.r2 = sender.doubleValue
        }
        update()
    }

    private func update() {
        canvas.model = model
        canvas.needsDisplay = true
        voltageLabel?.stringValue = "\(NumberFormatting.german(model.voltage)) V"
        r1Label?.stringValue = "\(NumberFormatting.german(model.r1)) Ω"
        r2Label?.stringValue = "\(NumberFormatting.german(model.r2)) Ω"
        readoutLabel.stringValue = """
            R_ges = \(NumberFormatting.german(model.totalResistance)) Ω
            I     = \(NumberFormatting.german(model.current)) A
            U1    = \(NumberFormatting.german(model.voltageR1)) V
            U2    = \(NumberFormatting.german(model.voltageR2)) V
            P_ges = \(NumberFormatting.german(model.powerTotal)) W
            P1    = \(NumberFormatting.german(model.powerR1)) W
            P2    = \(NumberFormatting.german(model.powerR2)) W
            """
    }
}

// MARK: Container mit Simulationsauswahl

final class SimulationViewController: NSViewController {

    private var current: NSViewController?
    private var container: NSView!

    private lazy var ramp = RampSimulationViewController()
    private lazy var optics = OpticsSimulationViewController()
    private lazy var circuit = CircuitSimulationViewController()

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 500))

        let title = NSTextField(labelWithString: "🔬  Physik-Simulationen")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(title)

        let segments = NSSegmentedControl(
            labels: ["Schräge Rampe", "Optikbank", "Reihenschaltung"],
            targets: [self, self, self],
            actions: [#selector(segmentSelected(_:)), #selector(segmentSelected(_:)), #selector(segmentSelected(_:))],
            forMode: .selectOne
        )
        segments.selectedSegment = 0
        segments.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(segments)

        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(containerView)
        container = containerView

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            segments.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            segments.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            segments.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            container.topAnchor.constraint(equalTo: segments.bottomAnchor, constant: 18),
            container.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])

        view = wrapper
        show(ramp)
    }

    @objc private func segmentSelected(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0: show(ramp)
        case 1: show(optics)
        default: show(circuit)
        }
    }

    private func show(_ controller: NSViewController) {
        if current === controller { return }
        if let existing = current {
            existing.removeFromParent()
            existing.view.removeFromSuperview()
        }
        addChild(controller)
        container.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: container.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        current = controller
    }
}
