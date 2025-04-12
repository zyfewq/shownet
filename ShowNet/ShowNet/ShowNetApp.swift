import SwiftUI
import AppKit

@main
struct ShowNetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var networkStatusItem: NSStatusItem!
    var networkMonitor: NetworkMonitor!
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application did finish launching")
        
        // 创建状态栏项目
        networkStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if networkStatusItem.button != nil {
            // 初始化显示
            updateStatusBarDisplay(upload: 0, download: 0)
            print("状态栏项目已创建")
            
            // 设置菜单
            setupMenu()
        } else {
            print("错误：无法创建状态栏项目")
            return
        }
        
        // 初始化网络监控器
        networkMonitor = NetworkMonitor()
        print("网络监控器已初始化")
        
        // 根据设置的刷新频率更新速度
        startTimer()
        print("计时器已启动")
        
        // 注册设置更改通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsDidChange),
            name: Notification.Name("com.shownet.settingsChanged"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func settingsDidChange() {
        // 更新计时器间隔
        startTimer()
        
        // 更新状态栏显示
        let (upload, download) = networkMonitor.getCurrentSpeeds()
        updateStatusBarDisplay(upload: upload, download: download)
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "网络监控", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // 添加菜单项以显示详细速度
        let uploadMenuItem = NSMenuItem(title: "上传: 0 KB/s", action: nil, keyEquivalent: "")
        uploadMenuItem.tag = 1
        menu.addItem(uploadMenuItem)
        
        let downloadMenuItem = NSMenuItem(title: "下载: 0 KB/s", action: nil, keyEquivalent: "")
        downloadMenuItem.tag = 2
        menu.addItem(downloadMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加偏好设置菜单
        menu.addItem(NSMenuItem(title: "偏好设置...", action: #selector(openPreferences), keyEquivalent: ","))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        
        networkStatusItem.menu = menu
    }
    
    @objc func openPreferences() {
        PreferencesWindowController.shared.showWindow()
    }
    
    func startTimer() {
        // 停止现有计时器
        timer?.invalidate()
        
        // 获取用户设置的刷新频率
        let interval = UserDefaults.standard.double(forKey: "refreshRate")
        timer = Timer.scheduledTimer(withTimeInterval: interval > 0 ? interval : 1.0, repeats: true) { [weak self] _ in
            self?.updateNetworkSpeed()
        }
    }
    
    func updateNetworkSpeed() {
        let (upload, download) = networkMonitor.getCurrentSpeeds()
        print("当前速度 - 上传: \(upload), 下载: \(download)")
        
        DispatchQueue.main.async {
            self.updateStatusBarDisplay(upload: upload, download: download)
            self.updateMenuItems(upload: upload, download: download)
        }
    }
    
    func updateMenuItems(upload: Double, download: Double) {
        guard let menu = networkStatusItem.menu else { return }
        
        // 更新上传菜单项
        if let uploadItem = menu.item(withTag: 1) {
            uploadItem.title = "上传: \(formatSpeed(upload))"
        }
        
        // 更新下载菜单项
        if let downloadItem = menu.item(withTag: 2) {
            downloadItem.title = "下载: \(formatSpeed(download))"
        }
    }
    
    func updateStatusBarDisplay(upload: Double, download: Double) {
        guard let button = networkStatusItem.button else { return }
        
        // 基于UserDefaults的设置
        let displayStyle = UserDefaults.standard.string(forKey: "displayStyle") ?? "标准"
        
        // 根据所选显示样式更新显示
        switch displayStyle {
        case "紧凑":
            updateCompactDisplay(button: button, upload: upload, download: download)
        case "详细":
            updateDetailedDisplay(button: button, upload: upload, download: download)
        default:
            updateStandardDisplay(button: button, upload: upload, download: download)
        }
    }
    
    // 获取上传颜色
    func getUploadColor() -> NSColor {
        if let colorData = UserDefaults.standard.data(forKey: "uploadColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            return color
        }
        return NSColor.systemGreen
    }
    
    // 获取下载颜色
    func getDownloadColor() -> NSColor {
        if let colorData = UserDefaults.standard.data(forKey: "downloadColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            return color
        }
        return NSColor.systemBlue
    }
    
    // 紧凑显示模式 - 只显示最大的速度值
    func updateCompactDisplay(button: NSStatusBarButton, upload: Double, download: Double) {
        let attributedString = NSMutableAttributedString()
        
        if upload > download {
            attributedString.append(NSAttributedString(string: "↑", attributes: [.foregroundColor: getUploadColor()]))
            attributedString.append(NSAttributedString(string: " \(formatCompactSpeed(upload))"))
        } else {
            attributedString.append(NSAttributedString(string: "↓", attributes: [.foregroundColor: getDownloadColor()]))
            attributedString.append(NSAttributedString(string: " \(formatCompactSpeed(download))"))
        }
        
        button.attributedTitle = attributedString
    }
    
    // 标准显示模式 - 上传和下载并排显示
    func updateStandardDisplay(button: NSStatusBarButton, upload: Double, download: Double) {
        let attributedString = NSMutableAttributedString()
        
        // 添加上传速度指示器
        attributedString.append(NSAttributedString(string: "↑", attributes: [.foregroundColor: getUploadColor()]))
        attributedString.append(NSAttributedString(string: " \(formatCompactSpeed(upload))"))
        
        // 添加分隔符
        attributedString.append(NSAttributedString(string: "  "))
        
        // 添加下载速度指示器
        attributedString.append(NSAttributedString(string: "↓", attributes: [.foregroundColor: getDownloadColor()]))
        attributedString.append(NSAttributedString(string: " \(formatCompactSpeed(download))"))
        
        button.attributedTitle = attributedString
    }
    
    // 详细显示模式 - 带单位的完整速度显示
    func updateDetailedDisplay(button: NSStatusBarButton, upload: Double, download: Double) {
        let attributedString = NSMutableAttributedString()
        
        // 添加上传速度指示器
        attributedString.append(NSAttributedString(string: "↑", attributes: [.foregroundColor: getUploadColor()]))
        attributedString.append(NSAttributedString(string: " \(formatSpeed(upload))"))
        
        // 添加分隔符
        attributedString.append(NSAttributedString(string: "  "))
        
        // 添加下载速度指示器
        attributedString.append(NSAttributedString(string: "↓", attributes: [.foregroundColor: getDownloadColor()]))
        attributedString.append(NSAttributedString(string: " \(formatSpeed(download))"))
        
        button.attributedTitle = attributedString
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

func formatSpeed(_ bytesPerSecond: Double) -> String {
    let kb = bytesPerSecond / 1024
    let mb = kb / 1024
    
    let decimalPlaces = UserDefaults.standard.integer(forKey: "decimalPlaces")
    let showUnits = UserDefaults.standard.bool(forKey: "showUnits")
    
    let format = "%.\(decimalPlaces)f"
    
    if mb >= 1.0 {
        return showUnits ? String(format: "\(format) MB/s", mb) : String(format: "\(format)M", mb)
    } else {
        return showUnits ? String(format: "\(format) KB/s", kb) : String(format: "\(format)K", kb)
    }
}

func formatCompactSpeed(_ bytesPerSecond: Double) -> String {
    let kb = bytesPerSecond / 1024
    let mb = kb / 1024
    
    let decimalPlaces = UserDefaults.standard.integer(forKey: "decimalPlaces")
    let showUnits = UserDefaults.standard.bool(forKey: "showUnits")
    
    let format = "%.\(decimalPlaces)f"
    
    if mb >= 1.0 {
        return showUnits ? String(format: "\(format)M", mb) : String(format: "\(format)", mb)
    } else {
        return showUnits ? String(format: "\(format)K", kb) : String(format: "\(format)", kb)
    }
} 