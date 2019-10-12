//
//  SymbolOrderBookObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class SymbolOrderBookObject: BaseApiModel {

    var symbol: String?
    var bidPrice: String?
    var bidQty: String?
    var askPrice: String?
    var askQty: String?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol          <- map["symbol"]
        bidPrice        <- map["bidPrice"]
        bidQty          <- map["bidQty"]
        askPrice        <- map["askPrice"]
        askQty          <- map["askQty"]
    }
}
