import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let main = MainViewController()
        let window = NSWindow(contentViewController: main)
        window.title = "WinFunktion Mathe"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.contentMinSize = NSSize(width: 760, height: 520)
        window.makeKeyAndOrderFront(nil)
        let controller = NSWindowController(window: window)
        controller.showWindow(self)
        self.windowController = controller
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
