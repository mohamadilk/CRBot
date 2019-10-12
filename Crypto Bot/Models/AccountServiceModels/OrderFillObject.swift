//
//  OrderFillObject.swift
//  Crypto Bot
//
//  Created by Mohammad Ilkhani on 10/8/19.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderFillObject: BaseApiModel {
    var price: String?
    var qty: String?
    var commission: String?
    var commissionAsset: String?

    public required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map)
    {
        super.mapping(map: map)
        
        price               <- map["price"]
        qty                 <- map["qty"]
        commission          <- map["commission"]
        commissionAsset     <- map["commissionAsset"]
    }
}
