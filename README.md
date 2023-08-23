# TestWebSocket

Welcome toTestWebSocket This project showcases how to integrate third-party libraries into an iOS app. It includes examples of using the ProgressHUD library for displaying loading indicators and the Starscream library for WebSocket communication.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [ProgressHUD](#progresshud)
  - [Starscream](#starscream)
- [Dependencies](#dependencies)

## Installation

### Swift Package Manager (SPM)

To integrate the project into your Xcode project using Swift Package Manager (SPM), follow these steps:

1. Open your Xcode project.

2. Click on "File" > "Swift Packages" > "Add Package Dependency..."

3. Enter the repository URLs for the required packages:
   - ProgressHUD: https://github.com/relatedcode/ProgressHUD.git
   - Starscream: https://github.com/daltoniam/Starscream.git

4. Click "Next" and then specify the version or branch you want to use.

5. Click "Finish" to add the packages to your project.

6. Import the libraries into your Swift files where you want to use them.

## Usage

### ProgressHUD

ProgressHUD is used to display loading indicators in your app. Here's how to use it:

// Import the ProgressHUD module
import ProgressHUD

// Show the loading indicator
ProgressHUD.show()

// Hide the loading indicator
ProgressHUD.dismiss()

Copy code
// Import the Starscream module
import Starscream

// Create a WebSocket instance
let socket = WebSocket(url: URL(string: "wss://your.websocket.url")!)

// Set WebSocket event handlers
socket.onConnect = {
    print("WebSocket connected")
}

socket.onText = { text in
    print("Received text: \(text)")
}

// Connect to the WebSocket
socket.connect()

## Dependencies

ProgressHUD: Loading indicator library for iOS apps.
Starscream: WebSocket library for Swift.

##  License

This project is available under the MIT License.
