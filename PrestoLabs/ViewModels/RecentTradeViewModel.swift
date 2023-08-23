//
//  RecentTradeViewModel.swift
//  PrestoLabs
//
//  Created by tzh.
//

import Foundation
import Combine

/**
 A delegate protocol to handle events and updates related to the RecentTradeViewModel.
 
 The methods defined in this protocol allow the RecentTradeViewModel to communicate various events and updates to its delegate.
 
 */
protocol RecentTradeViewModelDelegate: AnyObject {
    /**
     Informs the delegate to reload the data.
     
     This method is called when the RecentTradeViewModel needs the delegate to refresh or reload the displayed data.
     
     */
    func reloadData()
    /**
     Notifies the delegate about a connection error.
     
     - Parameter msg: A message describing the connection error.
     
     This method is called when there's an error related to the WebSocket connection, providing a description of the error message.
     
     */
    func notifyConnectionError(msg: String)
    /**
     Notifies the delegate about a disconnection event.
     
     - Parameter msg: A message describing the disconnection event.
     
     This method is called when the WebSocket connection has been disconnected, providing a description of the reason for the disconnection.
     
     */
    
    func didDisconnect(msg: String)
    
}

class RecentTradeViewModel {
    /// The topic associated with the recent trade.
    private let topic: String
    
    /// The WebSocket connection instance used for recent trades data.
    private var webSocketConnection : WebSocketConnection
    
    /// A weak reference to the delegate responsible for handling events from this view model.
    weak var delegate: RecentTradeViewModelDelegate?
    
    /// A collection of cancellable objects used for managing asynchronous operations.
    private var tradeDataManager: TradeDataManager<Trade>!
    
    /// A collection of cancellable objects used for managing asynchronous operations.
    private var cancellables: Set<AnyCancellable> = []
    
    /// The list of recent trades.
    private var trades: [Trade] = []
    
    /**
     The number of recent trade to be displayed in the  Recent Trade.
     
     This computed property returns the minimum value between 30 and the actual count of  recent trade. This is used to ensure that only a maximum of 30 trades count are displayed in the Recent Trade UI.
     */
    var tradeCount: Int {
        return min(30, trades.count)
    }
    /**
     Initializes the RecentTradeViewModel.
     
     - Parameters:
     - topic: The topic to subscribe to for trade updates.
     - webSocketConnection: The WebSocketConnection instance to communicate with the WebSocket.
     */
    init(topic: String, webSocketConnection: WebSocketConnection) {
        self.topic = topic
        self.webSocketConnection = webSocketConnection
        self.tradeDataManager = TradeDataManager<Trade>()
        
    }
    
    /**
     Sets up publishers to receive updates from the trade data manager.
     
     This method sets up publishers for recent trade updates from the trade data manager. It subscribes to changes in the top descending recent trade lists and updates the `trades`accordingly. Additionally, it triggers a UI reload through the delegate.
     */
    func setPublisherData() {
        let publisher = tradeDataManager.getTopDescendingListPublisher()
        
        publisher
            .sink { [weak self] updatedTrades in
                self?.trades = updatedTrades
                self?.delegate?.reloadData()
            }
            .store(in: &cancellables)
    }
    /**
     Performs necessary cleanup when the view model is deallocated.
     
     This method is called when the `RecentTradeViewModel` is deallocated. It cancels all the registered cancellables, ensuring that there are no memory leaks or invalid references to publishers.
     */
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    /**
     Establishes a WebSocket connection and subscribes to data updates if necessary.
     
     This method is responsible for establishing a WebSocket connection using the `webSocketConnection` property. If a connection is not already established, it attempts to connect asynchronously in the background. Upon successful connection, the delegate is assigned and data subscription is initiated. If connection fails, the delegate is informed of the error. If a connection is already established, the method proceeds to subscribe to data updates.
     
     - Note: If the WebSocket connection is already established, the method directly proceeds to data subscription.
     
     - Returns: None.
     */
    func connectWebSocket() {
        if !self.webSocketConnection.isConnect {
            DispatchQueue.global(qos: .background).async {
                do {
                    try self.webSocketConnection.connect()
                    DispatchQueue.main.async {
                        self.webSocketConnection.delegate = self
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("setUpWebSocket: \(error)")
                        self.handleWebSocketConnectionError(error)
                    }
                }
            }
        } else {
            self.subScribe()
        }
        
    }
    /**
     Handles WebSocket connection errors by notifying the delegate.
     
     This private method is responsible for handling errors that occur during WebSocket connection setup. It informs the delegate about the connection error by calling the appropriate delegate method to display an error message to the user.
     
     - Parameter error: The error that occurred during WebSocket connection setup.
     
     - Returns: None.
     */
    
