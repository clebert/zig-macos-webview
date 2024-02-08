import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let url: String

    func makeNSView(context: Context) -> WKWebView  {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebView>) {
        nsView.load(URLRequest(url: URL(string: url)!))
    }
}
