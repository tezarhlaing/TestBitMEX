//
//  WebSocketConnection.swift
//  PrestoLabs
//
//

import Foundation
import Starscream

// Enum for WebSocket Disconnection Reason
enum WebSocketDisconnectionReason {
    case reconnectTimeout
    case other(reason: String)
    var stringValue: String {
        switch self {
            case .reconnectTimeout:
                return "Reconnect Timeout"
            case .other(let reason):
                return reason
        }
    }
}

// Enum for WebSocket Errors
enum WebSocketError: Error {
    case invalidURL
}

@objc protocol WebSocketConnectionDelegate: AnyObject {
    func didConnect()
    func didDisconnect(reason: String)
    @objc optional func didReceiveMessage(text: String)
    @objc optional func didReceiveSubData(data: Data)

}

/**
 Manages the WebSocket connection for real-time data communication.

 The `WebSocketConnection` class provides functionalities to establish, manage, and interact with a WebSocket connection.
 It supports reconnection mechanisms and event handling for receiving WebSocket events, such as connection, disconnection, and data reception.

 ## Example Usage:
 ```swift
 let webSocketConnection = WebSocketConnection.shared
 webSocketConnection.connect()
 webSocketConnection.delegate = self
 webSocketConnection.write(string: "Hello, WebSocket!")
 Note: This class uses Starscream library to work with WebSocket communication.
 Important: It's recommended to set the delegate property to receive WebSocket event updates.
 */
class WebSocketConnection {
    /// Singleton instance to ensure thread-safe shared WebSocket connection.
    static let shared = WebSocketConnection()
    /// The Starscream WebSocket instance.
    private var socket: WebSocket?
    /// Timer for automatic reconnection.
    private var reconnectTimer:Timer?
    
    /// The time interval between reconnection attempts.
    let reconnectionInterval: TimeInterval = 10.0
    
    /// Tracks the connection status.
    var isConnect: Bool = false
    
    /// Counts the number of reconnection attempts.
    private var reconnectionCount = 0
    
    /// The delegate for WebSocket connection events.
    weak var delegate: WebSocketConnectionDelegate?
    
    /// The current topic for WebSocket communication.
    var topic: String?
    
    /**
     Private initializer to prevent direct instance creation.
     Initializes the WebSocket connection and sets up the Starscream WebSocket instance.

     - Note: Uses Starscream library for WebSocket communication.
     */
    private init() {
        do {
            guard let url = try createWebSocketURL() else {
                print("WebSocket URL is invalid")
                return
            }
            let urlRequest = URLRequest(url: url)
            self.socket = WebSocket(request: urlRequest)
            self.socket?.delegate = self
        } catch {
               print("Error creating WebSocket URL: \(error.localizedDescription)")
        }
    }
    
    private func createWebSocketURL() throws -> URL? {
        guard let url = URL(string: Constants.WEBSOCKET_ENDPOINT) else {
            throw WebSocketError.invalidURL
        }
        return url
    }

    /**
     Establishes a WebSocket connection.

     Initiates the WebSocket connection by invoking the `connect()` method of the Starscream WebSocket instance.
     */
    func connect() {
        guard let socket = socket else {
            print("Unexpected error! socket not constructed")
            return
        }
        print("Start connect")
        socket.connect()
    }
   
    /**
     Disconnects the WebSocket connection.

     Initiates the disconnection of the WebSocket connection and stops any reconnection timers.
     */
    func disconnect() {
        print("disconnect")
        self.isConnect = false
        self.stopReconnectionTimer()
        self.socket?.disconnect()
    }
    
    /**
     Writes a string to the WebSocket connection.

     - Parameter string: The string data to be sent over the WebSocket.
     */
    func write(string: String) {
        self.socket?.write(string: string)
    }
    
