import SwiftUI
import AppKit

class PreferencesWindowController {
    private var window: NSWindow?
    private let preferencesView = PreferencesView()
    
    static let shared = PreferencesWindowController()
    
    private init() {}
    
    func showWindow() {
        if let window = self.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // 创建窗口
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "ShowNet 偏好设置"
        window.center()
        window.setFrameAutosaveName("PreferencesWindow")
        window.contentView = NSHostingView(rootView: preferencesView)
        window.isReleasedWhenClosed = false
        
        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
} 