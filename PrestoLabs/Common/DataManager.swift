//
//  DataManager.swift
//  PrestoLabs
//
//  Created by tzh .
//

import Foundation
import Combine

/**
 A generic data manager class for handling real-time trade and order book data.

 This class manages the storage, processing, and distribution of real-time trade and order book data.
 It utilizes a Publisher-Subscriber pattern for notifying data changes and ensures thread safety
 using concurrent data queues.

 - Note: This class is generic and can be used with different types of trade and order book data.

 - Author: tzar

 ## Example Usage:
let tradeDataManager = TradeDataManager<RecentTrade>()
tradeDataManager.parseJSON(from: jsonData)
let topDescendingPublisher = tradeDataManager.getTopDescendingListPublisher()
let cancellable = topDescendingPublisher.sink { topTrades in
// Handle updated list of top descending trades
}


- Requires: `TradeType` to conform to the `TradeData` protocol.

- SeeAlso: `TradeData`, `RecentTrade`, `OrderBook`
*/

class TradeDataManager<TradeType: TradeData>  {
    /// The dictionary storing trade data based on their unique identifiers.
    private var dataList: [String: TradeType] = [:]
    /// The list of top descending trades based on timestamp.
    @Published private var topDescendingList: [TradeType] = []
    /// The concurrent dispatch queue for managing data access.

    private let dataQueue = DispatchQueue(label: "com.trade.data", attributes: .concurrent)
    /// The dictionary storing sell orders based on their identifiers.
    private var sellOrders: [Int: TradeType] = [:]
    /// The dictionary storing buy orders based on their identifiers.

    private var buyOrders: [Int: TradeType] = [:]
    /// The list of top ascending trades based on timestamp.
    @Published private var topAsendingList: [TradeType] = []
    
    /**
     Parses and processes JSON data representing a recent trade update.

     This method decodes JSON data using a JSONDecoder and processes it to handle recent trade updates.
     Upon successful decoding, the method dispatches the handling of trade updates to the `handleTradeUpdate(_:)` method
     within a concurrent barrier dispatch queue to ensure thread safety.

     - Parameter jsonData: The JSON data containing the recent trade update information.

     - Throws: An error if there is an issue with decoding the JSON data.

     - Note: This method is designed to be used within the context of the `TradeDataManager` class.

     ## Example Usage:
     let tradeDataManager = TradeDataManager<RecentTrade>()
     let jsonData: Data = ... // JSON data representing a recent trade update
     do {
     try tradeDataManager.parseJSON(from: jsonData)
     } catch {
     print("Error parsing JSON data: (error)")
     }
     */
    func parseJSON(from jsonData: Data) throws  {
        let decoder = JSONDecoder()
            do {
                
                let recentTrade = try decoder.decode(RecentTrade.self, from: jsonData)
               
                dataQueue.async(flags: .barrier) { [weak self] in
                    self?.handleTradeUpdate(recentTrade)
                    
                }
            }
            catch {
                print("Trade Data Manager Error decoding JSON:=> \(jsonData)")
            }
        
        
    }
    /**
     Parses and processes JSON data representing an order book update.

     This method decodes JSON data using a JSONDecoder and processes it to handle order book updates.
     Upon successful decoding, the method dispatches the handling of order book updates to the `handleOrderUpdate(_:)` method
     within a concurrent barrier dispatch queue to ensure thread safety.

     - Parameter jsonData: The JSON data containing the order book update information.

     - Throws: An error if there is an issue with decoding the JSON data.

     - Note: This method is designed to be used within the context of the `TradeDataManager` class.

     ## Example Usage
     let tradeDataManager = TradeDataManager<RecentTrade>()
     let jsonData: Data = ... // JSON data representing an order book update
     do {
     try tradeDataManager.parseJSONOrderBook(from: jsonData)
     } catch {
     print("Error parsing JSON data: (error)")
     }

     */

