//
//  RecentTradesListResponse.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class TradeObject: BaseApiModel {
    
    var _id: UInt32?
    var price: String?
    var qty: String?
    var quoteQty: String?
    var time: TimeInterval?
    var isBuyerMaker: Bool?
    var isBestMatch: Bool?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        _id           <- map["id"]
        price         <- map["price"]
        qty           <- map["qty"]
        quoteQty      <- map["quoteQty"]
        time          <- map["time"]
        isBuyerMaker  <- map["isBuyerMaker"]
        isBestMatch   <- map["isBestMatch"]
    }
}
