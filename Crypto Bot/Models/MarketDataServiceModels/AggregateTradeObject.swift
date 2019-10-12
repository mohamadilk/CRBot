//
//  AggregateTradeObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class AggregateTradeObject: BaseApiModel {
    
    var aggregateTradeId: UInt32?
    var price: String?
    var quantity: String?
    var firstTradeId: UInt32?
    var lastTradeId: UInt32?
    var timeStamp: TimeInterval?
    var isBuyerTheMaker: Bool?
    var isTradeTheBestPriceMatch: Bool?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        aggregateTradeId           <- map["a"]
        price                      <- map["p"]
        quantity                   <- map["q"]
        firstTradeId               <- map["f"]
        lastTradeId                <- map["l"]
        timeStamp                  <- map["T"]
        isBuyerTheMaker            <- map["m"]
        isTradeTheBestPriceMatch   <- map["M"]

    }
}
