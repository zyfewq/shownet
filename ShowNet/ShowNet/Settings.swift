import SwiftUI
import AppKit

// 设置更改通知名
extension Notification.Name {
    static let settingsChanged = Notification.Name("com.shownet.settingsChanged")
}

class Settings: ObservableObject {
    static let shared = Settings()
    
    private init() {
        // 添加观察者以监控UserDefaults更改
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @AppStorage("displayStyle") var displayStyle = DisplayStyle.standard.rawValue {
        didSet {
            notifySettingsChanged()
        }
    }
    
    @AppStorage("uploadColorR") private var uploadColorR: Double = 0.0
    @AppStorage("uploadColorG") private var uploadColorG: Double = 1.0
    @AppStorage("uploadColorB") private var uploadColorB: Double = 0.0
    @AppStorage("uploadColorA") private var uploadColorA: Double = 1.0
    
    @AppStorage("downloadColorR") private var downloadColorR: Double = 0.0
    @AppStorage("downloadColorG") private var downloadColorG: Double = 0.0
    @AppStorage("downloadColorB") private var downloadColorB: Double = 1.0
    @AppStorage("downloadColorA") private var downloadColorA: Double = 1.0
    
    @AppStorage("showIcons") var showIcons = true {
        didSet {
            notifySettingsChanged()
        }
    }
    
    @AppStorage("refreshRate") var refreshRate = 1.0 {
        didSet {
            notifySettingsChanged()
        }
    }
    
    // 在UserDefaults更改时调用
    @objc private func userDefaultsDidChange() {
        DispatchQueue.main.async {
            self.notifySettingsChanged()
        }
    }
    
    // 通知设置更改
    private func notifySettingsChanged() {
        NotificationCenter.default.post(name: Notification.Name("com.shownet.settingsChanged"), object: nil)
    }
    
    // 获取上传颜色
    var uploadColor: Color {
        get {
            Color(.sRGB, red: uploadColorR, green: uploadColorG, blue: uploadColorB, opacity: uploadColorA)
        }
        set {
            if let components = newValue.cgColor?.components {
                uploadColorR = Double(components[0])
                uploadColorG = Double(components[1])
                uploadColorB = Double(components[2])
                uploadColorA = Double(components[3])
            }
            notifySettingsChanged()
        }
    }
    
    // 获取下载颜色
    var downloadColor: Color {
        get {
            Color(.sRGB, red: downloadColorR, green: downloadColorG, blue: downloadColorB, opacity: downloadColorA)
        }
        set {
            if let components = newValue.cgColor?.components {
                downloadColorR = Double(components[0])
                downloadColorG = Double(components[1])
                downloadColorB = Double(components[2])
                downloadColorA = Double(components[3])
            }
            notifySettingsChanged()
        }
    }
    
    // 将SwiftUI的Color转换为NSColor以在AppKit中使用
    func getUploadNSColor() -> NSColor {
        let color = NSColor(uploadColor)
        return color
    }
    
    func getDownloadNSColor() -> NSColor {
        let color = NSColor(downloadColor)
        return color
    }
    
    // 根据当前设置获取显示样式
    func getCurrentDisplayStyle() -> DisplayStyle {
        if let style = DisplayStyle(rawValue: displayStyle) {
            return style
        }
        return .standard
    }
    
    // 获取刷新频率（秒）
    func getRefreshInterval() -> TimeInterval {
        return refreshRate
    }
    
    // 判断是否显示图标
    func shouldShowIcons() -> Bool {
        return showIcons
    }
}

// 显示样式枚举
enum DisplayStyle: String, CaseIterable {
    case compact = "紧凑"
    case standard = "标准"
    case detailed = "详细"
}

// 扩展NSColor以便从SwiftUI的Color创建
extension NSColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 0]
        self.init(red: components[0], 
                  green: components[1], 
                  blue: components[2], 
                  alpha: components[3])
    }
} 