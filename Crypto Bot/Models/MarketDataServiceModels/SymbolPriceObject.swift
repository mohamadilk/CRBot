//
//  SymbolPriceObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class SymbolPriceObject: BaseApiModel {
    
    var symbol: String?
    var price: String?
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        symbol         <- map["symbol"]
        price          <- map["price"]
    }
}
