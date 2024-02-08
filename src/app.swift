import SwiftUI

@main
struct Main: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var state = AppState.shared

    var body: some Scene {
        WindowGroup {
            WebView(url: "http://127.0.0.1:\(state.port)")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if (start_server() != 0) {
            exit(1)
        }

        AppState.shared.port = get_port()

        signal(SIGPIPE) { _ in }
        signal(SIGABRT) { _ in stop_server() }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationWillTerminate(_ notification: Notification) {
        stop_server()
    }
}

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var port: Int32 = 0
}