    func parseJSONOrderBook(from jsonData: Data) throws  {
        let decoder = JSONDecoder()
            do {
                
                let orderBook = try decoder.decode(OrderBook.self, from: jsonData)
            
                dataQueue.async(flags: .barrier) { [weak self] in
                    self?.handleOrderUpdate(orderBook)
                    
                }
            }
            catch {
                print("Data Manager Order Error decoding JSON:=> \(jsonData)")
            }
        
    }
    /**
     Handles the update of the order book based on the provided `OrderBook` instance.

     This method processes an `OrderBook` instance, updates the buy and sell orders accordingly based on the action type,
     and triggers updates to the top descending and ascending order lists.

     - Parameter orderBook: The `OrderBook` instance representing the order book update.
     
     - Note: This method should be called within a concurrent barrier queue for thread safety.
     */
    private func handleOrderUpdate(_ orderBook: OrderBook) {
        dataQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            switch orderBook.action {
            case .partial:
                // Clear existing buy and sell order dictionaries
                self.buyOrders = [:]
                self.sellOrders = [:]
                // Populate buy and sell order dictionaries based on order side
                for order in orderBook.data {
                    if order.side == "Buy" {
                        self.buyOrders[order.id] = order as? TradeType
                        
                    } else {
                        self.sellOrders[order.id] = order as? TradeType
                    }
                }
            case .insert:
                // Update buy and sell order dictionaries with new orders
                orderBook.data.forEach { order in
                    if order.side == "Buy" {
                        
                        self.buyOrders[order.id] = order as? TradeType
                        
                    } else {
                        self.sellOrders[order.id] = order as? TradeType
                    }
                }
            case .delete:
                // Remove orders from buy and sell order dictionaries
                orderBook.data.forEach { order in
                    if order.side == "Buy" {
                        self.buyOrders[order.id] = nil
                    } else {
                        self.sellOrders[order.id] = nil
                    }
                }
            case .update:
                // Update quantities for existing buy and sell orders
                orderBook.data.forEach { order in
                    if order.side == "Buy" {
                        if var buyOrder = self.buyOrders[order.id] as? OrderBookItem {
                            let qty = (buyOrder.size ?? 0) + (order.size ?? 0)
                            buyOrder.setQty(qty)
                        }
                        
                        
                    } else {
                        if var sellOrder = self.sellOrders[order.id] as? OrderBookItem {
                            let qty = (sellOrder.size ?? 0) + (sellOrder.size ?? 0)
                            sellOrder.setQty(qty)
                        }
                    }
                }
            }
            // Update top descending and ascending order lists
            self.updateTopOrderBuyList()
            self.updateTopOrderSellList()
        }
    }
    /**
     Updates the top descending order list based on the current buy orders.

     This method sorts buy orders in descending order of price and retains the top 20 orders,
     removing any exceeding the limit.
     */
    private func updateTopOrderBuyList() {
        // Sorting buy orders by price in descending order
            self.topDescendingList = self.buyOrders.values.sorted { order1 , order2 in
                return order1.price > order2.price
            }
        // Remove exceeding orders beyond the limit of 20

            if self.topDescendingList.count > 20 {
                self.topDescendingList.removeLast(self.topDescendingList.count - 20)
            }
        
    }
    /**
     Updates the top ascending order list based on the current sell orders.

     This method sorts sell orders in ascending order of price and retains the top 20 orders,
     removing any exceeding the limit.
     */
    private func updateTopOrderSellList() {
        // Sorting sell orders by price in ascending order
            self.topAsendingList = self.sellOrders.values.sorted { order1 , order2 in
                return order1.price < order2.price
            }
            
        // Remove exceeding orders beyond the limit of 20

            if self.topAsendingList.count > 20 {
                self.topAsendingList.removeLast(self.topAsendingList.count - 20)
            }
        
    }
    /**
     Handles the update of trade data based on the provided `RecentTrade` instance.

     This method processes a `RecentTrade` instance, updating the trade data based on the action type,
     and triggers updates to the top descending order list.

     - Parameter recentTrade: The `RecentTrade` instance representing the trade update.

     - Note: This method should be called within a concurrent barrier queue for thread safety.
     */
    private func handleTradeUpdate(_ recentTrade: RecentTrade) {
        dataQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            switch recentTrade.action {
            case .partial:
                // Clear the existing trade data dictionary and populate with new data
                self.dataList = [:]
                self.dataList = Dictionary(uniqueKeysWithValues: recentTrade.data.map { ($0.trdMatchID, $0 as! TradeType) })
                
            case .insert:
                // Update the trade data dictionary with new trades
                recentTrade.data.forEach { trade in
                    self.dataList[trade.trdMatchID] = trade as? TradeType
                }
                
            case .delete:
                // Remove trades from the trade data dictionary
                recentTrade.data.forEach { deletedTrade in
                    self.dataList[deletedTrade.trdMatchID] = nil
                }
            case .update:
                // Update existing trades in the trade data dictionary
                recentTrade.data.forEach { updatedTrade in
                    self.dataList[updatedTrade.trdMatchID] = updatedTrade as? TradeType
                }
                
            }
            // Update the top descending order list based on the updated trade data
            self.updateTopDescendingList(count: 30)
            
        }
        
    }
    /**
     Updates the top descending order list based on the current trade data.

     This method sorts trade data by timestamp in descending order and retains the top 'count' trades,
     removing any exceeding the limit.
     
     - Parameter count: The maximum number of top trades to retain.
     
     - Note: This method should be called within a concurrent queue.
     */
    private func updateTopDescendingList(count: Int) {
        dataQueue.async { [weak self] in
            guard let self = self else { return }
            // Sort trade data by timestamp in descending order

            self.topDescendingList = self.dataList.values.sorted { trade1 , trade2 in
                return trade1.timestamp > trade2.timestamp
            }
            // Remove exceeding trades beyond the specified limit

            if self.topDescendingList.count > count {
                self.topDescendingList.removeLast(self.topDescendingList.count - 30)
            }
        }
    }
    
    /**
     Returns a publisher for the top descending order list.

     This method provides a publisher that emits updates to the top descending order list.

     - Returns: A publisher for the top descending order list.
     */
    func getTopDescendingListPublisher() -> Published<[TradeType]>.Publisher {
        return $topDescendingList
    }
    /**
     Returns a publisher for the top ascending order list.

     This method provides a publisher that emits updates to the top ascending order list.

     - Returns: A publisher for the top ascending order list.
     */
    func getTopAscendingPublisher() -> Published<[TradeType]>.Publisher {
        return $topAsendingList
    }
}
