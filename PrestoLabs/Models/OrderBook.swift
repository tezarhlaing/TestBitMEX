//
//  OrderBook.swift
//  PrestoLabs
//
//  Created by tzh.
//

import Foundation
/// Represents a custom error type for JSON parsing.
enum JSONParseError: Error {
    case missingField(String) // Error case indicating a missing JSON field during parsing.
}

/// Represents an individual order book item.
struct OrderBookItem: TradeData {
    
    let symbol: String // Trading symbol
    let id: Int  // Order ID
    let side: String // Buy or sell side indicator
    var size: Int? // Size of the order (can be nil for certain actions)
    let price: Double // Price of the order
    let timestamp: Date // Timestamp of the order
    var qty: Int? // Total quantity (can be nil for certain actions)
    
    /// Coding keys for decoding JSON properties.
    enum CodingKeys: String, CodingKey {
        case symbol,id, side, size, price, timestamp
    }
    mutating func setQty(_ qty : Int) {
        self.qty = qty
    }
    /// Initializes an OrderBookItem by decoding from a decoder.
    /// Throws: DecodingError if unable to decode JSON properties or timestamp is in an invalid format.
   
   init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        id = try container.decode(Int.self, forKey: .id)
        side = try container.decode(String.self, forKey: .side)
       if let sizeValue = try container.decodeIfPresent(Int.self, forKey: .size) {
               size = sizeValue
           } else {
               size = nil  // Set size to nil for "delete" action
           }
        price = try container.decode(Double.self, forKey: .price)
        self.qty = size ?? 0
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //2023-08-08T12:11:02.146Z
         
        if let timestampDate = dateFormatter.date(from: timestampString){
            self.timestamp = timestampDate

        } else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Invalid timestamp format")
        }

    }
}

/// Represents a complete order book containing multiple OrderBookItem instances.

struct OrderBook: Codable {
    let table: String // Table name
    let action: TransationAction // Action type (insert, update, delete)
    let data: [OrderBookItem]  // Array of OrderBookItem instances
    let keys: [String]? // Keys for data access
   let types: [String: String]? //Data types for keys
    let filter: [String: String]? // Filter options for data

}


