//
//  OrderBookResponseObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/7/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderBookResponseObject: BaseApiModel {
    
    var lastUpdateId: UInt64?
    var bids: Array<Array<String>>?
    var asks: Array<Array<String>>?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        lastUpdateId  <- map["lastUpdateId"]
        bids          <- map["bids"]
        asks          <- map["asks"]
    }
}
