import AppKit

class NetworkIconGenerator {
    
    static func createNetworkSpeedIcon(speed: Double, isUpload: Bool) -> NSImage {
        // 确定图标大小
        let iconWidth: CGFloat = 18
        let iconHeight: CGFloat = 16
        
        let image = NSImage(size: NSSize(width: iconWidth, height: iconHeight))
        image.lockFocus()
        
        // 根据速度确定要显示的条数
        let speedKB = speed / 1024
        let maxBars = 4
        var filledBars = 0
        
        if speedKB > 5000 {
            filledBars = 4 // >5MB/s
        } else if speedKB > 1000 {
            filledBars = 3 // >1MB/s
        } else if speedKB > 100 {
            filledBars = 2 // >100KB/s
        } else if speedKB > 10 {
            filledBars = 1 // >10KB/s
        }
        
        // 获取用户自定义颜色
        let color = isUpload ? 
            Settings.shared.getUploadNSColor() : 
            Settings.shared.getDownloadNSColor()
        
        // 根据用户设置决定是否显示图标
        if !Settings.shared.shouldShowIcons() {
            image.unlockFocus()
            return image
        }
        
        // 根据上传或下载的不同显示不同样式
        if isUpload {
            // 上传使用垂直条（类似信号强度）
            drawVerticalBars(filledBars: filledBars, maxBars: maxBars, iconWidth: iconWidth, iconHeight: iconHeight, color: color)
        } else {
            // 下载使用水平条（更像电池）
            drawHorizontalBars(filledBars: filledBars, maxBars: maxBars, iconWidth: iconWidth, iconHeight: iconHeight, color: color)
        }
        
        image.unlockFocus()
        return image
    }
    
    private static func drawVerticalBars(filledBars: Int, maxBars: Int, iconWidth: CGFloat, iconHeight: CGFloat, color: NSColor) {
        // 计算尺寸
        let barWidth: CGFloat = 3
        let spacing: CGFloat = 1
        let startX: CGFloat = 2
        let maxHeight: CGFloat = iconHeight - 2
        
        // 绘制条
        for i in 0..<maxBars {
            let barHeight = maxHeight * CGFloat(i+1) / CGFloat(maxBars)
            let barRect = NSRect(
                x: startX + CGFloat(i) * (barWidth + spacing), 
                y: (iconHeight - barHeight) / 2, 
                width: barWidth, 
                height: barHeight
            )
            
            if i < filledBars {
                color.setFill()
            } else {
                NSColor.lightGray.withAlphaComponent(0.5).setFill()
            }
            
            let path = NSBezierPath(roundedRect: barRect, xRadius: 1, yRadius: 1)
            path.fill()
        }
    }
    
    private static func drawHorizontalBars(filledBars: Int, maxBars: Int, iconWidth: CGFloat, iconHeight: CGFloat, color: NSColor) {
        // 计算尺寸
        let totalWidth: CGFloat = iconWidth - 4
        let barHeight: CGFloat = 6
        let barWidth = totalWidth / CGFloat(maxBars)
        let startY: CGFloat = (iconHeight - barHeight) / 2
        
        // 绘制电池外框
        let outlineRect = NSRect(x: 1, y: startY - 1, width: totalWidth + 2, height: barHeight + 2)
        let outlinePath = NSBezierPath(roundedRect: outlineRect, xRadius: 2, yRadius: 2)
        NSColor.lightGray.withAlphaComponent(0.7).setStroke()
        outlinePath.lineWidth = 0.5
        outlinePath.stroke()
        
        // 绘制条段
        for i in 0..<maxBars {
            let barRect = NSRect(
                x: 2 + CGFloat(i) * barWidth,
                y: startY,
                width: barWidth - 1,
                height: barHeight
            )
            
            if i < filledBars {
                color.setFill()
            } else {
                NSColor.clear.setFill()
            }
            
            let path = NSBezierPath(rect: barRect)
            path.fill()
        }
    }
    
    static func createUploadIcon(speed: Double) -> NSImage {
        let icon = createNetworkSpeedIcon(speed: speed, isUpload: true)
        icon.isTemplate = true // 这样可以正确支持暗黑模式
        return icon
    }
    
    static func createDownloadIcon(speed: Double) -> NSImage {
        let icon = createNetworkSpeedIcon(speed: speed, isUpload: false)
        icon.isTemplate = true // 这样可以正确支持暗黑模式
        return icon
    }
} 