    private func handleWebSocketConnectionError(_ error: Error) {
        self.delegate?.notifyConnectionError(msg: "Connection Error")
    }
    
    /**
     Subscribes to the specified topic for recent trade updates.
     
     This method sends a subscription request to the WebSocketConnection to receive recent trade updates for the specified topic.
     */
    func subScribe() {
        self.webSocketConnection.topic = self.topic
        
        if self.webSocketConnection.isConnect {
            let subTopicJSONStr = createJSONString(op: Constants.subscribe, args: [topic])
            self.webSocketConnection.write(string: subTopicJSONStr ?? "")
            self.webSocketConnection.delegate = self
        }
    }
    /**
     Unsubscribes from the current topic by sending an unsubscription request to the WebSocket connection.
     
     This method sends an unsubscription request to the WebSocket connection if it is currently connected. The unsubscription request is created as a JSON string using the "unsubscribe" operation and the current topic. The method then writes the JSON string to the WebSocket connection.
     
     - Note: This method should be called when the WebSocket connection is active and subscribed to a topic.
     
     */
    func unSubScribe() {
        
        if self.webSocketConnection.isConnect {
            let topicOp = createJSONString(op: Constants.unSubscribe, args: [topic])
            self.webSocketConnection.write(string: topicOp ?? "")
        }
    }
    func getTrade(for indexPath: IndexPath) -> Trade {
        
        return self.trades[indexPath.row]
    }
    
    /**
     Creates a JSON string from provided operation and argument data.
     
     This private method constructs a JSON string from the given operation (op) and arguments (args) data. It formats the operation and arguments into a JSON dictionary and serializes it into a JSON data object. Then, it converts the data object into a UTF-8 encoded JSON string.
     
     - Parameters:
     - op: The operation to be included in the JSON dictionary.
     - args: The list of arguments associated with the operation.
     
     - Returns: The JSON string created from the operation and arguments, or nil if an error occurs during JSON serialization.
     */
    private func createJSONString(op: String, args: [String]) -> String? {
        let jsonData: [String: Any] = [
            "op": op,
            "args": args
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonData, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
extension RecentTradeViewModel: WebSocketConnectionDelegate {
    /**
     Notifies the delegate that the WebSocket connection was disconnected.
     
     - Parameter reason: A description of the disconnection reason.
     
     This method is called when the WebSocket connection has been disconnected. It informs the delegate about the disconnection event and provides a description of the reason for the disconnection.
     
     */
    func didDisconnect(reason: String) {
        self.delegate?.didDisconnect(msg: reason)
    }
    /**
     Notifies the delegate that the WebSocket connection was successfully established.
     
     This method is called when the WebSocket connection has been successfully established. It informs the delegate about the successful connection and initiates subscription to the specified topic.
     
     */
    
    
    func didConnect() {
        self.subScribe()
    }
    
    /**
     Notifies the delegate that subscription data has been received from the WebSocket connection.
     
     - Parameter data: The subscription data received from the WebSocket connection.
     
     This method is called when subscription data has been received from the WebSocket connection. It attempts to parse the received data as an OrderBook object and updates the tradeDataManager with the parsed data. If an error occurs during parsing, it prints an error message.
     
     - Note: This method assumes that the subscription data is formatted as JSON and can be decoded into an OrderBook object.
     
     */
    func didReceiveSubData(data: Data) {
        do {
            try self.tradeDataManager.parseJSON(from: data)
        }
        catch {
            print("Trade Error decoding JSON: \(error)")
        }
    }
}
