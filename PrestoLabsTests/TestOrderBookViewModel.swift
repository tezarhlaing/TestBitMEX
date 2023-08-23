//
//  TestOrderBookViewModel.swift
//  PrestoLabsTests
//
//  Created by tzh.
//

import XCTest
@testable import PrestoLabs

final class TestOrderBookViewModel: XCTestCase {
    var orderBookViewModel: OrderBookViewModel!
    
    override func setUp() {
        super.setUp()
        orderBookViewModel = OrderBookViewModel(topic: "orderBookL2:XBTUSD", webSocketConnection: WebSocketConnection.shared)
    }
    
    override func tearDown() {
        orderBookViewModel = nil
        super.tearDown()
    }
  /*  func loadJSONData(from fileName: String) -> String? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonString = String(data: data, encoding: .utf8) {
                    return jsonString
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
        return nil
    }*/
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
    func testOrderCount() throws  {
        guard let jsonData = loadJSONData(from: "testOrderbook") else {
            XCTFail("Failed to load JSON data")
            return
        }
        do {
            try self.orderBookViewModel.tradeDataManager.parseJSONOrderBook(from: jsonData)
            let expectation = XCTestExpectation(description: "TopDescendingList publisher expectation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let sellOrderCount = self.orderBookViewModel.sellOrderCount
                let buyOrderCount = self.orderBookViewModel.buyOrderCount
                XCTAssertEqual(sellOrderCount, 92, "sellOrderCount should match the number of sellOrders")
                XCTAssertEqual(buyOrderCount, 23, "sellOrderCount should match the number of sellOrders")

                expectation.fulfill()
            }



        } catch {
            XCTFail("Error decoding JSON: \(error)")

        }
     
    }
    
   
    
    /*
     sample index (r,col) in colleciton view
     (0,0)   (0,1)
     (0,2)   (0,3)
     (1,0)   (1,1)
     (1,2)   (1,3)
     */
    func testOrderBookItemForIndexPath() throws {
        let json = """
                [{"symbol": "AAPL","id": 4,"side": "buy","size": 100,"price": 150.25,"timestamp": "2023-08-08T12:11:02.146Z"
                },{"symbol": "AAPL","id": 5,"side": "buy","size": 50,"price": 152.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 6,"side": "buy","size": 3,"price": 154.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 7,"side": "buy","size": 6,"price": 300.25,"timestamp": "2023-08-08T12:11:02.146Z"}]
                """
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
               
        let mockBuyOrders = try decoder.decode([OrderBookItem].self, from: jsonData)
        XCTAssertEqual(mockBuyOrders.count, 4)

        let selljson = """
                [{"symbol": "AAPL","id": 1,"side": "Sell","size": 100,"price": 150.25,"timestamp": "2023-08-08T12:11:02.146Z"
                },{"symbol": "AAPL","id": 2,"side": "Sell","size": 50,"price": 152.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 3,"side": "Sell","size": 3,"price": 154.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 8,"side": "Sell","size": 6,"price": 300.25,"timestamp": "2023-08-08T12:11:02.146Z"}]
                """
        let jsonDataSell = selljson.data(using: .utf8)!
        let mockSellOrders = try decoder.decode([OrderBookItem].self, from: jsonDataSell)
        XCTAssertEqual(mockSellOrders.count, 4)
        orderBookViewModel.setOrders(sellOrders: mockSellOrders, buyOrders: mockBuyOrders)
        //let indexPath1 = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 1, section: 0)
       // let indexPath3 = IndexPath(row: 2, section: 0)
       // let indexPath4 = IndexPath(row: 3, section: 0)

        let indexPath5 = IndexPath(row: 0, section: 1)
       // let indexPath6 = IndexPath(row: 1, section: 1)
       // let indexPath7 = IndexPath(row: 2, section: 1)
        let indexPath8 = IndexPath(row: 3, section: 1)

        let order = orderBookViewModel.orderBookItem(for: indexPath5)
        XCTAssertEqual(order?.id, 6, "according to index , should be buy order at index 2")

       let order1 = orderBookViewModel.orderBookItem(for: indexPath2)
       XCTAssertEqual(order1?.id, 1, "according to index , should be sell order at index 1")

           let order2 = orderBookViewModel.orderBookItem(for: indexPath8)
           XCTAssertEqual(order2?.id, 8, "according to index , should be sell order at index 3")

    }
    func testOrderBookItemBuyOrderOnly() throws {
        let json = """
                [{"symbol": "AAPL","id": 4,"side": "buy","size": 100,"price": 150.25,"timestamp": "2023-08-08T12:11:02.146Z"
                },{"symbol": "AAPL","id": 5,"side": "buy","size": 50,"price": 152.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 6,"side": "buy","size": 3,"price": 154.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 7,"side": "buy","size": 6,"price": 300.25,"timestamp": "2023-08-08T12:11:02.146Z"}]
                """
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
               
        let mockBuyOrders = try decoder.decode([OrderBookItem].self, from: jsonData)
        XCTAssertEqual(mockBuyOrders.count, 4)

       
        orderBookViewModel.setOrders(sellOrders: [OrderBookItem](), buyOrders: mockBuyOrders)
       // let indexPath1 = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 1, section: 0)
       // let indexPath3 = IndexPath(row: 2, section: 0)
       // let indexPath4 = IndexPath(row: 3, section: 0)

        let indexPath5 = IndexPath(row: 0, section: 1)
       // let indexPath6 = IndexPath(row: 1, section: 1)
       // let indexPath7 = IndexPath(row: 2, section: 1)
       // let indexPath8 = IndexPath(row: 3, section: 1)

        let order = orderBookViewModel.orderBookItem(for: indexPath5)
        XCTAssertEqual(order?.id, 6, "according to index , should be buy order at index 2")

        let order1 = orderBookViewModel.orderBookItem(for: indexPath2)
        XCTAssertNil(order1)
        let selljson = """
                [{"symbol": "AAPL","id": 1,"side": "Sell","size": 100,"price": 150.25,"timestamp": "2023-08-08T12:11:02.146Z"
                },{"symbol": "AAPL","id": 2,"side": "Sell","size": 50,"price": 152.25,"timestamp": "2023-08-08T12:11:02.146Z"},{"symbol": "AAPL","id": 3,"side": "Sell","size": 3,"price": 154.25,"timestamp": "2023-08-08T12:11:02.146Z"}]
                """
        let jsonDataSell = selljson.data(using: .utf8)!
        let mockSellOrders = try decoder.decode([OrderBookItem].self, from: jsonDataSell)
        XCTAssertEqual(mockSellOrders.count, 3)
   
        orderBookViewModel.setOrders(sellOrders:mockSellOrders, buyOrders: mockBuyOrders)

    }
}
