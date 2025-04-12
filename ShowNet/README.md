# ShowNet

ShowNet is a simple macOS menu bar application that displays real-time network speed (upload and download) in your menu bar.

## Features

- Displays real-time upload and download speeds
- Lightweight and minimal resource usage
- Lives in your menu bar for easy access
- Simple right-click menu to quit the application

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later (for development)

## Installation

### Option 1: Build from Source

1. Clone this repository
2. Open the project in Xcode
3. Build the application (⌘+B)
4. Run the application (⌘+R)

### Option 2: Run in Release Mode

1. Build the application in Release mode
2. Move the built ShowNet.app to your Applications folder
3. Launch the application

## Usage

Once launched, ShowNet will appear in your menu bar displaying your current network speeds. The values are updated every second.

- Upload speed is displayed with an up arrow (↑)
- Download speed is displayed with a down arrow (↓)

To quit the application, right-click on the menu bar icon and select "Quit".

## How It Works

ShowNet uses the native Darwin networking APIs to track network interface statistics and calculate real-time speeds. It monitors all active network interfaces to provide accurate readings.

## License

This project is available under the MIT License. 