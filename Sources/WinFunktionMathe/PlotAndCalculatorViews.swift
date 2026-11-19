import AppKit

/// Zeichnet den Graphen einer Funktion f(x) mit Achsen.
final class PlotView: NSView {

    var expression: String = "sin(x)" {
        didSet { needsDisplay = true }
    }
    var xRange: Double = 10.0 {
        didSet { needsDisplay = true }
    }

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.windowBackgroundColor.setFill()
        bounds.fill()

        let origin = NSPoint(x: bounds.midX, y: bounds.midY)
        let scaleX = bounds.width / (2 * xRange)
        let scaleY = scaleX

        let axisColor = NSColor.separatorColor
        axisColor.setStroke()

        let xAxisPath = NSBezierPath()
        xAxisPath.move(to: NSPoint(x: 0, y: origin.y))
        xAxisPath.line(to: NSPoint(x: bounds.width, y: origin.y))
        xAxisPath.stroke()

        let yAxisPath = NSBezierPath()
        yAxisPath.move(to: NSPoint(x: origin.x, y: 0))
        yAxisPath.line(to: NSPoint(x: origin.x, y: bounds.height))
        yAxisPath.stroke()

        let gridPath = NSBezierPath()
        gridPath.lineWidth = 0.5
        NSColor.separatorColor.withAlphaComponent(0.5).setStroke()
        for i in stride(from: 1.0, through: xRange, by: 1.0) {
            let dx = CGFloat(i) * CGFloat(scaleX)
            gridPath.move(to: NSPoint(x: origin.x + dx, y: 0))
            gridPath.line(to: NSPoint(x: origin.x + dx, y: bounds.height))
            gridPath.move(to: NSPoint(x: origin.x - dx, y: 0))
            gridPath.line(to: NSPoint(x: origin.x - dx, y: bounds.height))
            let dy = CGFloat(i) * CGFloat(scaleY)
            gridPath.move(to: NSPoint(x: 0, y: origin.y + dy))
            gridPath.line(to: NSPoint(x: bounds.width, y: origin.y + dy))
            gridPath.move(to: NSPoint(x: 0, y: origin.y - dy))
            gridPath.line(to: NSPoint(x: bounds.width, y: origin.y - dy))
        }
        gridPath.stroke()

        let graph = NSBezierPath()
        graph.lineWidth = 2
        NSColor.controlAccentColor.setStroke()

        var started = false
        var previousValid = false
        var previous = NSPoint.zero
        for px in stride(from: 0.0, through: Double(bounds.width), by: 1.0) {
            let xValue = (px - Double(origin.x)) / Double(scaleX)
            guard let yValue = try? MathEngine.evaluate(expression, x: xValue),
                  yValue.isFinite else {
                started = false
                previousValid = false
                continue
            }
            let py = Double(origin.y) - yValue * Double(scaleY)
            let point = NSPoint(x: CGFloat(px), y: CGFloat(py))
            if py < -10000 || py > 10000 {
                started = false
                previousValid = false
                continue
            }
            if !started && !previousValid {
                graph.move(to: point)
                started = true
            } else {
                graph.line(to: point)
            }
            previous = point
            previousValid = true
        }
        graph.stroke()

        drawScaleMarkers(origin: origin, scaleX: scaleX)
    }

    private func drawScaleMarkers(origin: NSPoint, scaleX: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor
        ]
        let step = max(1, Int(xRange / 10))
        var value = step
        while Double(value) <= xRange {
            let dx = CGFloat(value) * scaleX
            let label = NSString(string: "\(value)")
            label.draw(at: NSPoint(x: origin.x + dx - 8, y: origin.y + 4), withAttributes: attributes)
            label.draw(at: NSPoint(x: origin.x - dx - 8, y: origin.y + 4), withAttributes: attributes)
            value += step
        }
    }
}

/// Ansicht mit Eingabefeld und Zoom für den Funktionsplotter.
final class PlotViewController: NSViewController {

