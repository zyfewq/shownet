import SwiftUI

struct PreferencesView: View {
    @StateObject private var settings = Settings.shared
    
    var body: some View {
        TabView {
            // 显示设置
            VStack(alignment: .leading, spacing: 20) {
                // 显示样式
                VStack(alignment: .leading) {
                    Text("显示样式:")
                    Picker("显示样式", selection: $settings.displayStyle) {
                        ForEach(DisplayStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                }
                
                // 图标显示
                Toggle("显示图标", isOn: $settings.showIcons)
                
                // 刷新频率
                VStack(alignment: .leading) {
                    Text("刷新频率: \(String(format: "%.1f", settings.refreshRate)) 秒")
                    Slider(value: $settings.refreshRate, in: 0.1...5.0, step: 0.1)
                }
                
                // 颜色设置
                VStack(alignment: .leading) {
                    Text("颜色设置:")
                    HStack {
                        Text("上传:")
                        ColorPicker("", selection: $settings.uploadColor)
                    }
                    HStack {
                        Text("下载:")
                        ColorPicker("", selection: $settings.downloadColor)
                    }
                }
            }
            .padding()
            .tabItem {
                Label("显示", systemImage: "display")
            }
            
            // 关于页面
            VStack {
                Text("ShowNet")
                    .font(.title)
                Text("版本 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                    .frame(height: 20)
                Text("一个简单的网速监控工具")
                Link("GitHub 仓库", destination: URL(string: "https://github.com/zhao0/ShowNet")!)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tabItem {
                Label("关于", systemImage: "info.circle")
            }
        }
        .frame(width: 300, height: 400)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
} 