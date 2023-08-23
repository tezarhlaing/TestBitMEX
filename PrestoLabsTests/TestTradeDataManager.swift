//
//  TestTradeDataManager.swift
//  PrestoLabsTests
//
//  Created by tzh.
//

import XCTest
@testable import PrestoLabs
import Combine

final class TestTradeDataManager: XCTestCase {
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    func loadJSONData(from fileName: String) -> Data? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
            do {
               return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func testHandleOrderBook() {
        let tradeDataManager = TradeDataManager<OrderBookItem>()

        guard let jsonData = loadJSONData(from: "testOrderbook") else {
            XCTFail("Failed to load JSON data")
            return
        }
        do {
            try tradeDataManager.parseJSONOrderBook(from: jsonData)
            let expectation = XCTestExpectation(description: "TopDescendingList publisher expectation")
            var buyOrders: [OrderBookItem] = []
            let publisher = tradeDataManager.getTopDescendingListPublisher()
            publisher
                .sink { updatedTrades in
                    buyOrders = updatedTrades
                    expectation.fulfill()
                }
                .store(in: &cancellables)

            wait(for: [expectation], timeout: 20)
            XCTAssertEqual(buyOrders.count, 23)
            
            let expectation1 = XCTestExpectation(description: "TopDescendingList publisher expectation")
            var sellOrders: [OrderBookItem] = []
            let publisher1 = tradeDataManager.getTopAscendingPublisher()
            publisher1
                .sink { updatedTrades in
                    sellOrders = updatedTrades
                    expectation1.fulfill()
                }
                .store(in: &cancellables)

            wait(for: [expectation1], timeout: 20)
            XCTAssertEqual(sellOrders.count, 92)

        }catch {
            XCTFail("Error decoding JSON: \(error)")
        }
    }
    func testOrderUpdateAction() {
        let tradeDataManager = TradeDataManager<OrderBookItem>()

        guard let jsonData = loadJSONData(from: "testOrderbook") else {
            XCTFail("Failed to load JSON data")
            return
        }
        do {
            try tradeDataManager.parseJSONOrderBook(from: jsonData)
            let expectation = XCTestExpectation(description: "TopDescendingList publisher expectation")
            var buyOrders: [OrderBookItem] = []
            let publisher = tradeDataManager.getTopDescendingListPublisher()
            publisher
                .sink { updatedTrades in
                    buyOrders = updatedTrades
                    expectation.fulfill()
                }
                .store(in: &cancellables)

            wait(for: [expectation], timeout: 20)
            XCTAssertEqual(buyOrders.count, 23)
            
            let expectation1 = XCTestExpectation(description: "TopDescendingList publisher expectation")
            var sellOrders: [OrderBookItem] = []
            let publisher1 = tradeDataManager.getTopAscendingPublisher()
            publisher1
                .sink { updatedTrades in
                    sellOrders = updatedTrades
                    expectation1.fulfill()
                }
                .store(in: &cancellables)

            wait(for: [expectation1], timeout: 20)
            XCTAssertEqual(sellOrders.count, 92)
            
            

        }catch {
            XCTFail("Error decoding JSON: \(error)")
        }
    }
    func testHandlePartialTrade() {
        let tradeDataManager = TradeDataManager<Trade>()

        guard let jsonData = loadJSONData(from: "TestTradeInitial") else {
            XCTFail("Failed to load JSON data")
            return
        }
        guard let jsonDataInsert = loadJSONData(from: "TestTradeInsert") else {
            XCTFail("Failed to load JSON data")
            return
        }
        do {
            try tradeDataManager.parseJSON(from: jsonData)
            let expectation = XCTestExpectation(description: "TopDescendingList publisher expectation")
            var trades: [Trade] = []
            let publisher = tradeDataManager.getTopDescendingListPublisher()

                    publisher
                        .sink { updatedTrades in
                            trades = updatedTrades
                            expectation.fulfill()
                        }
                        .store(in: &cancellables)

            wait(for: [expectation], timeout: 20)
            XCTAssertEqual(trades.count, 1)

           try tradeDataManager.parseJSON(from: jsonDataInsert)
            var trades2: [Trade] = []
            let expectation2 = XCTestExpectation(description: "TopDescendingList publisher expectation")
            let publisher2 = tradeDataManager.getTopDescendingListPublisher()
            publisher2
                .sink { updatedTrades in
                    trades2 = updatedTrades
                    expectation2.fulfill()

                }
                .store(in: &cancellables)
            wait(for: [expectation2], timeout: 20)

            XCTAssertEqual(trades2.count, 18)

            
        }catch {
            XCTFail("Error decoding JSON: \(error)")
        }
        
        
    }
    
}
