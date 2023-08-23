//
//  RecentTrade.swift
//  PrestoLabs
//
//  Created by tzh.
//
import Foundation

/// Represents the type of transaction action that can occur.

enum TransationAction: String, Codable {
    case partial, update, insert, delete
}
/// Protocol representing common trade data properties.

protocol TradeData: Codable, Equatable {
    var price: Double { get } // Price of the trade
    var timestamp: Date { get } // Timestamp of the trade
    
}
/// Represents an individual trade in the market.

struct Trade  : TradeData {
    
    let symbol: String // Trading symbol
    let side: String // Trade side (buy or sell)
    let size: Int // Trade size
    let price: Double // Trade price
    let timestamp: Date // Trade timestamp
    let dateStr: String? // Formatted timestamp string
    let tickDirection: String? // Tick direction information
    let trdMatchID: String // Trade match ID
    let grossValue: Double? // Gross trade value
    let homeNotional: Double? // Home currency notional value
    let foreignNotional: Double? // Foreign currency notional value
    let trdType: String? // Trade type
    
    /// Coding keys for decoding JSON properties.
    
    enum CodingKeys: String, CodingKey {
        case symbol, side, size, price, timestamp, tickDirection, trdMatchID, grossValue, homeNotional, foreignNotional, trdType
    }
    
    /// Initializes a Trade by decoding from a decoder.
    /// Throws: DecodingError if unable to decode JSON properties or timestamp is in an invalid format.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode properties
        symbol = try container.decode(String.self, forKey: .symbol)
        side = try container.decode(String.self, forKey: .side)
        size = try container.decode(Int.self, forKey: .size)
        price = try container.decode(Double.self, forKey: .price)
        trdMatchID = try container.decode(String.self, forKey: .trdMatchID)
        tickDirection = try container.decodeIfPresent(String.self, forKey: .tickDirection)
        grossValue = try container.decodeIfPresent(Double.self, forKey: .grossValue)
        homeNotional = try container.decodeIfPresent(Double.self, forKey: .homeNotional)
        foreignNotional = try container.decodeIfPresent(Double.self, forKey: .foreignNotional)
        trdType = try container.decodeIfPresent(String.self, forKey: .trdType)
        
        // Decode and format timestamp
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Example: 2023-08-08T12:11:02.146Z
        
        if let timestampDate = dateFormatter.date(from: timestampString){
            self.timestamp = timestampDate
            dateFormatter.dateFormat = "HH:mm:ss" // Example format, adjust as needed
            self.dateStr = dateFormatter.string(from: timestampDate)
            
        } else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Invalid timestamp format")
        }
        
    }
}
/// Represents a recent trade event.
struct RecentTrade: Codable {
    let table: String // Table name
    let action: TransationAction // Action type (insert, update, delete)
    let keys: [String]? // Keys for data access
    let types: [String: String]? // Data types for keys
    let filter: [String: String]? // Filter options for data
    let data: [Trade] // Array of Trade instances
}



