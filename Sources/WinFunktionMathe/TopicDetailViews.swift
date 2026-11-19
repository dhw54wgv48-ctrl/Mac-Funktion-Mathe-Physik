import AppKit

/// Zeigt ein Lerngebiet mit Intro und Kapiteln.
final class TopicViewController: NSViewController {

    private let topic: Topic

    init(topic: Topic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder

        let content = NSStackView()
        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 14
        content.edgeInsets = NSEdgeInsets(top: 24, left: 32, bottom: 32, right: 32)
        content.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "\(topic.symbol)  \(topic.title)")
        title.font = NSFont.boldSystemFont(ofSize: 26)

        let intro = NSTextField(wrappingLabelWithString: topic.intro)
        intro.font = NSFont.systemFont(ofSize: 15)
        intro.textColor = NSColor.secondaryLabelColor

        content.addView(title, in: .leading)
        content.addView(intro, in: .leading)

        for chapter in topic.chapters {
            let header = NSTextField(labelWithString: chapter.title)
            header.font = NSFont.boldSystemFont(ofSize: 17)

            let box = NSBox()
            box.boxType = .primary
            box.title = chapter.title
            box.titleFont = NSFont.boldSystemFont(ofSize: 16)
            box.contentViewMargins = NSSize(width: 16, height: 14)

            let stack = NSStackView()
            stack.orientation = .vertical
            stack.alignment = .leading
            stack.spacing = 10
            for line in chapter.body {
                let label = NSTextField(wrappingLabelWithString: line)
                label.font = NSFont.systemFont(ofSize: 14)
                stack.addView(label, in: .leading)
            }
            box.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
                stack.topAnchor.constraint(equalTo: box.topAnchor, constant: 18),
                stack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -14)
            ])
            content.addView(box, in: .leading)
            _ = header
        }

        scrollView.documentView = content
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.widthAnchor.constraint(greaterThanOrEqualToConstant: 360)
        ])

        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 660, height: 500))
        wrapper.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])

        view = wrapper
        view.wantsLayer = true
        accessibilityDescription = topic.accessibilityDescription
    }
}

/// Formelsammlung als bildlaufbare Liste.
final class FormulaViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    private struct FormulaGroup {
        let topic: String
        let entries: [Formula]
    }

    private var formulasByTopic: [FormulaGroup] = []

    override func loadView() {
        var order: [String] = []
        var map: [String: [Formula]] = [:]
        for formula in ContentStore.formulas {
            if map[formula.topic] == nil { order.append(formula.topic) }
            map[formula.topic, default: []].append(formula)
        }
        formulasByTopic = order.map { FormulaGroup(topic: $0, entries: map[$0] ?? []) }

        let outline = NSOutlineView()
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("formula"))
        column.width = 420
        outline.addTableColumn(column)
        outline.headerView = nil
        outline.dataSource = self
        outline.delegate = self

        let scrollView = NSScrollView()
        scrollView.documentView = outline
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder

        let header = NSTextField(labelWithString: "📚  Formelsammlung")
        header.font = NSFont.boldSystemFont(ofSize: 24)
        header.translatesAutoresizingMaskIntoConstraints = false

        let wrapper = NSView(frame: NSRect(x: 0, y: 0, width: 660, height: 500))
        wrapper.addSubview(header)
        wrapper.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 24),
            header.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            scrollView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 32),
            scrollView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -32),
            scrollView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 72),
            scrollView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -24)
        ])

        view = wrapper
        for index in 0..<formulasByTopic.count {
            outline.expandItem(formulasByTopic[index], expandChildren: true)
        }
    }

    // MARK: Outline data

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil { return formulasByTopic.count }
        if let group = item as? FormulaGroup {
            return group.entries.count
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { return formulasByTopic[index] }
        if let group = item as? FormulaGroup {
            return group.entries[index]
        }
        return formulasByTopic[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is FormulaGroup { return true }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let group = item as? FormulaGroup {
            let field = NSTextField(labelWithString: group.topic)
            field.font = NSFont.boldSystemFont(ofSize: 16)
            return field
        }
        guard let formula = item as? Formula else { return nil }
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2

        let name = NSTextField(labelWithString: formula.name)
        name.font = NSFont.boldSystemFont(ofSize: 13)
        let expression = NSTextField(labelWithString: formula.formula)
        expression.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .medium)
        let note = NSTextField(labelWithString: formula.note)
        note.font = NSFont.systemFont(ofSize: 11)
        note.textColor = NSColor.secondaryLabelColor

        stack.addView(name, in: .leading)
        stack.addView(expression, in: .leading)
        stack.addView(note, in: .leading)
        return stack
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if item is Formula { return 64 }
        return 28
    }
}
