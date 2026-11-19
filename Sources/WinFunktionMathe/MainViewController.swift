import AppKit

enum SidebarKind {
    case topic(Int)
    case simulations
    case exercises
    case formulas
    case plotter
    case calculator
}

struct SidebarItem {
    let title: String
    let symbol: String
    let kind: SidebarKind
}

/// Hauptansicht: Themenliste links, Inhaltsbereich rechts.
final class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    private var sidebarItems: [SidebarItem] = []
    private var tableView: NSTableView!
    private var detailContainer: NSView!
    private var currentDetail: NSViewController?

    override func loadView() {
        var items: [SidebarItem] = ContentStore.topics.map { SidebarItem(title: $0.title, symbol: $0.symbol, kind: .topic($0.id)) }
        items.append(SidebarItem(title: "Physik-Simulationen", symbol: "🔬", kind: .simulations))
        items.append(SidebarItem(title: "Übungen", symbol: "🎓", kind: .exercises))
        items.append(SidebarItem(title: "Formelsammlung", symbol: "📚", kind: .formulas))
        items.append(SidebarItem(title: "Funktionsplotter", symbol: "📈", kind: .plotter))
        items.append(SidebarItem(title: "Taschenrechner", symbol: "🧮", kind: .calculator))
        sidebarItems = items

        let root = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: 620))
        root.wantsLayer = true

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("main"))
        column.width = 230

        let table = NSTableView()
        table.addTableColumn(column)
        table.headerView = nil
        table.selectionHighlightStyle = .regular
        table.backgroundColor = NSColor.controlBackgroundColor
        table.dataSource = self
        table.delegate = self
        scrollView.documentView = table
        self.tableView = table

        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.wantsLayer = true
        self.detailContainer = container

        root.addSubview(scrollView)
        root.addSubview(container)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: root.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: 240),
            container.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            container.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            container.topAnchor.constraint(equalTo: root.topAnchor),
            container.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])

        view = root
        table.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        tableViewSelectionDidChange(Notification(name: NSTableView.selectionDidChangeNotification, object: table))
    }

    // MARK: Table View

    func numberOfRows(in tableView: NSTableView) -> Int {
        sidebarItems.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = sidebarItems[row]
        let identifier = NSUserInterfaceItemIdentifier("SidebarRow")
        let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView ?? {
            let newCell = NSTableCellView()
            let field = NSTextField(labelWithString: "")
            field.identifier = NSUserInterfaceItemIdentifier("title")
            field.font = NSFont.systemFont(ofSize: 14, weight: .medium)
            newCell.textField = field
            newCell.addSubview(field)
            field.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: newCell.leadingAnchor, constant: 6),
                field.centerYAnchor.constraint(equalTo: newCell.centerYAnchor)
            ])
            newCell.identifier = identifier
            return newCell
        }()
        cell.textField?.stringValue = "\(item.symbol)  \(item.title)"
        return cell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        36
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let table = notification.object as? NSTableView else { return }
        let row = table.selectedRow
        guard row >= 0, row < sidebarItems.count else { return }
        showDetail(for: sidebarItems[row].kind)
    }

    // MARK: Detailsteuerung

    private func showDetail(for kind: SidebarKind) {
        if let current = currentDetail {
            current.removeFromParent()
            current.view.removeFromSuperview()
        }
        let detail: NSViewController
        switch kind {
        case .topic(let id):
            if let topic = ContentStore.topics.first(where: { $0.id == id }) {
                detail = TopicViewController(topic: topic)
            } else {
                detail = TopicViewController(topic: ContentStore.topics[0])
            }
        case .simulations:
            detail = SimulationViewController()
        case .exercises:
            detail = ExerciseViewController()
        case .formulas:
            detail = FormulaViewController()
        case .plotter:
            detail = PlotViewController()
        case .calculator:
            detail = CalculatorViewController()
        }
        addChild(detail)
        detailContainer.addSubview(detail.view)
        detail.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detail.view.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor),
            detail.view.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor),
            detail.view.topAnchor.constraint(equalTo: detailContainer.topAnchor),
            detail.view.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor)
        ])
        currentDetail = detail
    }
}
