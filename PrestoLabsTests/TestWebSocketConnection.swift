//
//  TestWebSocketConnection.swift
//  PrestoLabsTests
//
//  Created by tzh .
//

import Foundation
import XCTest
@testable import PrestoLabs

final class TestWebSocketConnection: XCTestCase {
    class MockDelegate: WebSocketConnectionDelegate {
       
        
            var didConnectCalled = false
            var didDisconnectCalled = false
            var didReceiveMessageText: String?
        var didReceiveSubData = false

            func didConnect() {
                print("mock connect")
                didConnectCalled = true
            }
        func didDisconnect(reason: String) {
            print("mock disconnect")

            didDisconnectCalled = true

        }
            
        func didReceiveSubData(data: Data) {
            didReceiveSubData = true
        }
            func didReceiveMessage(text: String) {
                didReceiveMessageText = text
        }
    }
    // Test WebSocketConnection's connection and disconnection
    func testWebSocketConnection() {
        let webSocketConnection = WebSocketConnection.shared
        let mockDelegate = MockDelegate()
        webSocketConnection.delegate = mockDelegate

        XCTAssertFalse(webSocketConnection.isConnect)
        
        webSocketConnection.connect()
        let expectation = XCTestExpectation(description: "WebSocket Connection Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(mockDelegate.didConnectCalled, "didConnect should have been called")
            XCTAssertTrue(webSocketConnection.isConnect, "WebSocket should be connected")
            expectation.fulfill()
        }
       // wait(for: [expectation], timeout: 60)

      /*  webSocketConnection.disconnect()
        let disconnectExpectation = XCTestExpectation(description: "WebSocket Disconnection Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(mockDelegate.didDisconnectCalled, "didDisconnect should have been called")
            XCTAssertFalse(webSocketConnection.isConnect, "WebSocket should be disconnected")
            disconnectExpectation.fulfill()
        }
        wait(for: [disconnectExpectation], timeout: 5)*/
    }
    
    func testWebSocketMessageRecived() {
        let webSocketConnection = WebSocketConnection.shared
        let mockDelegate = MockDelegate()
        webSocketConnection.delegate = mockDelegate
        webSocketConnection.connect()
        webSocketConnection.topic = "trade:XBTUSD"
        let jsonString = """
        {
            "op": "subscribe",
            "args": ["trade:XBTUSD"]
        }
        """
        webSocketConnection.write(string: jsonString)
        let expectation = XCTestExpectation(description: "WebSocket Text Receive Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(mockDelegate.didReceiveSubData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60)
    }
}
