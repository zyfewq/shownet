# ShowNet

ShowNet 是一个简单的 macOS 菜单栏应用程序，可以在菜单栏中实时显示网络上传和下载速度。

![ShowNet 界面截图](ui.png)

## 功能特点

- 实时显示上传和下载速度
- 轻量级，占用资源少
- 常驻菜单栏，方便查看
- 右键菜单可快速退出应用

## 系统要求

- macOS 13.0 或更高版本
- Xcode 14.0 或更高版本（用于开发）

## 安装方法

### 方法一：从源代码构建

1. 克隆本仓库
2. 在 Xcode 中打开项目
3. 构建应用 (⌘+B)
4. 运行应用 (⌘+R)

### 方法二：直接运行

1. 在 Release 模式下构建应用
2. 将生成的 ShowNet.app 移动到应用程序文件夹
3. 启动应用

## 使用方法

启动后，ShowNet 会出现在菜单栏中，显示当前的网络速度。数值每秒更新一次。

- 上传速度显示为向上箭头 (↑)
- 下载速度显示为向下箭头 (↓)

要退出应用，右键点击菜单栏图标并选择"退出"。

## 工作原理

ShowNet 使用原生的 Darwin 网络 API 来跟踪网络接口统计信息并计算实时速度。它会监控所有活动的网络接口以提供准确的读数。

## 开发计划

我们计划在未来的版本中添加以下功能：

1. 硬件监控
   - CPU 温度和频率监控
   - GPU 温度和频率监控
   - 内存使用情况
   - 硬盘读写速度
   - 电池状态（适用于笔记本）

2. 界面优化
   - 可自定义显示项目
   - 支持深色/浅色主题
   - 更详细的数据展示

## 许可证

本项目采用 MIT 许可证。 