    private var plotView: PlotView!
    private var expressionField: NSTextField!

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 660, height: 500))

        let title = NSTextField(labelWithString: "📈  Funktionsplotter")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: "f(x) =")
        label.font = NSFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false

        let field = NSTextField()
        field.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        field.placeholderString = "z. B. x^2 - 3 oder sin(x)"
        field.translatesAutoresizingMaskIntoConstraints = false
        field.target = self
        field.action = #selector(functionChanged)
        expressionField = field

        let apply = NSButton(title: "Zeichnen", target: self, action: #selector(functionChanged))
        apply.bezelStyle = .rounded
        apply.translatesAutoresizingMaskIntoConstraints = false

        let zoomIn = NSButton(title: "＋  Zoom in", target: self, action: #selector(zoomIn))
        zoomIn.bezelStyle = .rounded
        zoomIn.translatesAutoresizingMaskIntoConstraints = false

        let zoomOut = NSButton(title: "－  Zoom out", target: self, action: #selector(zoomOut))
        zoomOut.bezelStyle = .rounded
        zoomOut.translatesAutoresizingMaskIntoConstraints = false

        let plot = PlotView()
        plot.expression = "sin(x)"
        plot.translatesAutoresizingMaskIntoConstraints = false
        self.plotView = plot

        wrapper.addSubview(title)
        wrapper.addSubview(label)
        wrapper.addSubview(field)
        wrapper.addSubview(apply)
        wrapper.addSubview(zoomIn)
        wrapper.addSubview(zoomOut)
        wrapper.addSubview(plot)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            field.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            field.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            field.widthAnchor.constraint(equalToConstant: 280),
            apply.leadingAnchor.constraint(equalTo: field.trailingAnchor, constant: 8),
            apply.centerYAnchor.constraint(equalTo: field.centerYAnchor),
            zoomIn.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            zoomIn.topAnchor.constraint(equalTo: field.topAnchor, constant: 40),
            zoomOut.leadingAnchor.constraint(equalTo: zoomIn.trailingAnchor, constant: 10),
            zoomOut.centerYAnchor.constraint(equalTo: zoomIn.centerYAnchor),
            plot.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            plot.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            plot.topAnchor.constraint(equalTo: zoomIn.bottomAnchor, constant: 14),
            plot.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -24)
        ])

        view = wrapper
    }

    @objc private func functionChanged() {
        let text = expressionField.stringValue
        if text.isEmpty {
            plotView.expression = "0"
            return
        }
        do {
            _ = try MathEngine.evaluate(text, x: 1)
            plotView.expression = text
        } catch {
            plotView.expression = text
        }
    }

    @objc private func zoomIn() {
        plotView.xRange = max(1, plotView.xRange / 1.5)
    }

    @objc private func zoomOut() {
        plotView.xRange = min(200, plotView.xRange * 1.5)
    }
}

/// Wissenschaftlicher Taschenrechner mit Ausdrucksparser und Verlauf.
final class CalculatorViewController: NSViewController {

    private var displayLabel: NSTextField!
    private var historyView: NSTextView!
    private var inputField: NSTextField!

    override func loadView() {
        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 660, height: 500))

        let title = NSTextField(labelWithString: "🧮  Taschenrechner")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.translatesAutoresizingMaskIntoConstraints = false

        let input = NSTextField()
        input.font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        input.placeholderString = "z. B. 2*pi*5 oder sqrt(144)+7^2"
        input.translatesAutoresizingMaskIntoConstraints = false
        input.target = self
        input.action = #selector(calculate)
        inputField = input

        let display = NSTextField(labelWithString: "= 0")
        display.font = NSFont.monospacedSystemFont(ofSize: 30, weight: .bold)
        display.translatesAutoresizingMaskIntoConstraints = false
        displayLabel = display

        let hint = NSTextField(wrappingLabelWithString: "Unterstützt: + − * / ^ ( ) sowie sin, cos, tan, sqrt, ln, log, exp, abs, pi, e. Eingabe mit ⏎ auswerten.")
        hint.font = NSFont.systemFont(ofSize: 11)
        hint.textColor = NSColor.secondaryLabelColor
        hint.translatesAutoresizingMaskIntoConstraints = false

        let clearButton = NSButton(title: "Verlauf löschen", target: self, action: #selector(clearHistory))
        clearButton.bezelStyle = .rounded
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        let historyScroll = NSScrollView()
        historyScroll.hasVerticalScroller = true
        historyScroll.borderType = .bezelBorder
        historyScroll.translatesAutoresizingMaskIntoConstraints = false

        let history = NSTextView()
        history.isEditable = false
        history.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        history.isRichText = false
        historyScroll.documentView = history
        historyView = history

        wrapper.addSubview(title)
        wrapper.addSubview(input)
        wrapper.addSubview(display)
        wrapper.addSubview(hint)
        wrapper.addSubview(clearButton)
        wrapper.addSubview(historyScroll)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            input.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            input.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            input.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            input.heightAnchor.constraint(equalToConstant: 34),
            display.topAnchor.constraint(equalTo: input.bottomAnchor, constant: 10),
            display.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            hint.topAnchor.constraint(equalTo: display.bottomAnchor, constant: 6),
            hint.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            hint.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            historyScroll.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 14),
            historyScroll.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            historyScroll.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            historyScroll.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -24),
            clearButton.topAnchor.constraint(equalTo: historyScroll.topAnchor, constant: 4),
            clearButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -40)
        ])

        view = wrapper
    }

    @objc private func calculate() {
        let text = inputField.stringValue
        guard !text.isEmpty else { return }
        do {
            let value = try MathEngine.evaluate(text)
            if value.isFinite {
                displayLabel.stringValue = "= \(NumberFormatting.german(value, fractionDigits: 10))"
                appendHistory("\(text)  =  \(NumberFormatting.german(value, fractionDigits: 10))")
            } else {
                displayLabel.stringValue = "Nicht definiert"
                appendHistory("\(text)  =  nicht definiert")
            }
        } catch let error as MathError {
            displayLabel.stringValue = "Fehler"
            appendHistory("\(text)  →  \(error.description)")
        } catch {
            displayLabel.stringValue = "Fehler"
        }
    }

    private func appendHistory(_ line: String) {
        let existing = historyView.string
        historyView.string = existing.isEmpty ? line : existing + "\n" + line
        historyView.scrollToEndOfDocument(nil)
    }

    @objc private func clearHistory() {
        historyView.string = ""
    }
}
