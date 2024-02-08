# zig-macos-webview

> A Zig and Swift PoC for lightweight, resource-efficient native macOS apps.

**zig-macos-webview** is a Proof-of-Concept project that combines macOS Swift UI, Zig server logic,
and web technologies to build native applications. A Zig web server serves a web UI
(HTML/JavaScript/CSS) displayed in a WebView window within a Swift UI App. This leverage the ease of
designing UIs with web technologies, plus the effectiveness of Zig for logic. The output: a compact
binary (just 160 KB), optimized for speed and smaller than Electron-based alternatives.