    /**
     Starts a reconnection timer with optional disconnection reason.

     The `startReconnectionTimer` method initiates a timer for reconnection attempts in case of a WebSocket disconnection.
     If the reconnection count exceeds a threshold, it notifies the delegate of disconnection due to a reconnection timeout.

     - Parameters:
       - disconnectionReason: Optional reason for disconnection, defaults to `nil`.

     - Note: The reconnection count is tracked to limit reconnection attempts and notify the delegate when needed.
     */
    private func startReconnectionTimer(disconnectionReason: WebSocketDisconnectionReason? = nil) {
        if self.reconnectionCount > 3 {
            delegate?.didDisconnect(reason: WebSocketDisconnectionReason.reconnectTimeout.stringValue)
            return
        }
        guard reconnectTimer == nil else { return }
        self.reconnectionCount += 1
        reconnectTimer = Timer.scheduledTimer(timeInterval: reconnectionInterval, target: self, selector: #selector(reconnect), userInfo: nil, repeats: false)
    }
    
    /**
     Stops the reconnection timer.

     The `stopReconnectionTimer` method invalidates the reconnection timer, effectively stopping any ongoing reconnection attempts.
     */
    private func stopReconnectionTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    /**
     Reconnects to the WebSocket if not already connected.

     The `reconnect` method attempts to reconnect to the WebSocket server if the connection is not already established.
     This method is triggered by the reconnection timer and ensures that reconnection attempts are made only when necessary.
     */
    @objc private func reconnect() {
        if !self.isConnect {
            connect()

        }
    }
    
}

/**
 An extension of `WebSocketConnection` that handles WebSocket events by conforming to the `WebSocketDelegate` protocol.

 The extension overrides the `didReceive(event:client:)` method from the `WebSocketDelegate` protocol to handle various WebSocket events, such as connection status changes, message reception, and errors.

 - Note: The extension provides default implementations for handling different WebSocket events, and can be customized as needed for specific application requirements.
 */
extension WebSocketConnection : WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket)
    {
        switch(event) {
        case .connected:
            print(" WebSocket Connected!")
            self.isConnect = true
            self.stopReconnectionTimer()
            self.delegate?.didConnect()
            
        case .disconnected(let errMsg, _):
            print("WebSocket Disconnected!")
            self.isConnect = false
            startReconnectionTimer(disconnectionReason: .other(reason: errMsg))

        case .ping:
            print("WebSocket ping!")

            break
            
        case .pong(let data):
            print(" WebSocket pong!")

        case .text(let text):
            
            if let data = text.data(using: .utf8, allowLossyConversion: false) {
                do {
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        print("Json conversion fails!")
                        return
                    }
                   if let dataArr = json["data"] as? [[String:Any]] {
                       let topic =  (json["table"] as? String ?? "") + ":" + (dataArr.first?["symbol"] as? String ?? "")
                       if topic == self.topic {
                           
                           self.delegate?.didReceiveSubData?(data: data)

                       } else {
                           print(json)

                       }
                       return
                    }
                    print(json)
                    self.delegate?.didReceiveMessage?(text: text)
                }
                catch let err {
                    print("Err \(err): \(text)")
                }
            }
            

        case .binary(let data):
            print(" WebSocket Received binary!")

        case .error(let error):
            print(" WebSocket Error: \(error?.localizedDescription ?? "")")
            self.isConnect = false
            let disconnectionReason = WebSocketDisconnectionReason.other(reason: error?.localizedDescription ?? "Unknown Error")
            delegate?.didDisconnect(reason: disconnectionReason.stringValue)

        case .viabilityChanged(let visible):
            print(" WebSocket Visible: \(visible)")
            
        case .reconnectSuggested(let reconnect):
            print(" WebSocket Suggest Reconnect: \(reconnect)")
            startReconnectionTimer()

        case .cancelled:
            print("WebSocket Cancel event received!")
            self.isConnect = false
            let disconnectionReason = WebSocketDisconnectionReason.other(reason: "")
            delegate?.didDisconnect(reason: disconnectionReason.stringValue)

        }
    }
}
