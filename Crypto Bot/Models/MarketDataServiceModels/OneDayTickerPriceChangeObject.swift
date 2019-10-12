//
//  OneDayTickerPriceChangeObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OneDayTickerPriceChangeObject: BaseApiModel {
    
    var symbol: String?
    var priceChange: String?
    var priceChangePercent: String?
    var weightedAvgPrice: String?
    var prevClosePrice: String?
    var lastPrice: String?
    var lastQty: String?
    var bidQty: String?
    var askQty: String?
    var bidPrice: String?
    var askPrice: String?
    var openPrice: String?
    var highPrice: String?
    var lowPrice: String?
    var volume: String?
    var quoteVolume: String?
    var openTime: TimeInterval?
    var closeTime: TimeInterval?
    var firstTradeId: UInt32?   // First tradeId
    var lastTradeId: UInt32?    // Last tradeId
    var count: UInt32?         // Trade count
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol               <- map["symbol"]
        priceChange          <- map["priceChange"]
        priceChangePercent   <- map["priceChangePercent"]
        weightedAvgPrice     <- map["weightedAvgPrice"]
        prevClosePrice       <- map["prevClosePrice"]
        lastPrice            <- map["lastPrice"]
        lastQty              <- map["lastQty"]
        askQty               <- map["askQty"]
        bidQty               <- map["bidQty"]
        bidPrice             <- map["bidPrice"]
        askPrice             <- map["askPrice"]
        openPrice            <- map["openPrice"]
        highPrice            <- map["highPrice"]
        lowPrice             <- map["lowPrice"]
        volume               <- map["volume"]
        quoteVolume          <- map["quoteVolume"]
        openTime             <- map["openTime"]
        closeTime            <- map["closeTime"]
        firstTradeId         <- map["firstId"]
        lastTradeId          <- map["lastId"]
        count                <- map["count"]

    }
}
